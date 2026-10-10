test_that("build_site() builds the roadmap beside a site with its own articles", {
  skip_on_cran()
  skip_if_not_installed("pkgdownconfig")
  issues <- list(fake_issue(1, "Roadmap item", fake_milestone(1, "v3.0.0")))
  local_mocked_bindings(gh = fake_gh(issues), .package = "gh")
  withr::local_envvar(CI = "true")
  dir <- fake_package(c(
    "url: https://example.org",
    "template:",
    "  package: pkgdownconfig",
    "roadmap:",
    "  enabled: true",
    "articles:",
    "  - title: Guides",
    "    contents:",
    "      - articles/guide"
  ))
  dir.create(file.path(dir, "vignettes", "articles"), recursive = TRUE)
  writeLines(
    c("---", "title: Guide", "---", "", "Text."),
    file.path(dir, "vignettes", "articles", "guide.Rmd")
  )

  pkgdownconfig::build_site(
    dir,
    preview = FALSE,
    new_process = FALSE,
    quiet = TRUE
  )

  docs <- file.path(dir, "docs")
  index <- readLines(file.path(docs, "articles", "index.html"))
  expect_true(file.exists(file.path(docs, "articles", "roadmap.html")))
  expect_true(any(grepl('href="guide.html"', index)))
  expect_false(any(grepl('href="roadmap.html"', index)))
  expect_true(any(grepl(
    'href="articles/roadmap.html"',
    readLines(file.path(docs, "index.html"))
  )))
})
