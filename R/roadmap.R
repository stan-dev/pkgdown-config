#' Print the roadmap
#'
#' Renders the roadmap as pandoc markdown: an introduction, a timeline of the
#' latest release and the open milestones, one section per milestone with its
#' issues, and a closing section. Milestones are ordered by version, next
#' release first, and the text comes from the `roadmap` section of
#' `_pkgdown.yml`. This is the body of the article written by [use_roadmap()].
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
  milestones <- split(
    issues,
    vapply(issues, function(issue) issue$milestone$number, 0L)
  )
  titles <- vapply(milestones, function(m) m[[1]]$milestone$title, "")
  versions <- numeric_version(sub("^v", "", titles), strict = FALSE)
  versioned <- !is.na(versions)
  release <- tryCatch(
    gh::gh("/repos/{repo}/releases/latest", repo = repo),
    error = function(e) NULL
  )

  fill <- function(text) roadmap_fill(text, pkg$package, repo)
  cat(
    sprintf("[Last updated: %s]{.rm-updated}", format(Sys.Date(), "%B %Y")),
    "",
    fill(config$intro),
    if (any(versioned)) {
      roadmap_timeline(
        milestones[versioned][order(versions[versioned])],
        release,
        repo
      )
    },
    unlist(lapply(
      milestones[order(is.na(versions), versions)],
      roadmap_milestone,
      config
    )),
    fill(config$outro),
    sep = "\n"
  )
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
      "```{r, echo=FALSE, message=FALSE, results='asis'}",
      "pkgdownconfig::roadmap()",
      "```"
    ),
    path
  )
  invisible(path)
}

#' Substitute the package placeholders in roadmap text
#'
#' @param text Text from the roadmap config.
#' @param package The package name, for `{package}`.
#' @param repo The repository as `owner/name`, for `{repo}`.
#' @return `text` with the placeholders replaced.
#' @noRd
roadmap_fill <- function(text, package, repo) {
  text <- gsub("{package}", package, text, fixed = TRUE)
  gsub("{repo}", repo, text, fixed = TRUE)
}

#' Markdown for the release timeline
#'
#' @param milestones The issues grouped by milestone, in ascending version
#'   order.
#' @param release The latest release as returned by the GitHub API, or `NULL`.
#' @param repo The repository as `owner/name`.
#' @return A character vector of markdown lines.
#' @noRd
roadmap_timeline <- function(milestones, release, repo) {
  current <- if (!is.null(release)) {
    numeric_version(sub("^v", "", release$tag_name), strict = FALSE)
  }
  released <- if (!is.null(release)) {
    list(roadmap_station(
      release$tag_name,
      format(as.Date(substr(release$published_at, 1, 10)), "Released %B %Y"),
      "What's new",
      "../news/index.html",
      "rm-past"
    ))
  }
  upcoming <- lapply(milestones, function(m) {
    milestone <- m[[1]]$milestone
    version <- numeric_version(sub("^v", "", milestone$title), strict = FALSE)
    roadmap_station(
      milestone$title,
      roadmap_kind(version, current),
      "Milestone",
      milestone$html_url
    )
  })
  beyond <- list(roadmap_station(
    paste("Beyond", milestones[[length(milestones)]][[1]]$milestone$title),
    "Planned improvements & your ideas are welcome",
    "Open an issue",
    sprintf("https://github.com/%s/issues/new", repo)
  ))
  stations <- c(released, unname(upcoming), beyond)

  c(
    "",
    sprintf("::::: {.rm-timeline style=\"--rm-stations:%d\"}", length(stations)),
    unlist(stations),
    ":::::",
    ""
  )
}

#' Markdown for one timeline station
#'
#' @param title The station title.
#' @param subtitle The line below the title.
#' @param label The link text.
#' @param href The link target.
#' @param class Extra class for the station.
#' @return A character vector of markdown lines.
#' @noRd
roadmap_station <- function(title, subtitle, label, href, class = NULL) {
  c(
    paste0(":::: {", paste(c(".rm-station", class), collapse = " ."), "}"),
    sprintf("[%s]{.rm-station-title}", title),
    "",
    sprintf("[%s]{.rm-station-sub}", subtitle),
    "",
    sprintf("[%s](%s){.rm-station-sub}", label, href),
    "::::",
    ""
  )
}

#' Describe how a version follows the current release
#'
#' @param version The milestone version.
#' @param current The latest released version, or `NULL`.
#' @return `"Next major release"`, `"Next minor release"`,
#'   `"Next patch release"` or `"Upcoming release"`.
#' @noRd
roadmap_kind <- function(version, current) {
  if (is.null(current) || is.na(version) || is.na(current)) {
    return("Upcoming release")
  }
  next_version <- c(unlist(version), 0, 0)
  current <- c(unlist(current), 0, 0)
  if (next_version[1] > current[1]) {
    "Next major release"
  } else if (next_version[2] > current[2]) {
    "Next minor release"
  } else {
    "Next patch release"
  }
}

#' Markdown for one milestone
#'
#' Cards are the issues followed by the custom `cards` of the milestone
#' override, ordered by `order` (the issue number by default), closed last.
#'
#' @param issues The issues of a single milestone.
#' @param config The `roadmap` section of the merged pkgdown config.
#' @return A character vector of markdown lines.
#' @noRd
roadmap_milestone <- function(issues, config) {
  milestone <- issues[[1]]$milestone
  override <- config$overrides$milestones[[as.character(milestone$number)]]
  cards <- c(
    lapply(issues, function(issue) {
      card <- config$overrides$issues[[as.character(issue$number)]]
      list(
        title = card$title %||% issue$title,
        description = card$description,
        url = issue$html_url,
        closed = issue$state == "closed",
        order = card$order %||% issue$number
      )
    }),
    lapply(override$cards, function(card) {
      list(
        title = card$title,
        description = card$description,
        url = card$url,
        closed = FALSE,
        order = card$order %||% Inf
      )
    })
  )
  closed <- vapply(cards, function(card) card$closed, NA)
  position <- vapply(cards, function(card) card$order, 0)

  c(
    paste("##", override$title %||% milestone$title),
    "",
    trimws(override$description %||% milestone$description),
    "",
    "::::: {.rm-cards}",
    unlist(lapply(cards[order(closed, position)], roadmap_card)),
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

#' Markdown for one card
#'
#' @param card A list with `title`, `description`, `url` and `closed`.
#' @return A character vector of markdown lines.
#' @noRd
roadmap_card <- function(card) {
  title <- paste0(if (card$closed) "✓ ", card$title)
  c(
    if (card$closed) ":::: {.rm-card .rm-closed}" else ":::: {.rm-card}",
    "",
    paste("####", if (is.null(card$url)) title else sprintf("[%s](%s)", title, card$url)),
    "",
    trimws(card$description),
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
