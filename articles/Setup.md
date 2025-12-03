# Setup

## General Setup

If you haven’t started a `pkgdown` site yet, initialize it.

``` r
usethis::use_pkgdown()
```

In `./_pkgdown.yml` add the contributed package:

``` yaml
template:
  package: pkgdownconfig
```

Optional but highly recommended is to set development mode to auto and
to build the site in root, like so:

``` yaml
destination: "."

development:
  mode: auto
```

Point to this repository in `DESCRIPTION` to download the theme
automatically.

``` yaml
Config/Needs/website: stan-dev/pkgdown-config
```

Optionally, you should be able to pin a specific version of the template
with a tag or commit:

``` yaml
Config/Needs/website: stan-dev/pkgdown-config@v1.0.1

Config/Needs/website: stan-dev/pkgdown-config@COMMITHASH
```

For local development, you need to install the package before you can
build the site:

``` r
pak::pak("stan-dev/pkgdown-config")
pkgdown::build_site()
```

If you’re getting an error about dependency resolution when using a
GitHub Action to automatically build your pkgdown site, remove the
`Config/Needs/website:` line from DESCRIPTION and add use the R
dependencies step like [here](NA):

``` yaml
      - uses: r-lib/actions/setup-r-dependencies@v2
        with:
          extra-packages: any::pkgdown, local::., stan-dev/pkgdown-config
```

By default, the theme has a navbar item which has other Stan R
packages–this is not smart and won’t automatically drop the package
you’re using the theme in. If you don’t want this, you should override
that list in `_pkgdown.yml`. This example is taken from `loo`’s setup

``` yaml
navbar:
  title: "loo"

  structure:
    left: [home, vignettes, functions, news, pkgs, stan]
    right: [search, bluesky, forum, github, lightswitch]

  components:
    pkgs:
      text: Other Packages
      menu:
        - text: bayesplot
          href: https://mc-stan.org/bayesplot
        - text: cmdstanr
          href: https://mc-stan.org/cmdstanr
        - text: posterior
          href: https://mc-stan.org/posterior
        - text: projpred
          href: https://mc-stan.org/projpred
        - text: rstan
          href: https://mc-stan.org/rstan
        - text: rstanarm
          href: https://mc-stan.org/rstanarm
        - text: rstantools
          href: https://mc-stan.org/rstantools
        - text: shinystan
          href: https://mc-stan.org/shinystan
```

## Example (`shinystan`)

Put together, here’s what a reasonable YAML looks like (truncated, taken
from `shinystan`):

``` yaml
url: https://mc-stan.org/shinystan

destination: "."

development:
  mode: auto

template:
  package: pkgdownconfig

navbar:
  title: "shinystan"

  structure:
    left: [home, vignettes, functions, news, pkgs, stan]
    right: [search, bluesky, forum, github, lightswitch]

  components:
    pkgs:
      text: Other Packages
      menu:
        - text: bayesplot
          href: https://mc-stan.org/bayesplot
        - text: cmdstanr
          href: https://mc-stan.org/cmdstanr
        - text: "loo"
          href: https://mc-stan.org/loo
        - text: posterior
          href: https://mc-stan.org/posterior
        - text: projpred
          href: https://mc-stan.org/projpred
        - text: rstan
          href: https://mc-stan.org/rstan
        - text: rstanarm
          href: https://mc-stan.org/rstanarm
        - text: rstantools
          href: https://mc-stan.org/rstantools

# now you can add articles, references, etc.
```

## Common Issues

If for some reason the favicons don’t get copied over, check if you are
defining favicons in `pkgdown/favicons`. In most cases you can delete
everything in that folder–just delete the logo and favicons if you are
worried. The template will hook in the correct favicon and logo. If its
not working, download
[logo.svg](https://github.com/stan-dev/logos/blob/master/logo.svg) to
`/man/figures/logo.svg` and run
[`pkgdown::build_favicons()`](https://pkgdown.r-lib.org/reference/build_favicons.html)
once to build the favicons.

If you want the hex in your README (or if it isn’t working), make sure
to edit the `README.MD` or however you generate it. You can take a look
at this package’s to get an idea of what you need to do (repeated
below):

``` md
# pkgdownConfig <a href="https://mc-stan.org/pkgdown-config"><img src="man/figures/logo.svg" align="right" height="139" alt="pkgdownConfig website" /></a>
```

For any further concerns/help/anything, open an issue and/or ping
`@Visruth` on the Stan Slack.
