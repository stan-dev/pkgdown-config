#' Build a Stan pkgdown site
#'
#' Writes the roadmap article when `roadmap: enabled: true` is set, then calls
#' [pkgdown::build_site()] with all other arguments.
#'
#' @inheritParams pkgdown::build_site
#' @param ... Passed on to [pkgdown::build_site()].
#' @param override Passed on to [pkgdown::build_site()].
#' @return The result of [pkgdown::build_site()], invisibly.
#' @export
build_site <- function(pkg = ".", ..., override = list()) {
  use_roadmap(pkg)
  pkgdown::build_site(roadmap_site(pkg), ..., override = override)
}

#' Add the roadmap to a pkgdown site
#'
#' Adds `roadmap` to the navbar after `news`, and hides the roadmap article from
#' the Articles index while keeping it built. Call it after [use_roadmap()] so
#' the article is parsed. Used by [build_site()] and the GitHub Action.
#'
#' @inheritParams use_roadmap
#' @return A pkgdown object, unchanged when the roadmap is disabled.
#' @export
roadmap_site <- function(pkg = ".") {
  pkg <- pkgdown::as_pkgdown(pkg)
  if (!isTRUE(pkg$meta$roadmap$enabled)) {
    return(pkg)
  }
  left <- pkg$meta$navbar$structure$left
  pkg$meta$navbar$structure$left <- append(
    left,
    "roadmap",
    match("news", left, nomatch = length(left))
  )
  sections <- pkg$meta$articles %||% list(
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
