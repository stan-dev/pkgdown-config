test_that("the repository workflow matches the one shipped to consumers", {
  repository <- test_path("..", "..", ".github", "workflows", "pkgdown.yaml")
  skip_if_not(file.exists(repository))
  shipped <- system.file("workflows", "pkgdown.yaml", package = "pkgdownconfig")

  expect_identical(readLines(repository), readLines(shipped))
})

test_that("use_pkgdown_gha() copies the workflow into the package", {
  pkg <- tempfile()

  use_pkgdown_gha(pkg)

  expect_true(file.exists(file.path(pkg, ".github", "workflows", "pkgdown.yaml")))
})
