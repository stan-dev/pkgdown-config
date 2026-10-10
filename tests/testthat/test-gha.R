test_that("gha_override() points a pull request preview at its own URL, unindexed", {
  pkg <- pkgdown::as_pkgdown(fake_package(c("url: https://example.org")))

  site <- pkgdown::as_pkgdown(
    fake_package(c("url: https://example.org")),
    override = gha_override(pkg, "18")
  )

  expect_equal(site$meta$url, "https://example.org/pr/18")
  expect_true(site$meta$template$params$noindex)
})

test_that("gha_override() leaves the site alone without a pull request", {
  pkg <- pkgdown::as_pkgdown(fake_package(c("url: https://example.org")))

  expect_equal(gha_override(pkg, ""), list())
})
