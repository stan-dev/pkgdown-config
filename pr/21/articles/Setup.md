# Setup

## General Setup

If you haven’t started a `pkgdown` site yet, initialize it.

``` r

usethis::use_pkgdown()
```

In `_pkgdown.yml` add the template package:

``` yaml
template:
  package: pkgdownconfig
```

Optional but highly recommended is to set [development
mode](https://pkgdown.r-lib.org/reference/build_site.html#setting-development-mode)
to auto. This will build a dev version of the site at `/dev` (see
[`loo`](https://mc-stan.org/loo/dev/) for example). Whether `pkgdown`
treats a build as a development or release site is controlled by the
version in DESCRIPTION (see pkgdown docs linked above).

``` yaml
development:
  mode: auto
```

Point to this repository in `DESCRIPTION` to download the theme
automatically.

``` yaml
Config/Needs/website: stan-dev/pkgdown-config
```

Optionally, you can pin a specific version of the template with a tag or
commit, but this isn’t reocmmended.

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
GitHub Action (GHA) to automatically build your pkgdown site, remove the
`Config/Needs/website:` line from DESCRIPTION and add the pacakge to
this GHA step:

``` yaml
      - uses: r-lib/actions/setup-r-dependencies@v2
        with:
          extra-packages: any::pkgdown, local::., stan-dev/pkgdown-config
```

## Example

Put together, here’s what a typical YAML might look like:

``` yaml
url: https://mc-stan.org/PKGNAME

destination: "."

development:
  mode: auto

template:
  package: pkgdownconfig

articles:
  - title: "Article 1"
    ...

reference:
  - title: "Function Group 1"
    ...
```

## GHA

You can run
[`pkgdownconfig::use_pkgdown_gha()`](https://mc-stan.org/pkgdown-config/pr/21/reference/use_pkgdown_gha.md)
to copy in a good default template which you should edit as needed. You
could also copy [this package’s
GHA](https://github.com/stan-dev/pkgdown-config/blob/main/.github/workflows/pkgdown.yaml)
directly to `.github/workflows/pkgdown.yaml`. It builds `main` to `/dev`
and releases to the root. Pull requests with the `build-website` label
get a preview at `/pr/<number>` and a comment with its URL and commit.
Forks can’t deploy previews, so their PRs are skipped.

## Common Issues

The navbar logo falls back to the Stan logo shipped with the template,
so a package without `man/figures/logo.svg` still builds; a logo in your
package takes precedence.

If you want the hex in your README (or if it isn’t working), make sure
to edit the `README.md` or however you generate it. You can take a look
at this package’s to get an idea of what you need to do (repeated
below):

``` md
# pkgdownConfig <a href="https://mc-stan.org/pkgdown-config"><img src="man/figures/logo.svg" align="right" height="139" alt="pkgdownConfig website" /></a>
```

For any further concerns/help/anything, open an issue and/or ping
`@Visruth` on the Stan Slack.
