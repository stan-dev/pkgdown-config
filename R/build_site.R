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
