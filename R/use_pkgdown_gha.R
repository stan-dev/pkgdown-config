#' Copy the Stan pkgdown GitHub Action
#'
#' Copies this package's `pkgdown.yaml` workflow into `.github/workflows`.
#'
#' @param pkg Path to the package.
#' @return The path of the workflow, invisibly.
#' @export
use_pkgdown_gha <- function(pkg = ".") {
  path <- file.path(pkg, ".github", "workflows", "pkgdown.yaml")
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  file.copy(
    system.file("workflows", "pkgdown.yaml", package = "pkgdownconfig"),
    path,
    overwrite = TRUE
  )
  invisible(path)
}
