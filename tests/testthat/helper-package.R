fake_package <- function(config) {
  dir <- tempfile()
  dir.create(dir)
  writeLines(
    c(
      "Package: fake",
      "Version: 1.0",
      "Title: Fake",
      "Description: Fake.",
      "License: MIT"
    ),
    file.path(dir, "DESCRIPTION")
  )
  writeLines(config, file.path(dir, "_pkgdown.yml"))
  dir
}

article_path <- function(dir) {
  file.path(dir, "vignettes", "articles", "roadmap.Rmd")
}
