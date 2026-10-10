test_that("use_roadmap() writes the article only when enabled", {
  disabled <- fake_package(c("roadmap:", "  enabled: false"))
  enabled <- fake_package(c("roadmap:", "  enabled: true", "  format: rmd"))

  use_roadmap(disabled)
  use_roadmap(enabled)

  expect_false(file.exists(article_path(disabled)))
  expect_true(file.exists(article_path(enabled)))
})

test_that("use_roadmap() rejects formats other than rmd", {
  pkg <- fake_package(c("roadmap:", "  enabled: true", "  format: qmd"))

  expect_error(use_roadmap(pkg), "rmd")
})

test_that("roadmap_site() adds the navbar link only when enabled", {
  navbar <- c("navbar:", "  structure:", "    left: [home, news, stan]")
  enabled <- fake_package(c(navbar, "roadmap:", "  enabled: true", "  format: rmd"))
  disabled <- fake_package(c(navbar, "roadmap:", "  enabled: false"))
  use_roadmap(enabled)

  expect_equal(
    roadmap_site(enabled)$meta$navbar$structure$left,
    c("home", "news", "roadmap", "stan")
  )
  expect_equal(
    roadmap_site(disabled)$meta$navbar$structure$left,
    c("home", "news", "stan")
  )
})
