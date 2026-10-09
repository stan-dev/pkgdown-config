# Navbar override for the roadmap

Inserts `roadmap` into the navbar after `news` when the roadmap is
enabled. Used by
[`build_site()`](https://mc-stan.org/pkgdown-config/pr/18/reference/build_site.md)
and the GitHub Action.

## Usage

``` r
roadmap_override(pkg = ".")
```

## Arguments

- pkg:

  Path to the package, or a pkgdown object from
  [`pkgdown::as_pkgdown()`](https://pkgdown.r-lib.org/reference/as_pkgdown.html).

## Value

A pkgdown override list, empty when the roadmap is disabled.
