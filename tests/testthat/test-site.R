build_roadmap_site <- function(format) {
  issues <- list(fake_issue(1, "Roadmap item", fake_milestone(1, "v3.0.0")))
  local_mocked_bindings(gh = fake_gh(issues), .package = "gh")
  withr::local_envvar(CI = "true")
  dir <- fake_package(c(
    "url: https://example.org",
    "template:",
    "  package: pkgdownconfig",
    "roadmap:",
    "  enabled: true",
    paste0("  format: ", format),
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

  pkgdownconfig::build_site(dir, preview = FALSE, new_process = FALSE, quiet = TRUE)
  dir
}

test_that("build_site() builds the roadmap beside a site with its own articles", {
  skip_on_cran()
  skip_if_not_installed("pkgdownconfig")
  dir <- build_roadmap_site("rmd")

  docs <- file.path(dir, "docs")
  index <- readLines(file.path(docs, "articles", "index.html"))
  expect_true(file.exists(file.path(dir, "vignettes", "articles", "roadmap.Rmd")))
  expect_true(file.exists(file.path(docs, "articles", "roadmap.html")))
  expect_true(any(grepl('href="guide.html"', index)))
  expect_false(any(grepl('href="roadmap.html"', index)))
  expect_true(any(grepl('href="articles/roadmap.html"', readLines(file.path(docs, "index.html")))))
})

test_that("build_site() builds a Quarto roadmap when the format is qmd", {
  skip_on_cran()
  skip_if_not_installed("pkgdownconfig")
  skip_if(Sys.which("quarto") == "", "Quarto is not installed")
  dir <- build_roadmap_site("qmd")

  docs <- file.path(dir, "docs")
  index <- readLines(file.path(docs, "articles", "index.html"))
  expect_true(file.exists(file.path(dir, "vignettes", "articles", "roadmap.qmd")))
  expect_false(file.exists(file.path(dir, "vignettes", "articles", "roadmap.Rmd")))
  expect_true(file.exists(file.path(docs, "articles", "roadmap.html")))
  expect_false(any(grepl('href="roadmap.html"', index)))
})
