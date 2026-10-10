test_that("build_gha_site() builds a pull request preview under its own URL, unindexed", {
  dir <- fake_package(c("url: https://example.org"))
  withr::local_dir(dir)
  local_mocked_bindings(
    build_site_github_pages = function(...) list(...),
    .package = "pkgdown"
  )

  args <- build_gha_site("18")

  expect_equal(args$override$url, "https://example.org/pr/18")
  expect_true(args$override$template$params$noindex)
})

test_that("build_gha_site() adds no overrides without a pull request", {
  dir <- fake_package(c("url: https://example.org"))
  withr::local_dir(dir)
  local_mocked_bindings(
    build_site_github_pages = function(...) list(...),
    .package = "pkgdown"
  )

  expect_equal(build_gha_site("")$override, list())
})
