fake_package <- function(config) {
  dir <- tempfile()
  dir.create(dir)
  writeLines(
    c(
      "Package: fake",
      "Version: 1.0",
      "Title: Fake",
      "Description: Fake.",
      "License: MIT",
      "URL: https://github.com/stan-dev/fake",
      "Authors@R: person(\"A\", \"B\", role = c(\"aut\", \"cre\"), email = \"a@b.c\")"
    ),
    file.path(dir, "DESCRIPTION")
  )
  writeLines(config, file.path(dir, "_pkgdown.yml"))
  dir
}

article_path <- function(dir, ext) {
  file.path(dir, "vignettes", "articles", paste0("roadmap.", ext))
}
