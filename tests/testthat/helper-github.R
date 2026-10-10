fake_milestone <- function(number, title, state = "open") {
  list(
    number = number,
    title = title,
    state = state,
    description = paste(title, "description"),
    html_url = paste0("https://github.com/stan-dev/fake/milestone/", number)
  )
}

fake_issue <- function(
  number,
  title,
  milestone,
  state = "open",
  labels = character(),
  pull_request = FALSE
) {
  list(
    number = number,
    title = title,
    html_url = paste0("https://github.com/stan-dev/fake/issues/", number),
    state = state,
    labels = lapply(labels, function(label) list(name = label)),
    pull_request = if (pull_request) list(url = "https://example.org"),
    milestone = milestone
  )
}

fake_gh <- function(issues, release = list(tag_name = "v2.10.1")) {
  function(endpoint, ...) {
    if (grepl("releases", endpoint)) release else issues
  }
}
