#' Convert an image to a geo-tagged raster
#'
#' @description
#' Geotags an image based on the coordinates of a given spatial object.
#'
#' @param x It could be
#'   * A `sf`, `sfc`, `sfg` or bounding box (see [sf::st_bbox()]) object
#'     (**sf** package).
#'   * A `SpatRaster`, `SpatVector` or `SpatExtent` object (**terra** package).
#'   * A numeric vector of length 4 with the extent to be used for geotagging (
#'     i.e. `c(xmin, ymin, xmax, ymax)`).
#' @param img An image to be geotagged. It can be a local file or an online
#'   file (e.g. "https://i.imgur.com/6yHmlwT.jpeg"). The following image
#'   extensions are accepted:
#'   * `png`
#'   * `jpeg/jpg`
#'   * `tiff/tif`
#' @param halign Horizontal alignment of `img` with respect to the `x` object.
#'  It should be a value between `0` (`x` is aligned on the left edge of the
#'  raster) and `1` (`x` is on the right edge of the raster).
#' @param valign Vertical alignment of `img` with respect to the `x` object.
#'  It should be a value between `0` (`x` is aligned on the bottom edge of the
#'  raster) and `1` (`x` is on the top edge of the raster).
#' @param expand An expansion factor of the bounding box of `x`. `0` means that
#'  no expansion is added, `1` means that the bounding box is expanded to double
#'  the original size.
#' @param crop Logical. Should the raster be cropped to the (expanded) bounding
#'  box of `x`?
#' @param mask Logical. Should the raster be masked to `x`? See [terra::mask()]
#'  for details. This option is only valid if `x` is a `sf/sfc` object.
#' @param inverse Logical. It affects only if `mask = TRUE`. If `TRUE`, areas on
#'   the raster that do not overlap with `x` are masked.
#' @param crs Character string describing a coordinate reference system.
#'   This parameter would only affect if `x` does not present a Coordinate
#'   Reference System (e.g. when `x` is a `SpatExtent`, `sfg` `bbox` or a
#'   vector of coordinates). See **Details**
#'
#' @return A `SpatRaster` object.
#'
#' @details
#'
#' The function preserves the Coordinate Reference System of the `x` object. For
#' optimal results do not use geographic coordinates (longitude/latitude).
#'
#' `crs` can be in a WKT format, as a "authority:number" code such as
#' `"EPSG:4326"`, or a PROJ-string format such as "+proj=utm +zone=12". It can
#' be also retrieved as `sf::st_crs(25830)$wkt`. See `value` and **Notes** on
#' [terra::crs()].
#'
#' @seealso [sf::st_crs()], [sf::st_bbox()], [terra::crs()].
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(sf)
#' library(terra)
#'
#' x_path <- system.file("gpkg/UK.gpkg", package = "rasterpic")
#' x <- st_read(x_path, quiet = TRUE)
#' img <- system.file("img/vertical.png", package = "rasterpic")
#'
#' # Default config
#' ex1 <- rasterpic_img(x, img)
#'
#' class(ex1)
#'
#'
#' plotRGB(ex1)
#' plot(x$geom,
#'   add = TRUE,
#'   col = NA,
#'   border = "white",
#'   lwd = 2
#' )
#'
#' # Expand
#' ex2 <- rasterpic_img(x,
#'   img,
#'   expand = 0.5
#' )
#'
#' plotRGB(ex2)
#' plot(x$geom,
#'   add = TRUE,
#'   col = NA,
#'   border = "white",
#'   lwd = 2
#' )
#'
#' # Align
#' ex3 <- rasterpic_img(x,
#'   img,
#'   halign = 0
#' )
#'
#' plotRGB(ex3)
#' plot(x$geom,
#'   add = TRUE,
#'   col = NA,
#'   border = "white",
#'   lwd = 2
#' )
#'
#' # Crop
#' ex4 <- rasterpic_img(x,
#'   img,
#'   crop = TRUE
#' )
#'
#' plotRGB(ex4)
#' plot(x$geom,
#'   add = TRUE,
#'   col = NA,
#'   border = "white",
#'   lwd = 2
#' )
#'
#' # Mask
#' ex5 <- rasterpic_img(x,
#'   img,
#'   mask = TRUE
#' )
#'
#' plotRGB(ex5)
#' plot(x$geom,
#'   add = TRUE,
#'   col = NA,
#'   border = "white",
#'   lwd = 2
#' )
#'
#'
#' # Mask inverse
#' ex6 <- rasterpic_img(x,
#'   img,
#'   mask = TRUE,
#'   inverse = TRUE
#' )
#'
#' plotRGB(ex6)
#' plot(x$geom,
#'   add = TRUE,
#'   col = NA,
#'   border = "white",
#'   lwd = 2
#' )
#'
#'
#' # Combine Mask inverse and crop
#' ex7 <- rasterpic_img(x,
#'   img,
#'   crop = TRUE,
#'   mask = TRUE,
#'   inverse = TRUE
#' )
#'
#' plotRGB(ex7)
#' plot(x$geom,
#'   add = TRUE,
#'   col = NA,
#'   border = "white",
#'   lwd = 2
#' )
#' }
rasterpic_img <- function(x,
                          img,
                          halign = 0.5,
                          valign = 0.5,
                          expand = 0,
                          crop = FALSE,
                          mask = FALSE,
                          inverse = FALSE,
                          crs) {

  # Initial validations
  if (halign < 0 | halign > 1) stop("'haling' should be between 0 and 1")
  if (valign < 0 | valign > 1) stop("'valing' should be between 0 and 1")

  # A. Extract values from x: crs and initial extent----

  process <- rpic_input(x, crs)

  # Unpack
  crs <- process$crs
  box <- process$box
  x <- process$x

  # B. Read img file----
  rast <- rpic_read(img, crs)

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
  ext <- c(
    x_init,
    x_init + new_w,
    y_init,
    y_init + new_h
  )


  # Copy!
  new_rast <- rast
  terra::ext(new_rast) <- terra::ext(ext)

  # D. (Optionally) Crop ----
  new_rast <- rpic_crop(crop, box_marg, new_rast)

  # E. (Optionally) Mask ----

  if (mask) {
    if (inherits(x, "SpatVector")) {
      new_rast <- terra::mask(new_rast, x,
        inverse = inverse
      )
    } else {
      message("'mask' only available when 'x' is an 'sf/sfc/SpatVector' object")
    }
  }

  return(new_rast)
}