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
  if (!isTRUE(pkg$meta$roadmap$enabled)) {
    return(pkg)
  }
  write_roadmap(pkg)
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
  if (nzchar(pr_number) && pkg$development$mode == "devel") {
    Sys.setenv(PKGDOWN_DEV_MODE = "unreleased")
  }
  pkgdown::build_site_github_pages(
    pkg = pkg,
    lazy = FALSE,
    run_dont_run = TRUE,
    new_process = TRUE,
    override = gha_override(pkg, pr_number)
  )
}

#' Build overrides for a pull request preview
#'
#' @param pkg A pkgdown object.
#' @param pr_number The pull request number, or an empty string.
#' @return A pkgdown override list, empty when there is no pull request.
#' @noRd
gha_override <- function(pkg, pr_number) {
  if (!nzchar(pr_number)) {
    return(list())
  }
  list(
    url = paste0(pkg$meta$url, "/pr/", pr_number),
    template = list(params = list(noindex = TRUE))
  )
}
