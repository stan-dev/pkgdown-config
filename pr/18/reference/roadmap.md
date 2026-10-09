# Print the roadmap

Renders the issues of the open GitHub milestones of the package as
pandoc markdown, one section per milestone. This is the body of the
article written by
[`use_roadmap()`](https://mc-stan.org/pkgdown-config/pr/18/reference/use_roadmap.md).

## Usage

``` r
roadmap(pkg = "../..")
```

## Arguments

- pkg:

  Path to the package, or a pkgdown object from
  [`pkgdown::as_pkgdown()`](https://pkgdown.r-lib.org/reference/as_pkgdown.html).
  The default is two levels up, which is the working directory pkgdown
  renders articles from.

## Value

`NULL`, invisibly. Called for its printed output.
