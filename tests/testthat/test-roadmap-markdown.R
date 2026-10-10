test_that("roadmap_markdown() leaves out pull requests, closed milestones and excluded issues", {
  issues <- list(
    fake_issue(1, "Kept", fake_milestone(1, "v3.0.0")),
    fake_issue(
      2,
      "Pull request",
      fake_milestone(1, "v3.0.0"),
      pull_request = TRUE
    ),
    fake_issue(
      3,
      "Internal work",
      fake_milestone(1, "v3.0.0"),
      labels = "internal-tooling"
    ),
    fake_issue(4, "Excluded by number", fake_milestone(1, "v3.0.0")),
    fake_issue(
      5,
      "Old milestone",
      fake_milestone(2, "v2.0.0", state = "closed")
    )
  )
  local_mocked_bindings(gh = fake_gh(issues), .package = "gh")
  pkg <- pkgdown::as_pkgdown(fake_package(c(
    "roadmap:",
    "  enabled: true",
    "  exclude:",
    "    labels: [internal*]",
    "    issues: [4]"
  )))

  markdown <- paste(roadmap_markdown(pkg), collapse = "\n")

  expect_match(markdown, "Kept")
  expect_no_match(
    markdown,
    "Pull request|Internal work|Excluded by number|Old milestone"
  )
})

test_that("roadmap_markdown() orders milestones by version and cards by number, open first", {
  issues <- list(
    fake_issue(9, "Open late", fake_milestone(11, "v2.11.0")),
    fake_issue(
      3,
      "Closed early",
      fake_milestone(11, "v2.11.0"),
      state = "closed"
    ),
    fake_issue(7, "Older version", fake_milestone(9, "v2.9.0")),
    fake_issue(8, "Backlog item", fake_milestone(12, "Backlog")),
    fake_issue(1, "Newest version", fake_milestone(13, "v3.0.0"))
  )
  local_mocked_bindings(gh = fake_gh(issues), .package = "gh")
  pkg <- pkgdown::as_pkgdown(fake_package(c("roadmap:", "  enabled: true")))

  headings <- grep("^## ", roadmap_markdown(pkg), value = TRUE)
  cards <- grep("^#### ", roadmap_markdown(pkg), value = TRUE)

  expect_equal(
    headings,
    c("## v2.9.0", "## v2.11.0", "## v3.0.0", "## Backlog")
  )
  expect_equal(
    grep("Open late|Closed early", cards, value = TRUE),
    c(
      "#### [Open late](https://github.com/stan-dev/fake/issues/9)",
      "#### [✓ Closed early](https://github.com/stan-dev/fake/issues/3)"
    )
  )
})

test_that("roadmap_markdown() applies milestone and issue overrides and custom cards", {
  issues <- list(
    fake_issue(9, "Original title", fake_milestone(3, "v3.0.0")),
    fake_issue(5, "Second", fake_milestone(3, "v3.0.0"))
  )
  local_mocked_bindings(gh = fake_gh(issues), .package = "gh")
  pkg <- pkgdown::as_pkgdown(fake_package(c(
    "roadmap:",
    "  enabled: true",
    "  overrides:",
    "    milestones:",
    "      \"3\":",
    "        title: Version three",
    "        description: Custom description.",
    "        cards:",
    "          - title: Your ideas",
    "            description: Tell us.",
    "            order: 0",
    "    issues:",
    "      \"9\":",
    "        title: Renamed",
    "        description: Custom card text.",
    "        order: 1"
  )))

  markdown <- roadmap_markdown(pkg)

  expect_true("## Version three" %in% markdown)
  expect_true("Custom description." %in% markdown)
  expect_match(paste(markdown, collapse = "\n"), "Your ideas.*Renamed.*Second")
  expect_match(paste(markdown, collapse = "\n"), "Custom card text.")
})
