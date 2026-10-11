# Build the GitHub Pages site

Build the GitHub Pages site

## Usage

``` r
build_gha_site(pr_number = Sys.getenv("PR_NUMBER"), ...)
```

## Arguments

- pr_number:

  Pull request number. Empty builds the main site.

- ...:

  Passed on to
  [`pkgdown::build_site_github_pages()`](https://pkgdown.r-lib.org/reference/build_site_github_pages.html),
  overriding its defaults.
