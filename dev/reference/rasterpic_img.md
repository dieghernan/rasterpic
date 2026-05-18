# Convert an image into a geotagged `SpatRaster`

Geotags an image based on the coordinates of a spatial object.

`rasterpic_img()` is an S3 generic.
[rasterpic](https://CRAN.R-project.org/package=rasterpic) provides
methods for the following classes:

- `SpatExtent`

- `SpatRaster`

- `SpatVector`

- `bbox`

- `default`

- `numeric`

- `sf`

- `sfc`

- `sfg`

- `stars`

## Usage

``` r
rasterpic_img(
  x,
  img,
  halign = 0.5,
  valign = 0.5,
  expand = 0,
  crop = FALSE,
  ...
)

# S3 method for class 'sf'
rasterpic_img(
  x,
  img,
  halign = 0.5,
  valign = 0.5,
  expand = 0,
  crop = FALSE,
  ...,
  mask = FALSE,
  inverse = FALSE
)

# S3 method for class 'sfc'
rasterpic_img(
  x,
  img,
  halign = 0.5,
  valign = 0.5,
  expand = 0,
  crop = FALSE,
  ...,
  mask = FALSE,
  inverse = FALSE
)

# S3 method for class 'sfg'
rasterpic_img(
  x,
  img,
  halign = 0.5,
  valign = 0.5,
  expand = 0,
  crop = FALSE,
  ...,
  mask = FALSE,
  inverse = FALSE,
  crs = NULL
)

# S3 method for class 'stars'
rasterpic_img(
  x,
  img,
  halign = 0.5,
  valign = 0.5,
  expand = 0,
  crop = FALSE,
  ...
)

# S3 method for class 'bbox'
rasterpic_img(
  x,
  img,
  halign = 0.5,
  valign = 0.5,
  expand = 0,
  crop = FALSE,
  ...,
  crs = NULL
)

# S3 method for class 'numeric'
rasterpic_img(
  x,
  img,
  halign = 0.5,
  valign = 0.5,
  expand = 0,
  crop = FALSE,
  ...,
  crs = NULL
)

# S3 method for class 'SpatRaster'
rasterpic_img(
  x,
  img,
  halign = 0.5,
  valign = 0.5,
  expand = 0,
  crop = FALSE,
  ...
)

# S3 method for class 'SpatVector'
rasterpic_img(
  x,
  img,
  halign = 0.5,
  valign = 0.5,
  expand = 0,
  crop = FALSE,
  ...,
  mask = FALSE,
  inverse = FALSE
)

# S3 method for class 'SpatExtent'
rasterpic_img(
  x,
  img,
  halign = 0.5,
  valign = 0.5,
  expand = 0,
  crop = FALSE,
  ...,
  crs = NULL
)
```

## Arguments

- x:

  An **R** object (see **S3 methods**).

- img:

  An image to be geotagged. It can be a local file or a URL (e.g.
  `"https://i.imgur.com/6yHmlwT.jpeg"`). Accepted extensions are `png`,
  `jpeg`/`jpg` and `tiff`/`tif`.

- halign:

  A number between `0` and `1` giving the horizontal alignment of `img`
  relative to `x`. `0` aligns `x` with the left edge, `1` aligns with
  the right edge and `0.5` centers it horizontally.

- valign:

  A number between `0` and `1` giving the vertical alignment of `img`
  relative to `x`. `0` aligns `x` with the bottom edge, `1` aligns with
  the top edge and `0.5` centers it vertically.

- expand:

  An expansion factor of the bounding box of `x`. `0` means that no
  expansion is added, `1` means that the bounding box is expanded to
  double the original size. See **Details**.

- crop:

  Logical. Should the raster be cropped to the (expanded) bounding box
  of `x`? See **Details**.

- ...:

  Further arguments passed to methods.

- mask:

  Logical, available for vector methods. Should the raster be
  [masked](https://rspatial.github.io/terra/reference/mask.html) to the
  shape of `x`? See **Details**.

- inverse:

  Logical. This only has an effect when `mask = TRUE`. If `TRUE`, areas
  of the raster covered by `x` are masked.

- crs:

  Character string describing a CRS. This parameter only applies when
  `x` is a `SpatExtent`, `sfg`, `bbox` or a numeric coordinate vector.
  See **CRS** section.

## Value

A `SpatRaster` object (see
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html))
where each layer corresponds to a color channel of `img`:

- If `img` has at least 3 layers, the result will have an additional
  property setting layers 1 to 3 as the red, green and blue channels
  with names `"r"`, `"g"` and `"b"` and `alpha` if applicable.

- If `img` already has a definition of RGB values (this may be the case
  for `tiff`/`tif` files) the result will keep that channel definition.

The resulting `SpatRaster` will have an RGB specification as explained
in
[`terra::RGB()`](https://rspatial.github.io/terra/reference/RGB.html).

## Details

[`vignette("rasterpic", package = "rasterpic")`](https://dieghernan.github.io/rasterpic/dev/articles/rasterpic.md)
explains, with examples, the effect of parameters `halign`, `valign`,
`expand`, `crop` and `mask`.

### S3 methods

[rasterpic](https://CRAN.R-project.org/package=rasterpic) supports the
following input classes:

- **sf** classes: `sf`, `sfc`, `sfg` or `bbox`.

- **terra** classes: `SpatRaster`, `SpatVector` and `SpatExtent`.

- **stars** classes: `stars`.

- A numeric coordinate vector of the form `c(xmin, ymin, xmax, ymax)`.

Other packages can provide methods for additional spatial classes.

Methods for extent-like inputs use the object extent. Methods for vector
inputs can also mask the image to the object shape.

### CRS

This function preserves the CRS of `x` when applicable. For optimal
results, **do not use** geographic coordinates (longitude/latitude).

`crs` can be in a WKT format, as a `"authority:number"` code such as
`"EPSG:4326"` or a PROJ-string format such as `"+proj=utm +zone=12"`. It
can also be retrieved with:

- [`sf::st_crs(25830)$wkt`](https://r-spatial.github.io/sf/reference/st_crs.html).

- [`terra::crs()`](https://rspatial.github.io/terra/reference/crs.html).

- [`tidyterra::pull_crs()`](https://dieghernan.github.io/tidyterra/reference/pull_crs.html).

See **Value** and **Notes** in
[`terra::crs()`](https://rspatial.github.io/terra/reference/crs.html).

## See also

[`vignette("rasterpic", package = "rasterpic")`](https://dieghernan.github.io/rasterpic/dev/articles/rasterpic.md)
for examples.

From [sf](https://CRAN.R-project.org/package=sf):

- [`sf::st_crs()`](https://r-spatial.github.io/sf/reference/st_crs.html).

- [`sf::st_bbox()`](https://r-spatial.github.io/sf/reference/st_bbox.html).

- [`vignette("sf1", package = "sf")`](https://r-spatial.github.io/sf/articles/sf1.html)
  to understand how [sf](https://CRAN.R-project.org/package=sf)
  organizes **R** objects.

From [stars](https://CRAN.R-project.org/package=stars):

- [`stars::st_as_stars()`](https://r-spatial.github.io/stars/reference/st_as_stars.html).

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

- [`tidyterra::autoplot.SpatRaster()`](https://dieghernan.github.io/tidyterra/reference/autoplot.Spat.html)
  and
  [`tidyterra::geom_spatraster_rgb()`](https://dieghernan.github.io/tidyterra/reference/geom_spatraster_rgb.html)
  with [ggplot2](https://CRAN.R-project.org/package=ggplot2).

- [tmap](https://CRAN.R-project.org/package=tmap),
  [mapsf](https://CRAN.R-project.org/package=mapsf) and
  [maptiles](https://CRAN.R-project.org/package=maptiles).

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

# Default configuration.
ex1 <- rasterpic_img(x, img)

ex1
#> class       : SpatRaster
#> size        : 333, 250, 3  (nrow, ncol, nlyr)
#> resolution  : 6484.467, 6484.467  (x, y)
#> extent      : -1193414, 427703.2, 6430573, 8589900  (xmin, xmax, ymin, ymax)
#> coord. ref. : WGS 84 / Pseudo-Mercator (EPSG:3857)
#> source(s)   : memory
#> colors rgb  : 1, 2, 3
#> names       :   r,   g,   b
#> min values  :  15,   8,   4
#> max values  : 254, 255, 254

autoplot(ex1) +
  geom_sf(data = x, fill = NA, color = "white", linewidth = 0.5)


# Expand.
ex2 <- rasterpic_img(x, img, expand = 0.5)

autoplot(ex2) +
  geom_sf(data = x, fill = NA, color = "white", linewidth = 0.5)


# Align.
ex3 <- rasterpic_img(x, img, halign = 0)

autoplot(ex3) +
  geom_sf(data = x, fill = NA, color = "white", linewidth = 0.5)

labs(title = "Align")
#> <ggplot2::labels> List of 1
#>  $ title: chr "Align"

# Crop.
ex4 <- rasterpic_img(x, img, crop = TRUE)

autoplot(ex4) +
  geom_sf(data = x, fill = NA, color = "white", linewidth = 0.5) +
  labs(title = "Crop")


# Mask.
ex5 <- rasterpic_img(x, img, mask = TRUE)

autoplot(ex5) +
  geom_sf(data = x, fill = NA, color = "white", linewidth = 0.5) +
  labs(title = "Mask")


# Inverse mask.
ex6 <- rasterpic_img(x, img, mask = TRUE, inverse = TRUE)

autoplot(ex6) +
  geom_sf(data = x, fill = NA, color = "white", linewidth = 0.5) +
  labs(title = "Mask Inverse")


# Combine inverse masking and cropping.
ex7 <- rasterpic_img(x, img, crop = TRUE, mask = TRUE, inverse = TRUE)

autoplot(ex7) +
  geom_sf(data = x, fill = NA, color = "white", linewidth = 0.5) +
  labs(title = "Combine")

# }
```
