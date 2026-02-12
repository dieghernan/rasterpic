# Convert an image to a geo-tagged `SpatRaster`

Geotags an image based on the coordinates of a given spatial object.

## Usage

``` r
rasterpic_img(
  x,
  img,
  halign = 0.5,
  valign = 0.5,
  expand = 0,
  crop = FALSE,
  mask = FALSE,
  inverse = FALSE,
  crs = NULL
)
```

## Arguments

- x:

  **R** object that may be:

  - An object created with [sf](https://CRAN.R-project.org/package=sf)
    of class [`sf`](https://r-spatial.github.io/sf/reference/sf.html),
    [`sfc`](https://r-spatial.github.io/sf/reference/sfc.html),
    [`sfg`](https://r-spatial.github.io/sf/reference/st.html) or
    [`bbox`](https://r-spatial.github.io/sf/reference/st_bbox.html)).

  - An object created with
    [terra](https://CRAN.R-project.org/package=terra) of class
    [`SpatRaster`](https://rspatial.github.io/terra/reference/rast.html),
    [`SpatVector`](https://rspatial.github.io/terra/reference/vect.html)
    or
    [`SpatExtent`](https://rspatial.github.io/terra/reference/ext.html).

  - A numeric vector of length 4 with the extent to be used for
    geotagging (i.e. `c(xmin, ymin, xmax, ymax)`).

- img:

  An image to be geotagged. It can be a local file or an online file
  (e.g. `"https://i.imgur.com/6yHmlwT.jpeg"`). The following image
  extensions are accepted:

  - `png`.

  - `jpeg/jpg`.

  - `tiff/tif`.

- halign, valign:

  Horizontal and vertical alignment of `img` with respect to `x`. They
  should be values between `0` and `1`:

  - `halign = 0, valign = 0` assumes that `x` should be in the bottom
    left corner of the `SpatRaster`.

  - `halign = 1, valign = 1` assumes that `x` should be in the top right
    corner of the `SpatRaster`.

  - The default `halign = .5, valign = .5` assumes that `x` is the
    center of `img`. See
    [`vignette("rasterpic", package = "rasterpic")`](https://dieghernan.github.io/rasterpic/dev/articles/rasterpic.md)
    for examples.

- expand:

  An expansion factor of the bounding box of `x`. `0` means that no
  expansion is added, `1` means that the bounding box is expanded to
  double the original size. See **Details**.

- crop:

  Logical. Should the raster be cropped to the (expanded) bounding box
  of `x`? See **Details**.

- mask:

  Logical, applicable only if `x` is a `sf`, `sfc` or `SpatVector`
  object. Should the raster be
  [masked](https://rspatial.github.io/terra/reference/mask.html) to `x`?
  See **Details**.

- inverse:

  Logical. It only affects when `mask = TRUE`. If `TRUE`, areas on the
  raster that do not overlap with `x` are masked.

- crs:

  Character string describing a coordinate reference system. This
  parameter only affects when `x` is a `SpatExtent`, `sfg`, `bbox` or a
  vector of coordinates. See **CRS** section.

## Value

A `SpatRaster` object (see
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html))
where each layer corresponds to a color channel of `img`:

- If `img` has at least 3 channels (e.g. layers), the result will have
  an additional property setting the layers 1 to 3 as the Red, Green and
  Blue channels with names `"r" "g" "b"` and `alpha` (if applicable).

- If `img` already has a definition or RGB values (this may be the case
  for `tiff/tif` files) the result will keep that channel definition.

The resulting `SpatRaster` will have an RGB specification as explained
in
[`terra::RGB()`](https://rspatial.github.io/terra/reference/RGB.html).

## Details

[`vignette("rasterpic", package = "rasterpic")`](https://dieghernan.github.io/rasterpic/dev/articles/rasterpic.md)
explains, with examples, the effect of parameters `halign`, `valign`,
`expand`, `crop` and `mask`.

### CRS

The function preserves the Coordinate Reference System of `x` if
applicable. For optimal results **do not use** geographic coordinates
(longitude/latitude).

`crs` can be in a WKT format, as a `"authority:number"` code such as
`"EPSG:4326"`, or a PROJ-string format such as `"+proj=utm +zone=12"`.
It can also be retrieved with:

- [`sf::st_crs(25830)$wkt`](https://r-spatial.github.io/sf/reference/st_crs.html).

- [`terra::crs()`](https://rspatial.github.io/terra/reference/crs.html).

- [`tidyterra::pull_crs()`](https://dieghernan.github.io/tidyterra/reference/pull_crs.html).

See **Value** and **Notes** on
[`terra::crs()`](https://rspatial.github.io/terra/reference/crs.html).

## See also

From [sf](https://CRAN.R-project.org/package=sf):

- [`sf::st_crs()`](https://r-spatial.github.io/sf/reference/st_crs.html).

- [`sf::st_bbox()`](https://r-spatial.github.io/sf/reference/st_bbox.html).

- [`vignette("sf1", package = "sf")`](https://r-spatial.github.io/sf/articles/sf1.html)
  to understand how [sf](https://CRAN.R-project.org/package=sf)
  organizes **R** objects.

From [terra](https://CRAN.R-project.org/package=terra):

- [`terra::vect()`](https://rspatial.github.io/terra/reference/vect.html),
  [`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
  and
  [`terra::ext()`](https://rspatial.github.io/terra/reference/ext.html).

- [`terra::mask()`](https://rspatial.github.io/terra/reference/mask.html).

- [`terra::crs()`](https://rspatial.github.io/terra/reference/crs.html).

- [`terra::RGB()`](https://rspatial.github.io/terra/reference/RGB.html).

For plotting:

- [`terra::plot()`](https://rspatial.github.io/terra/reference/plot.html)
  and
  [`terra::plotRGB()`](https://rspatial.github.io/terra/reference/plotRGB.html).

- With [ggplot2](https://CRAN.R-project.org/package=ggplot2) use
  [tidyterra](https://CRAN.R-project.org/package=tidyterra):

  - [`tidyterra::autoplot.SpatRaster()`](https://dieghernan.github.io/tidyterra/reference/autoplot.Spat.html).

  - [`tidyterra::geom_spatraster_rgb()`](https://dieghernan.github.io/tidyterra/reference/geom_spatraster_rgb.html).

- Other packages:

  - [tmap](https://CRAN.R-project.org/package=tmap).

  - [mapsf](https://CRAN.R-project.org/package=mapsf).

  - [maptiles](https://CRAN.R-project.org/package=maptiles).

## Examples

``` r
# \donttest{
library(sf)
#> Linking to GEOS 3.12.1, GDAL 3.8.4, PROJ 9.4.0; sf_use_s2() is TRUE
library(terra)
library(ggplot2)
library(tidyterra)
#> 
#> Attaching package: ‘tidyterra’
#> The following object is masked from ‘package:stats’:
#> 
#>     filter


x_path <- system.file("gpkg/UK.gpkg", package = "rasterpic")
x <- st_read(x_path, quiet = TRUE)
img <- system.file("img/vertical.png", package = "rasterpic")

# Default config
ex1 <- rasterpic_img(x, img)

ex1
#> class       : SpatRaster 
#> size        : 333, 250, 3  (nrow, ncol, nlyr)
#> resolution  : 6484.467, 6484.467  (x, y)
#> extent      : -1193414, 427703.2, 6430573, 8589900  (xmin, xmax, ymin, ymax)
#> coord. ref. : WGS 84 / Pseudo-Mercator (EPSG:3857) 
#> source(s)   : memory
#> colors RGB  : 1, 2, 3 
#> names       :   r,   g,   b 
#> min values  :  15,   8,   4 
#> max values  : 254, 255, 254 

autoplot(ex1) +
  geom_sf(data = x, fill = NA, color = "white", linewidth = .5)



# Expand
ex2 <- rasterpic_img(x, img, expand = 0.5)

autoplot(ex2) +
  geom_sf(data = x, fill = NA, color = "white", linewidth = .5)



# Align
ex3 <- rasterpic_img(x, img, halign = 0)

autoplot(ex3) +
  geom_sf(data = x, fill = NA, color = "white", linewidth = .5)

labs(title = "Align")
#> <ggplot2::labels> List of 1
#>  $ title: chr "Align"

# Crop
ex4 <- rasterpic_img(x, img, crop = TRUE)

autoplot(ex4) +
  geom_sf(data = x, fill = NA, color = "white", linewidth = .5) +
  labs(title = "Crop")


# Mask
ex5 <- rasterpic_img(x, img, mask = TRUE)

autoplot(ex5) +
  geom_sf(data = x, fill = NA, color = "white", linewidth = .5) +
  labs(title = "Mask")


# Mask inverse
ex6 <- rasterpic_img(x, img, mask = TRUE, inverse = TRUE)

autoplot(ex6) +
  geom_sf(data = x, fill = NA, color = "white", linewidth = .5) +
  labs(title = "Mask Inverse")


# Combine Mask inverse and crop
ex7 <- rasterpic_img(x, img, crop = TRUE, mask = TRUE, inverse = TRUE)

autoplot(ex7) +
  geom_sf(data = x, fill = NA, color = "white", linewidth = .5) +
  labs(title = "Combine")


# RGB channels ------
plot(ex1)

ex_rgb <- ex1
has.RGB(ex_rgb)
#> [1] TRUE
RGB(ex_rgb)
#> [1] 1 2 3

# Modify RGB channels
RGB(ex_rgb) <- c(2, 3, 1)
RGB(ex_rgb)
#> [1] 2 3 1

plot(ex_rgb)


# Remove RGB channels
RGB(ex_rgb) <- NULL
has.RGB(ex_rgb)
#> [1] FALSE
RGB(ex_rgb)
#> NULL

# Note the difference with terra::plot
plot(ex_rgb)

# }
```
