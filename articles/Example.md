# Test Vignette

``` r
knitr::opts_chunk$set(
  eval = identical(Sys.getenv("NOT_CRAN"), "true")
)
```

This is a testing vignette to make sure the conditional evaluation
works.

``` r
print("Starting expensive computation")
```

    ## [1] "Starting expensive computation"

``` r
Sys.sleep(5)
print("Done!")
```

    ## [1] "Done!"

Above should print two lines.
