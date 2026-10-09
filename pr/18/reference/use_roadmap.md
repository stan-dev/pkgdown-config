# Write the roadmap article

Writes `vignettes/articles/roadmap.Rmd`, which calls
[`roadmap()`](https://mc-stan.org/pkgdown-config/pr/18/reference/roadmap.md),
when `roadmap: enabled: true` is set in `_pkgdown.yml`.

## Usage

``` r
use_roadmap(pkg = ".")
```

## Arguments

- pkg:

  Path to the package, or a pkgdown object from
  [`pkgdown::as_pkgdown()`](https://pkgdown.r-lib.org/reference/as_pkgdown.html).

## Value

The path of the article, invisibly, or `NULL` invisibly if the roadmap
is disabled.
