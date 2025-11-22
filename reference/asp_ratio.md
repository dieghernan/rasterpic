# Compute aspect ratio of an object

Helper function. Ratio is computed as width/height (or col/rows).

## Usage

``` r
asp_ratio(x)
```

## Arguments

- x:

  A `SpatRaster` object, an `sf/sfc` object or a numeric vector of
  length 4 with coordinates c(`xmin`, `ymin`, `xmax`, `ymax`), as
  created by
  [`sf::st_bbox()`](https://r-spatial.github.io/sf/reference/st_bbox.html).

## Value

The aspect ratio

## Examples

``` r
# \donttest{
library(terra)
#> terra 1.8.80

x <- rast(system.file("tiff/elev.tiff", package = "rasterpic"))
plot(x)

asp_ratio(x)
#> [1] 2.34375
# }
```
