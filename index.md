

<!-- index.md is generated from index.qmd. Please edit that file -->

# rasterpic <a href="https://dieghernan.github.io/rasterpic/"><img src="man/figures/logo.png" alt="rasterpic website" align="right" height="139"/></a>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/rasterpic)](https://CRAN.R-project.org/package=rasterpic)
[![CRAN
results](https://badges.cranchecks.info/worst/rasterpic.svg)](https://cran.r-project.org/web/checks/check_results_rasterpic.html)
[![R-CMD-check](https://github.com/dieghernan/rasterpic/actions/workflows/check-full.yaml/badge.svg)](https://github.com/dieghernan/rasterpic/actions/workflows/check-full.yaml)
[![codecov](https://codecov.io/gh/dieghernan/rasterpic/branch/main/graph/badge.svg?token=jSZ4RIsj91)](https://app.codecov.io/gh/dieghernan/rasterpic)
[![r-universe](https://dieghernan.r-universe.dev/badges/rasterpic)](https://dieghernan.r-universe.dev/rasterpic)
[![CodeFactor](https://www.codefactor.io/repository/github/dieghernan/rasterpic/badge)](https://www.codefactor.io/repository/github/dieghernan/rasterpic)
[![DOI](https://img.shields.io/badge/DOI-10.32614/CRAN.package.rasterpic-blue)](https://doi.org/10.32614/CRAN.package.rasterpic)
[![Project Status: Inactive – The project has reached a stable, usable
state but is no longer being actively developed; support/maintenance
will be provided as time
allows.](https://www.repostatus.org/badges/latest/inactive.svg)](https://www.repostatus.org/#inactive)
[![status](https://tinyverse.netlify.app/status/rasterpic)](https://CRAN.R-project.org/package=rasterpic)

<!-- badges: end -->

**rasterpic** is a tiny package with a single goal: geotag an image and
return a **terra** `SpatRaster` object using coordinates from supported
spatial input classes (see `?terra::SpatRaster`).

<div class="callout callout-style-default callout-note callout-titled">
<div class="callout-header d-flex align-content-center">
<div class="callout-icon-container"><i class="callout-icon"></i></div>
<div class="callout-title-container flex-fill">Note</div></div>
<div class="callout-body-container callout-body">

This package is stable and maintained on a best-effort basis. I
currently prioritize CRAN compatibility, bug fixes and regressions over
new features.

</div>
</div>

## Installation

<div class="pkgdown-release">

Install **rasterpic** from
[**CRAN**](https://CRAN.R-project.org/package=rasterpic):

``` r
install.packages("rasterpic")
```

</div>

<div class="pkgdown-devel">

Check the documentation for the development version at
<https://dieghernan.github.io/rasterpic/dev/>.

You can install the development version of **rasterpic** with:

``` r
# install.packages("pak")
pak::pak("dieghernan/rasterpic")
```

Alternatively, you can install **rasterpic** using the
[r-universe](https://dieghernan.r-universe.dev/rasterpic):

``` r
# Install rasterpic in R.
install.packages(
  "rasterpic",
  repos = c(
    "https://dieghernan.r-universe.dev",
    "https://cloud.r-project.org"
  )
)
```

</div>

## Example

`rasterpic_img()` can geotag an image from several spatial input
classes:

- **sf** classes: `sf`, `sfc`, `sfg` and `bbox`.
- **terra** classes: `SpatRaster`, `SpatVector` and `SpatExtent`.
- **stars** class: `stars`.
- A numeric coordinate vector of the form `c(xmin, ymin, xmax, ymax)`.

`rasterpic_img()` is an S3 generic. Methods for extent-like inputs use
the object extent, and vector methods can also mask the image to the
object shape.

This example uses an `sf` object:

``` r
library(rasterpic)
library(sf)
library(terra)

# Use the flag of the United Kingdom.
img <- system.file("img/UK_flag.png", package = "rasterpic")
uk <- read_sf(system.file("gpkg/UK.gpkg", package = "rasterpic"))

class(uk)
#> [1] "sf"         "tbl_df"     "tbl"        "data.frame"

# Geotag the image.
uk_flag <- rasterpic_img(uk, img)

uk_flag
#> class       : SpatRaster
#> size        : 400, 800, 3  (nrow, ncol, nlyr)
#> resolution  : 5398.319, 5398.319  (x, y)
#> extent      : -2542183, 1776472, 6430573, 8589900  (xmin, xmax, ymin, ymax)
#> coord. ref. : WGS 84 / Pseudo-Mercator (EPSG:3857)
#> source(s)   : memory
#> colors rgb  : 1, 2, 3
#> names       :   r,   g,   b
#> min values  :   0,  14,  35
#> max values  : 255, 255, 255

# Plot with ggplot2 and tidyterra.
library(tidyterra)
library(ggplot2)

autoplot(uk_flag) +
  geom_sf(data = uk, color = alpha("blue", 0.5))
```

<img src="man/figures/README-example-basic-1.png" style="width:100.0%"
alt="Example using rasterpic with the UK flag." />

You can also adjust the expansion, alignment, cropping and masking
options:

``` r
# Align, crop and mask the image.
uk_flag2 <- rasterpic_img(uk, img, halign = 0.2, crop = TRUE, mask = TRUE)

autoplot(uk_flag2) +
  geom_sf(data = uk, fill = NA)
```

<img src="man/figures/README-align-crop-mask-1.png" style="width:100.0%"
alt="Example using rasterpic with the UK flag cropped to the shape." />

## Supported image formats

**rasterpic** can read the following image formats:

- `png` files.
- `jpeg`/`jpg` files.
- `tiff`/`tif` files.

## Citation

<p>

Hernangómez D (2026). <em>rasterpic: Convert Digital Images to Spatially
Referenced SpatRaster Objects</em>.
<a href="https://doi.org/10.32614/CRAN.package.rasterpic">doi:10.32614/CRAN.package.rasterpic</a>.
<a href="https://dieghernan.github.io/rasterpic/">https://dieghernan.github.io/rasterpic/</a>.
</p>

A BibTeX entry for LaTeX users is:

    @Manual{R-rasterpic,
      title = {{rasterpic}: Convert Digital Images to Spatially Referenced {SpatRaster} Objects},
      doi = {10.32614/CRAN.package.rasterpic},
      author = {Diego Hernangómez},
      year = {2026},
      version = {0.5.1},
      url = {https://dieghernan.github.io/rasterpic/},
      abstract = {Convert digital images to spatially referenced SpatRaster objects, as defined by the terra package, using coordinates from supported spatial input classes. Supported inputs include numeric coordinate vectors and objects from the sf, terra and stars packages. The main function is an S3 generic, allowing other packages to extend support to additional spatial classes.},
    }
