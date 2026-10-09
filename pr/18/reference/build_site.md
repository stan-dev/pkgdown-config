# Build a Stan pkgdown site

Writes the roadmap article and adds the roadmap to the navbar when
`roadmap: enabled: true` is set, then calls
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
  [`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html),
  merged over the navbar override from
  [`roadmap_override()`](https://mc-stan.org/pkgdown-config/pr/18/reference/roadmap_override.md).

## Value

The result of
[`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html),
invisibly.
