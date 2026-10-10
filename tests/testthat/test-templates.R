test_that("the navbar template differs from pkgdown's only by the logo", {
  normalise <- function(x) gsub("[[:space:]]", "", paste(x, collapse = ""))
  ours <- readLines(test_path("..", "..", "inst", "pkgdown", "templates", "navbar.html"), warn = FALSE)
  upstream <- readLines(system.file("BS5", "templates", "navbar.html", package = "pkgdown"), warn = FALSE)

  ours <- gsub("<img[^>]*stan-logo[^>]*>", "", normalise(ours))

  expect_equal(normalise(ours), normalise(upstream))
})
