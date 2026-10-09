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

## Roadmap

Opt in to a roadmap page built from your open GitHub milestones and
issues (PRs, closed milestones and issues labelled `internal*`,
`wontfix` or `invalid` are skipped; closed issues go last).

``` yaml
roadmap:
  enabled: true
```

Customize with `roadmap.overrides.milestones` /
`roadmap.overrides.issues` (keyed by milestone/issue number, with
`title` and `description`) and `roadmap.exclude.labels` /
`roadmap.exclude.issues`. See the defaults in [this package’s
config](https://github.com/stan-dev/pkgdown-config/blob/main/inst/pkgdown/_pkgdown.yml).

The GHA generates the roadmap article (`vignettes/articles/roadmap.Rmd`)
and adds the navbar link for you. The article is rewritten on every
build, so add it to `.gitignore`. For local builds use
[`pkgdownconfig::build_site()`](https://mc-stan.org/pkgdown-config/pr/18/reference/build_site.md)
in place of
[`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html);
it does the same and forwards all arguments.

## GHA

You can use the default GHA, or you can run
[`pkgdownconfig::use_pkgdown_gha()`](https://mc-stan.org/pkgdown-config/pr/18/reference/use_pkgdown_gha.md)
to copy [this package’s
GHA](https://github.com/stan-dev/pkgdown-config/blob/main/inst/workflows/pkgdown.yaml).
This GHA deploys `pkgdown` sites on (non-fork[^1]) PRs to unique URLs
(`/prs/$PR-NUMBER`). This means that PRs would have preview sites,
`/dev` would track `main`, and the main site would track releases.

You could also configure the `pkgdown` GHA to only run when [vignettes
are
modified](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow#using-filters-to-target-specific-paths-for-pull-request-or-push-events),
or only have the `workflow_dispatch` trigger so that you can build PR’s
`pkgdown` sites as needed.

## Common Issues

If for some reason the new favicons don’t get copied over, check if you
are defining favicons in `pkgdown/favicons`. In most cases you can
delete everything in that folder–just delete the logo and favicons if
you are worried. The template will hook in the correct favicon and logo.
If its not working, download
[logo.svg](https://github.com/stan-dev/logos/blob/master/logo.svg) to
`/man/figures/logo.svg` and run
[`pkgdown::build_favicons()`](https://pkgdown.r-lib.org/reference/build_favicons.html)
once to build the favicons.

If you want the hex in your README (or if it isn’t working), make sure
to edit the `README.md` or however you generate it. You can take a look
at this package’s to get an idea of what you need to do (repeated
below):

``` md
# pkgdownConfig <a href="https://mc-stan.org/pkgdown-config"><img src="man/figures/logo.svg" align="right" height="139" alt="pkgdownConfig website" /></a>
```

For any further concerns/help/anything, open an issue and/or ping
`@Visruth` on the Stan Slack.

[^1]: PRs from forks typically get a read-only `GITHUB_TOKEN` for
    security, so they wouldn’t be able to deploy the site.
