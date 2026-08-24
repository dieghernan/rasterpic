# Compute the aspect ratio of spatial input

Compute the aspect ratio as width divided by height or columns divided
by rows.

## Usage

``` r
asp_ratio(x)
```

## Arguments

- x:

  A `SpatRaster`, `sf` or `sfc` object or a numeric vector of length 4
  with coordinates `c(xmin, ymin, xmax, ymax)`, as created by
  [`sf::st_bbox()`](https://r-spatial.github.io/sf/reference/st_bbox.html).

## Value

A numeric scalar giving the aspect ratio.

## See also

Other image geotagging tools:
[`rasterpic_img()`](https://dieghernan.github.io/rasterpic/reference/rasterpic_img.md)

## Examples

``` r
# \donttest{
library(terra)
#> terra 1.9.46

x <- rast(system.file("tiff/elev.tiff", package = "rasterpic"))
plot(x)

asp_ratio(x)
#> [1] 2.34375
# }
```
