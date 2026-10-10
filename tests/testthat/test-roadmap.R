test_that("roadmap_site() writes the article in the configured format", {
  local_mocked_bindings(roadmap_markdown = function(pkg) "## Stub")
  rmd <- fake_package(c("roadmap:", "  enabled: true"))
  qmd <- fake_package(c("roadmap:", "  enabled: true", "  format: qmd"))

  roadmap_site(rmd)
  roadmap_site(qmd)

  expect_true(file.exists(article_path(rmd, "Rmd")))
  expect_false(file.exists(article_path(rmd, "qmd")))
  expect_true(file.exists(article_path(qmd, "qmd")))
  expect_false(file.exists(article_path(qmd, "Rmd")))
  expect_match(readLines(article_path(qmd, "qmd")), "## Stub", all = FALSE)
})

test_that("roadmap_site() writes nothing when disabled", {
  local_mocked_bindings(roadmap_markdown = function(pkg) stop("should not run"))
  pkg <- fake_package(c("roadmap:", "  enabled: false"))

  roadmap_site(pkg)

  expect_false(file.exists(article_path(pkg, "Rmd")))
})

test_that("roadmap_site() rejects formats other than rmd and qmd", {
  local_mocked_bindings(roadmap_markdown = function(pkg) "## Stub")
  pkg <- fake_package(c("roadmap:", "  enabled: true", "  format: html"))

  expect_error(roadmap_site(pkg), "rmd")
})

test_that("roadmap_site() adds the navbar link only when enabled", {
  local_mocked_bindings(roadmap_markdown = function(pkg) "## Stub")
  navbar <- c("navbar:", "  structure:", "    left: [home, news, stan]")
  enabled <- fake_package(c(navbar, "roadmap:", "  enabled: true"))
  disabled <- fake_package(c(navbar, "roadmap:", "  enabled: false"))

  expect_equal(
    roadmap_site(enabled)$meta$navbar$structure$left,
    c("home", "news", "roadmap", "stan")
  )
  expect_equal(
    roadmap_site(disabled)$meta$navbar$structure$left,
    c("home", "news", "stan")
  )
})
