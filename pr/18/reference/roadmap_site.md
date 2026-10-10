# Add the roadmap to a pkgdown site

Adds `roadmap` to the navbar after `news`, and hides the roadmap article
from the Articles index while keeping it built. Call it after
[`use_roadmap()`](https://mc-stan.org/pkgdown-config/pr/18/reference/use_roadmap.md)
so the article is parsed. Used by
[`build_site()`](https://mc-stan.org/pkgdown-config/pr/18/reference/build_site.md)
and the GitHub Action.

## Usage

``` r
roadmap_site(pkg = ".")
```

## Arguments

- pkg:

  Path to the package, or a pkgdown object from
  [`pkgdown::as_pkgdown()`](https://pkgdown.r-lib.org/reference/as_pkgdown.html).

## Value

A pkgdown object, unchanged when the roadmap is disabled.
