#' Convert an image to a geo-tagged `SpatRaster`
#'
#' @description
#'
#' Geotags an image based on the coordinates of a given spatial object.
#'
#' @param x **R** object that may be:
#'   * An object created with \CRANpkg{sf} of class [`sf`][sf::st_sf],
#'     [`sfc`][sf::st_sfc], `sfg` or [`bbox`][sf::st_bbox]).
#'   * An object created with \CRANpkg{terra} of class
#'     [`SpatRaster`][terra::rast], [`SpatVector`][terra::vect] or
#'     [`SpatExtent`][terra::ext].
#'   * A numeric vector of length 4 with the extent to be used for geotagging (
#'     i.e. `c(xmin, ymin, xmax, ymax)`).
#'
#' @param img An image to be geotagged. It can be a local file or an online
#'   file (e.g. `"https://i.imgur.com/6yHmlwT.jpeg"`). The following image
#'   extensions are accepted:
#'   * `png`.
#'   * `jpeg/jpg`.
#'   * `tiff/tif`.
#'
#' @param halign,valign Horizontal and vertical alignment of `img` with respect
#'  to `x`. It should be a value between `0` and `1`:
#'  - `halign = 0, valign = 0` assumes that `x` should be in the bottom left
#'     corner of the `SpatRaster`.
#'  - `halign = 1, valign = 1` assumes that `x` should be in the top right
#'     corner of the `SpatRaster`.
#'  - The default `halign = .5, valign = .5` assumes that `x` is the center
#'    of `img`.
#'  See `vignette("rasterpic", package = "rasterpic")` for examples.
#'
#' @param expand An expansion factor of the bounding box of `x`. `0` means that
#'  no expansion is added, `1` means that the bounding box is expanded to double
#'  the original size. See **Details**.
#'
#' @param crop Logical. Should the raster be cropped to the (expanded) bounding
#'  box of `x`? See **Details**.
#'
#' @param mask Logical, applicable only if `x` is a `sf`,  `sfc` or `SpatVector`
#'   object. Should the raster be [masked][terra::mask] to `x`? See **Details**.
#'
#' @param inverse Logical. It affects only if `mask = TRUE`. If `TRUE`, areas on
#'   the raster that do not overlap with `x` are masked.
#'
#' @param crs Character string describing a coordinate reference system.
#'   This parameter would only affect if `x` is a `SpatExtent`, `sfg`, `bbox` or
#'   a vector of coordinates. See **CRS** section.
#'
#' @return
#' A `SpatRaster` object (see [terra::rast()]) where each layer corresponds to
#' a color channel of `img`:
#' - If `img` has at least 3 channels (e.g. layers), the result would have
#'   an additional property setting the layers 1 to 3 as the Red, Green and Blue
#'   channels.
#' - If `img` already has a definition or RGB values (this may be the case for
#'   `tiff/tif` files) the result would keep that channel definition.
#'
#' @details
#'
#' `vignette("rasterpic", package = "rasterpic")` explains with examples the
#'  effect of parameters `halign`, `valign`, `expand`, `crop` and `mask`.
#'
#' ## CRS
#'
#' The function preserves the Coordinate Reference System of `x` if applicable.
#' For optimal results **do not use** geographic coordinates
#' (longitude/latitude).
#'
#' `crs` can be in a WKT format, as a `"authority:number"` code such as
#' `"EPSG:4326"`, or a PROJ-string format such as `"+proj=utm +zone=12"`. It can
#' be also retrieved with:
#' - [`sf::st_crs(25830)$wkt`][sf::st_crs].
#' - [terra::crs()].
#' - [tidyterra::pull_crs()].
#'
#'  See **Value** and **Notes** on [terra::crs()].
#'
#' @seealso
#'
#' From \CRANpkg{sf}:
#' - [sf::st_crs()].
#' - [sf::st_bbox()].
#' - `vignette("sf1", package = "sf")` to understand how \CRANpkg{sf} organizes
#'   **R** objects.
#'
#' From \CRANpkg{terra}:
#' - [terra::vect()], [terra::rast()] and [terra::ext()].
#' - [terra::mask()].
#' - [terra::crs()].
#' - [terra::RGB()].
#'
#' For plotting:
#' - [terra::plot()] and [terra::plotRGB()].
#' - With \CRANpkg{ggplot2} use \CRANpkg{tidyterra}:
#'   - [tidyterra::autoplot.SpatRaster()].
#'   - [tidyterra::geom_spatraster_rgb()].
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(sf)
#' library(terra)
#' library(ggplot2)
#' library(tidyterra)
#'
#'
#' x_path <- system.file("gpkg/UK.gpkg", package = "rasterpic")
#' x <- st_read(x_path, quiet = TRUE)
#' img <- system.file("img/vertical.png", package = "rasterpic")
#'
#' # Default config
#' ex1 <- rasterpic_img(x, img)
#'
#' ex1
#'
#' autoplot(ex1) +
#'   geom_sf(data = x, fill = NA, color = "white", linewidth = .5)
#'
#'
#' # Expand
#' ex2 <- rasterpic_img(x, img, expand = 0.5)
#'
#' autoplot(ex2) +
#'   geom_sf(data = x, fill = NA, color = "white", linewidth = .5)
#'
#'
#' # Align
#' ex3 <- rasterpic_img(x, img, halign = 0)
#'
#' autoplot(ex3) +
#'   geom_sf(data = x, fill = NA, color = "white", linewidth = .5)
#' labs(title = "Align")
#'
#' # Crop
#' ex4 <- rasterpic_img(x, img, crop = TRUE)
#'
#' autoplot(ex4) +
#'   geom_sf(data = x, fill = NA, color = "white", linewidth = .5) +
#'   labs(title = "Crop")
#'
#' # Mask
#' ex5 <- rasterpic_img(x, img, mask = TRUE)
#'
#' autoplot(ex5) +
#'   geom_sf(data = x, fill = NA, color = "white", linewidth = .5) +
#'   labs(title = "Mask")
#'
#' # Mask inverse
#' ex6 <- rasterpic_img(x, img, mask = TRUE, inverse = TRUE)
#'
#' autoplot(ex6) +
#'   geom_sf(data = x, fill = NA, color = "white", linewidth = .5) +
#'   labs(title = "Mask Inverse")
#'
#' # Combine Mask inverse and crop
#' ex7 <- rasterpic_img(x, img, crop = TRUE, mask = TRUE, inverse = TRUE)
#'
#' autoplot(ex7) +
#'   geom_sf(data = x, fill = NA, color = "white", linewidth = .5) +
#'   labs(title = "Combine")
#'
#' # RGB channels ------
#' plot(ex1)
#' ex_rgb <- ex1
#' has.RGB(ex_rgb)
#' RGB(ex_rgb)
#'
#' # Modify RGB channels
#' RGB(ex_rgb) <- c(2, 3, 1)
#' RGB(ex_rgb)
#'
#' plot(ex_rgb)
#'
#' # Remove RGB channels
#' RGB(ex_rgb) <- NULL
#' has.RGB(ex_rgb)
#' RGB(ex_rgb)
#'
#' # Note the difference with terra::plot
#' plot(ex_rgb)
#' }
rasterpic_img <- function(x, img, halign = .5, valign = .5, expand = 0,
                          crop = FALSE, mask = FALSE, inverse = FALSE,
                          crs = NULL) {
  # Initial validations
  if (halign < 0 || halign > 1) stop("'halign' should be between 0 and 1")
  if (valign < 0 || valign > 1) stop("'valign' should be between 0 and 1")

  # A. Extract values from x: crs and initial extent----

  process <- rpic_input(x, crs)

  # Unpack
  crs <- process$crs
  box <- process$box
  x <- process$x

  # B. Read img file----
  rast <- rpic_read(img, crs)

  # Throw a warning if nlyrs not correct
  if (terra::nlyr(rast) < 3) {
    warning(
      "img has ", terra::nlyr(rast), " not 3 or 4. ",
      "Result does not have a RGB property."
    )
  }

  # C. Geo-tagging the png----
  ## 1. Creates an expanded bbox----
  innermarg <- min(
    (box[3] - box[1]),
    (box[4] - box[2])
  ) * expand

  box_marg <- box + c(rep(-innermarg, 2), rep(innermarg, 2))

  ## 2. Adjust extent----
  # ratio w/h raster

  ratio_raster <- asp_ratio(rast)
  ratio_x <- asp_ratio(box_marg)

  # We assume planar coords from this point onwards

  # Width and height of the x object (after expanding)
  w <- box_marg[3] - box_marg[1]
  h <- box_marg[4] - box_marg[2]

  # Placement of the raster and the sf
  if (ratio_x <= ratio_raster) {
    # On this cases, adjust the width
    new_h <- h
    y_init <- box_marg[2]

    new_w <- h * ratio_raster
    # Handles alignment
    x_init <- box_marg[1] - halign * (new_w - w)
  } else {
    # On this cases, adjust the height
    new_w <- w
    x_init <- box_marg[1]

    new_h <- w / ratio_raster
    # Handles alignment
    y_init <- box_marg[2] - valign * (new_h - h)
  }

  # Create the final extent of the raster
  ext <- c(x_init, x_init + new_w, y_init, y_init + new_h)

  # Copy!
  new_rast <- rast
  terra::ext(new_rast) <- terra::ext(ext)

  # D. (Optionally) Crop ----
  new_rast <- rpic_crop(crop, box_marg, new_rast)

  # E. (Optionally) Mask ----

  if (mask) {
    if (inherits(x, "SpatVector")) {
      # Ensure CRS in the SpatVector
      terra::crs(x) <- crs

      new_rast <- terra::mask(new_rast, x,
        inverse = inverse
      )
    } else {
      message("'mask' only available when 'x' is an 'sf/sfc/SpatVector' object")
    }
  }

  # Assign RGB if at least 3 layers and not already RGB
  if (terra::nlyr(new_rast) >= 3) {
    if (!terra::has.RGB(new_rast)) {
      terra::RGB(new_rast) <- c(1, 2, 3)
    }
  }

  return(new_rast)
}
