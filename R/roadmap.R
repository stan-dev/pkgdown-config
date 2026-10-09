#' Print the roadmap
#'
#' Renders the issues of the open GitHub milestones of the package as pandoc
#' markdown, one section per milestone. This is the body of the article written
#' by [use_roadmap()].
#'
#' @param pkg Path to the package, or a pkgdown object from
#'   [pkgdown::as_pkgdown()]. The default is two levels up, which is the working
#'   directory pkgdown renders articles from.
#' @return `NULL`, invisibly. Called for its printed output.
#' @export
roadmap <- function(pkg = "../..") {
  pkg <- pkgdown::as_pkgdown(pkg)
  config <- pkg$meta$roadmap
  repo <- gsub("^https://github.com/|/$", "", pkg$repo$url$home)
  issues <- gh::gh(
    "/repos/{repo}/issues",
    repo = repo,
    milestone = "*",
    state = "all",
    .limit = Inf
  )
  issues <- Filter(
    function(issue) {
      is.null(issue$pull_request) &&
        issue$milestone$state == "open" &&
        !roadmap_excluded(issue, config$exclude)
    },
    issues
  )
  closed <- vapply(issues, function(issue) issue$state == "closed", NA)
  numbers <- vapply(issues, `[[`, 0L, "number")
  issues <- issues[order(closed, numbers)]
  milestones <- vapply(issues, function(issue) issue$milestone$number, 0L)

  sections <- lapply(split(issues, milestones), roadmap_milestone, config)
  cat(unlist(sections), sep = "\n")
}

#' Write the roadmap article
#'
#' Writes `vignettes/articles/roadmap.Rmd`, which calls [roadmap()], when
#' `roadmap: enabled: true` is set in `_pkgdown.yml`.
#'
#' @param pkg Path to the package, or a pkgdown object from
#'   [pkgdown::as_pkgdown()].
#' @return The path of the article, invisibly, or `NULL` invisibly if the
#'   roadmap is disabled.
#' @export
use_roadmap <- function(pkg = ".") {
  pkg <- pkgdown::as_pkgdown(pkg)
  config <- pkg$meta$roadmap
  if (!isTRUE(config$enabled)) {
    return(invisible())
  }
  if (!identical(config$format, "rmd")) {
    stop("Only `roadmap: format: rmd` is supported.", call. = FALSE)
  }
  path <- file.path(pkg$src_path, "vignettes", "articles", "roadmap.Rmd")
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(
    c(
      "---",
      "title: Roadmap",
      "---",
      "",
      "```{r, echo=FALSE, results='asis'}",
      "pkgdownconfig::roadmap()",
      "```"
    ),
    path
  )
  invisible(path)
}

#' Markdown for one milestone
#'
#' @param issues The issues of a single milestone, in display order.
#' @param config The `roadmap` section of the merged pkgdown config.
#' @return A character vector of markdown lines.
#' @noRd
roadmap_milestone <- function(issues, config) {
  milestone <- issues[[1]]$milestone
  override <- config$overrides$milestones[[as.character(milestone$number)]]
  c(
    paste("##", override$title %||% milestone$title),
    "",
    trimws(override$description %||% milestone$description),
    "",
    "::::: {.rm-cards}",
    unlist(lapply(issues, roadmap_card, config$overrides$issues)),
    ":::::",
    ""
  )
}

#' Whether an issue is excluded from the roadmap
#'
#' @param issue An issue as returned by the GitHub API.
#' @param exclude The `exclude` section of the roadmap config.
#' @return `TRUE` or `FALSE`.
#' @noRd
roadmap_excluded <- function(issue, exclude) {
  labels <- vapply(issue$labels, `[[`, "", "name")
  patterns <- utils::glob2rx(unlist(exclude$labels))
  as.character(issue$number) %in% unlist(exclude$issues) ||
    any(vapply(patterns, function(p) any(grepl(p, labels)), NA))
}

#' Markdown for one issue card
#'
#' @param issue An issue as returned by the GitHub API.
#' @param overrides The `overrides.issues` section of the roadmap config.
#' @return A character vector of markdown lines.
#' @noRd
roadmap_card <- function(issue, overrides) {
  closed <- issue$state == "closed"
  c(
    if (closed) ":::: {.rm-card .rm-closed}" else ":::: {.rm-card}",
    "",
    sprintf(
      "#### [%s%s](%s)",
      if (closed) "✓ " else "",
      issue$title,
      issue$html_url
    ),
    "",
    trimws(overrides[[as.character(issue$number)]]$description),
    "",
    "::::",
    ""
  )
}

#' Fall back to a default when `x` is `NULL`
#'
#' @param x A value.
#' @param y The default.
#' @return `x` if not `NULL`, otherwise `y`.
#' @noRd
`%||%` <- function(x, y) if (is.null(x)) y else x
