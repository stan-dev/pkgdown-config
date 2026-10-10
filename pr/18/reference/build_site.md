# Build a Stan pkgdown site

Adds the roadmap when `roadmap: enabled: true` is set, then calls
[`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html)
with all other arguments.

## Usage

``` r
build_site(pkg = ".", ..., override = list())
```

## Arguments

- pkg:

  Path to package.

- ...:

  Passed on to
  [`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html).

- override:

  Passed on to
  [`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html).

## Value

The result of
[`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html),
invisibly.
