#' Build a Stan pkgdown site
#'
#' Writes the roadmap article and adds the roadmap to the navbar when
#' `roadmap: enabled: true` is set, then calls [pkgdown::build_site()] with all
#' other arguments.
#'
#' @inheritParams pkgdown::build_site
#' @param ... Passed on to [pkgdown::build_site()].
#' @param override Passed on to [pkgdown::build_site()], merged over the
#'   navbar override from `roadmap_override()`.
#' @return The result of [pkgdown::build_site()], invisibly.
#' @export
build_site <- function(pkg = ".", ..., override = list()) {
  config <- pkgdown::as_pkgdown(pkg)
  use_roadmap(config)
  pkgdown::build_site(
    pkg,
    ...,
    override = utils::modifyList(roadmap_override(config), override)
  )
}

#' Navbar override for the roadmap
#'
#' Inserts `roadmap` into the navbar after `news` when the roadmap is enabled.
#' Used by [build_site()] and the GitHub Action.
#'
#' @inheritParams use_roadmap
#' @return A pkgdown override list, empty when the roadmap is disabled.
#' @export
roadmap_override <- function(pkg = ".") {
  pkg <- pkgdown::as_pkgdown(pkg)
  if (!isTRUE(pkg$meta$roadmap$enabled)) {
    return(list())
  }
  left <- pkg$meta$navbar$structure$left
  after <- match("news", left, nomatch = length(left))
  list(navbar = list(structure = list(left = append(left, "roadmap", after))))
}
