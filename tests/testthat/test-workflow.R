test_that("the repository workflow matches the one shipped to consumers", {
  repository <- test_path("..", "..", ".github", "workflows", "pkgdown.yaml")
  skip_if_not(file.exists(repository))
  shipped <- system.file("workflows", "pkgdown.yaml", package = "pkgdownconfig")

  expect_identical(readLines(repository), readLines(shipped))
})
