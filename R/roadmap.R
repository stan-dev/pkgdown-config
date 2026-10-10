#' Roadmap markdown
#'
#' Renders the roadmap as markdown: an introduction, a timeline of the latest
#' release and the open milestones, one section per milestone with its issues,
#' and a closing section.
#'
#' @param pkg A pkgdown object from [pkgdown::as_pkgdown()].
#' @return A character vector of markdown lines.
#' @noRd
roadmap_markdown <- function(pkg) {
  config <- pkg$meta$roadmap
  repo <- gsub("^https://github.com/|/$", "", pkg$repo$url$home)
  fill <- function(text) {
    text <- gsub("{package}", pkg$package, text, fixed = TRUE)
    gsub("{repo}", repo, text, fixed = TRUE)
  }

  issues <- gh::gh(
    "/repos/{repo}/issues",
    repo = repo,
    milestone = "*",
    state = "all",
    .limit = Inf
  )
  excluded_labels <- utils::glob2rx(unlist(config$exclude$labels))
  excluded_issues <- unlist(config$exclude$issues)
  issues <- Filter(
    function(issue) {
      labels <- vapply(issue$labels, `[[`, "", "name")
      is.null(issue$pull_request) &&
        issue$milestone$state == "open" &&
        !(as.character(issue$number) %in% excluded_issues) &&
        !any(vapply(excluded_labels, function(p) any(grepl(p, labels)), NA))
    },
    issues
  )

  milestones <- split(
    issues,
    vapply(issues, function(issue) issue$milestone$number, numeric(1))
  )
  titles <- vapply(milestones, function(m) m[[1]]$milestone$title, "")
  versions <- numeric_version(sub("^v", "", titles), strict = FALSE)
  release <- tryCatch(
    gh::gh("/repos/{repo}/releases/latest", repo = repo),
    http_error_404 = function(e) NULL
  )

  c(
    sprintf("[Last updated: %s]{.rm-updated}", format(Sys.Date(), "%B %Y")),
    "",
    fill(config$intro),
    if (any(!is.na(versions))) {
      roadmap_timeline(
        milestones[!is.na(versions)][order(versions[!is.na(versions)])],
        release,
        repo
      )
    },
    unname(unlist(lapply(
      milestones[order(is.na(versions), versions)],
      roadmap_milestone,
      config
    ))),
    fill(config$outro)
  )
}

#' Markdown for the release timeline
#'
#' @param milestones The issues grouped by milestone, in ascending version
#'   order.
#' @param release The latest release from the GitHub API, or `NULL`.
#' @param repo The repository as `owner/name`.
#' @return A character vector of markdown lines.
#' @noRd
roadmap_timeline <- function(milestones, release, repo) {
  released <- if (!is.null(release)) {
    list(roadmap_station(
      release$tag_name,
      format(as.Date(substr(release$published_at, 1, 10)), "Released %B %Y"),
      "What's new",
      "../news/index.html",
      "rm-past"
    ))
  }
  upcoming <- lapply(seq_along(milestones), function(i) {
    milestone <- milestones[[i]][[1]]$milestone
    roadmap_station(
      milestone$title,
      if (i == 1) "Next release" else "Upcoming release",
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
  stations <- c(released, upcoming, beyond)

  c(
    "",
    sprintf(
      "::::: {.rm-timeline style=\"--rm-stations:%d\"}",
      length(stations)
    ),
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
  classes <- paste0(".", c("rm-station", class), collapse = " ")
  c(
    sprintf(":::: {%s}", classes),
    sprintf("[%s]{.rm-station-title}", title),
    "",
    sprintf("[%s]{.rm-station-sub}", subtitle),
    "",
    sprintf("[%s](%s){.rm-station-sub}", label, href),
    "::::",
    ""
  )
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
  position <- vapply(cards, function(card) card$order, numeric(1))

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
    paste(
      "####",
      if (is.null(card$url)) title else sprintf("[%s](%s)", title, card$url)
    ),
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
