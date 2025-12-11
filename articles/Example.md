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

## “Likelihood” from [`rstanarm`](https://mc-stan.org/rstanarm/articles/lm#likelihood)

The likelihood for one observation under a linear model can be written
as a conditionally normal PDF \\\frac{1}{\sigma\_{\epsilon} \sqrt{2
\pi}} e^{-\frac{1}{2} \left(\frac{y -
\mu}{\sigma\_{\epsilon}}\right)^2},\\ where \\\mu = \alpha +
\mathbf{x}^\top \boldsymbol{\beta}\\ is a linear predictor and
\\\sigma\_{\epsilon}\\ is the standard deviation of the error in
predicting the outcome, \\y\\. The likelihood of the entire sample is
the product of \\N\\ individual likelihood contributions.

It is well-known that the likelihood of the sample is maximized when the
sum-of-squared residuals is minimized, which occurs when \\
\widehat{\boldsymbol{\beta}} = \left(\mathbf{X}^\top
\mathbf{X}\right)^{-1} \mathbf{X}^\top \mathbf{y}, \\ \\
\widehat{\alpha} = \overline{y} - \overline{\mathbf{x}}^\top
\widehat{\boldsymbol{\beta}}, \\ \\ \widehat{\sigma}\_{\epsilon}^2 =
\frac{\left(\mathbf{y} - \widehat{\alpha} - \mathbf{X} \widehat{
\boldsymbol{\beta}}\right)^\top \left(\mathbf{y} - \widehat{\alpha} -
\mathbf{X} \widehat{ \boldsymbol{\beta}}\right)}{N},\\ where
\\\overline{\mathbf{x}}\\ is a vector that contains the sample means of
the \\K\\ predictors, \\\mathbf{X}\\ is a \\N \times K\\ matrix of
*centered* predictors, \\\mathbf{y}\\ is a \\N\\-vector of outcomes and
\\\overline{y}\\ is the sample mean of the outcome.

Bold symbols should render, i.e. this should render properly:
\\\boldsymbol{\beta}\\ vs \\\beta\\ and not error out.
