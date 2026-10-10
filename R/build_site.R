#' Build a Stan pkgdown site
#'
#' Adds the roadmap when `roadmap: enabled: true` is set, then calls
#' [pkgdown::build_site()] with all other arguments.
#'
#' @inheritParams pkgdown::build_site
#' @param ... Passed on to [pkgdown::build_site()].
#' @param override Passed on to [pkgdown::build_site()].
#' @return The result of [pkgdown::build_site()], invisibly.
#' @export
build_site <- function(pkg = ".", ..., override = list()) {
  pkgdown::build_site(roadmap_site(pkg), ..., override = override)
}

#' Prepare a pkgdown site for the roadmap
#'
#' Writes the roadmap article, adds `roadmap` to the navbar after `news`, and
#' hides the article from the Articles index while keeping it built. Used by
#' [build_site()] and the GitHub Action.
#'
#' @param path Path to the package.
#' @return A pkgdown object, unchanged when the roadmap is disabled.
#' @noRd
roadmap_site <- function(path = ".") {
  pkg <- pkgdown::as_pkgdown(path)
  config <- pkg$meta$roadmap
  if (!isTRUE(config$enabled)) {
    return(pkg)
  }

  article_format <- config$format %||% "rmd"
  if (!article_format %in% c("rmd", "qmd")) {
    stop("`roadmap: format` must be `rmd` or `qmd`.", call. = FALSE)
  }
  extensions <- c(rmd = "Rmd", qmd = "qmd")
  dir <- file.path(pkg$src_path, "vignettes", "articles")
  other_format <- setdiff(names(extensions), article_format)
  other <- file.path(dir, paste0("roadmap.", extensions[[other_format]]))
  if (file.exists(other)) {
    stop(
      "`", other, "` exists alongside the ", article_format, " article. ",
      "Remove one of them.",
      call. = FALSE
    )
  }
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  writeLines(
    c("---", "title: Roadmap", "---", "", roadmap_markdown(pkg)),
    file.path(dir, paste0("roadmap.", extensions[[article_format]]))
  )

  pkg <- pkgdown::as_pkgdown(path)
  left <- pkg$meta$navbar$structure$left
  pkg$meta$navbar$structure$left <- append(
    left,
    "roadmap",
    match("news", left, nomatch = length(left))
  )
  sections <- pkg$meta$articles %||%
    list(
      list(title = "All vignettes", contents = list("starts_with(\"\")"))
    )
  sections <- lapply(sections, function(section) {
    section$contents <- c(section$contents, "-starts_with('articles/roadmap')")
    section
  })
  pkg$meta$articles <- c(
    sections,
    list(list(title = "internal", contents = list("articles/roadmap")))
  )
  pkg
}

#' Build the GitHub Pages site
#'
#' @param pr_number Pull request number. Empty builds the main site.
#' @export
build_gha_site <- function(pr_number = Sys.getenv("PR_NUMBER")) {
  pkg <- roadmap_site(".")
  override <- list()
  if (nzchar(pr_number)) {
    if (pkg$development$mode == "devel") {
      Sys.setenv(PKGDOWN_DEV_MODE = "unreleased")
    }
    override$url <- paste0(pkg$meta$url, "/pr/", pr_number)
    override$template$params$noindex <- TRUE
  }
  pkgdown::build_site_github_pages(
    pkg = pkg,
    lazy = FALSE,
    run_dont_run = TRUE,
    new_process = TRUE,
    override = override
  )
}
