#' Geotag an image as a `SpatRaster`
#'
#' @description
#' Geotag an image and return a `SpatRaster` based on coordinates from a
#' supported spatial input class.
#'
#' `rasterpic_img()` is an S3 generic. See **S3 methods** for supported input
#' classes.
#'
#' @param x An \R object. See **S3 methods** for supported classes.
#'
#' @param img An image to geotag. It can be a local file or a URL, for example
#'   `"https://i.imgur.com/6yHmlwT.jpeg"`. Accepted file extensions are `png`,
#'   `jpg`, `jpeg`, `tif` and `tiff`.
#'
#' @param halign A number between `0` and `1` giving the horizontal alignment of
#'   `img` relative to `x`. `0` aligns `img` with the left edge of `x`, `1`
#'   aligns it with the right edge and `0.5` centers it horizontally.
#'
#' @param valign A number between `0` and `1` giving the vertical alignment of
#'   `img` relative to `x`. `0` aligns `img` with the bottom edge of `x`, `1`
#'   aligns it with the top edge and `0.5` centers it vertically.
#'
#' @param expand An expansion factor of the bounding box of `x`. `0` means that
#'   no expansion is added, `1` means that the bounding box is expanded to
#'   double the original size. See **Details**.
#'
#' @param crop Logical. Should the raster be cropped to the (expanded) bounding
#'   box of `x`? See **Details**.
#'
#' @param mask Logical, for vector methods. Should the raster be
#'   [masked][terra::mask] to the shape of `x`? See **Details**.
#'
#' @param inverse Logical. Only used when `mask = TRUE`. If `TRUE`, areas of
#'   the raster covered by `x` are masked.
#'
#' @param crs Character string describing a CRS. This parameter only applies
#'   when `x` is a `SpatExtent`, `sfg`, `bbox` or a numeric coordinate vector.
#'   See the **CRS** section.
#'
#' @param ... Further arguments passed to methods.
#'
#' @return
#' A `SpatRaster` object (see [terra::rast()]) where each layer corresponds to
#' a color channel of `img`:
#'
#' - If `img` has at least 3 layers, the result records layers 1 to 3 as the
#'   red, green and blue channels with names `"r"`, `"g"` and `"b"` and `alpha`
#'   if applicable.
#' - If `img` already has an RGB specification (this may be the case for
#'   `tif`/`tiff` files), the result keeps that specification.
#'
#' The resulting `SpatRaster` will have an RGB specification as explained in
#' [terra::RGB()].
#'
#' @details
#' `vignette("rasterpic", package = "rasterpic")` explains the effect of
#' parameters `halign`, `valign`, `expand`, `crop` and `mask` with examples.
#'
#' ## S3 methods
#'
#' \CRANpkg{rasterpic} supports these spatial input classes:
#'
#' - \CRANpkg{sf} classes: `sf`, `sfc`, `sfg` and `bbox`.
#' - \CRANpkg{terra} classes: `SpatRaster`, `SpatVector` and `SpatExtent`.
#' - \CRANpkg{stars} class: `stars`.
#' - A numeric coordinate vector of the form `c(xmin, ymin, xmax, ymax)`.
#'
#' Other packages can provide methods for additional spatial classes.
#'
#' Methods for extent-like inputs use the object extent. Methods for vector
#' inputs can also mask the image to the object shape.
#'
#' ## CRS
#'
#' This function preserves the CRS of `x` when applicable. For optimal results,
#' **do not use** geographic coordinates (longitude/latitude).
#'
#' `crs` can be in WKT format, as an `"authority:number"` code such as
#' `"EPSG:4326"` or as a PROJ-string such as `"+proj=utm +zone=12"`. It can also
#' be retrieved with:
#'
#' - [`sf::st_crs(25830)$wkt`][sf::st_crs].
#' - [terra::crs()].
#' - [tidyterra::pull_crs()].
#'
#' See the **Value** and **Notes** sections in [terra::crs()].
#'
#' @seealso
#' `vignette("rasterpic", package = "rasterpic")` for examples.
#'
#' From \CRANpkg{sf}:
#'
#' - [sf::st_crs()].
#' - [sf::st_bbox()].
#' - `vignette("sf1", package = "sf")` to understand how \CRANpkg{sf} organizes
#'   \R objects.
#'
#' From \CRANpkg{stars}:
#'
#' - [stars::st_as_stars()].
#'
#' From \CRANpkg{terra}:
#'
#' - [terra::vect()], [terra::rast()] and [terra::ext()].
#' - [terra::mask()].
#' - [terra::crs()].
#' - [terra::RGB()].
#'
#' For plotting:
#'
#' - [terra::plot()] and [terra::plotRGB()].
#' - [tidyterra::autoplot.SpatRaster()] and
#'   [tidyterra::geom_spatraster_rgb()] with \CRANpkg{ggplot2}.
#' - \CRANpkg{tmap}, \CRANpkg{mapsf} and \CRANpkg{maptiles}.
#'
#' @export
#' @encoding UTF-8
#' @examples
#' \donttest{
#' library(sf)
#' library(terra)
#' library(ggplot2)
#' library(tidyterra)
#'
#' x_path <- system.file("gpkg/UK.gpkg", package = "rasterpic")
#' x <- st_read(x_path, quiet = TRUE)
#' img <- system.file("img/vertical.png", package = "rasterpic")
#'
#' # Use the default configuration.
#' ex1 <- rasterpic_img(x, img)
#'
#' ex1
#'
#' autoplot(ex1) +
#'   geom_sf(data = x, fill = NA, color = "white", linewidth = 0.5)
#'
#' # Expand the bounding box.
#' ex2 <- rasterpic_img(x, img, expand = 0.5)
#'
#' autoplot(ex2) +
#'   geom_sf(data = x, fill = NA, color = "white", linewidth = 0.5)
#'
#' # Align the image to the left edge.
#' ex3 <- rasterpic_img(x, img, halign = 0)
#'
#' autoplot(ex3) +
#'   geom_sf(data = x, fill = NA, color = "white", linewidth = 0.5) +
#'   labs(title = "Align")
#'
#' # Crop to the bounding box.
#' ex4 <- rasterpic_img(x, img, crop = TRUE)
#'
#' autoplot(ex4) +
#'   geom_sf(data = x, fill = NA, color = "white", linewidth = 0.5) +
#'   labs(title = "Crop")
#'
#' # Mask to the vector shape.
#' ex5 <- rasterpic_img(x, img, mask = TRUE)
#'
#' autoplot(ex5) +
#'   geom_sf(data = x, fill = NA, color = "white", linewidth = 0.5) +
#'   labs(title = "Mask")
#'
#' # Mask outside the vector shape.
#' ex6 <- rasterpic_img(x, img, mask = TRUE, inverse = TRUE)
#'
#' autoplot(ex6) +
#'   geom_sf(data = x, fill = NA, color = "white", linewidth = 0.5) +
#'   labs(title = "Mask Inverse")
#'
#' # Combine cropping and inverse masking.
#' ex7 <- rasterpic_img(x, img, crop = TRUE, mask = TRUE, inverse = TRUE)
#'
#' autoplot(ex7) +
#'   geom_sf(data = x, fill = NA, color = "white", linewidth = 0.5) +
#'   labs(title = "Combine")
#' }
rasterpic_img <- function(
  x,
  img,
  halign = 0.5,
  valign = 0.5,
  expand = 0,
  crop = FALSE,
  ...
) {
  UseMethod("rasterpic_img")
}

#' @export
rasterpic_img.default <- function(
  x,
  img,
  halign = 0.5,
  valign = 0.5,
  expand = 0,
  crop = FALSE,
  ...
) {
  # Report unsupported S3 classes.
  class_name <- paste0(class(x), collapse = ".") # nolint
  cli::cli_abort(paste0(
    "S3 method {.fun rasterpic_img} is not implemented for",
    " {.cls {class_name}} objects."
  ))
}

#' @rdname rasterpic_img
#' @export
rasterpic_img.sf <- function(
  x,
  img,
  halign = 0.5,
  valign = 0.5,
  expand = 0,
  crop = FALSE,
  ...,
  mask = FALSE,
  inverse = FALSE
) {
  crs <- sf::st_crs(x)

  x <- terra::vect(x)

  if (is.na(crs)) {
    terra::crs(x) <- ""
  }

  rasterpic_img(
    x,
    img = img,
    halign = halign,
    valign = valign,
    expand = expand,
    crop = crop,
    mask = mask,
    inverse = inverse
  )
}

#' @rdname rasterpic_img
#' @export
rasterpic_img.sfc <- function(
  x,
  img,
  halign = 0.5,
  valign = 0.5,
  expand = 0,
  crop = FALSE,
  ...,
  mask = FALSE,
  inverse = FALSE
) {
  x <- sf::st_as_sf(x)

  rasterpic_img(
    x,
    img = img,
    halign = halign,
    valign = valign,
    expand = expand,
    crop = crop,
    mask = mask,
    inverse = inverse
  )
}

#' @rdname rasterpic_img
#' @export
rasterpic_img.sfg <- function(
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
) {
  if (any(is.null(crs), is.na(crs))) {
    crs <- NA
  }
  x <- sf::st_sfc(x)
  x <- sf::st_sf(x)
  sf::st_crs(x) <- crs
  rasterpic_img(
    x,
    img = img,
    halign = halign,
    valign = valign,
    expand = expand,
    crop = crop,
    mask = mask,
    inverse = inverse
  )
}

#' @rdname rasterpic_img
#' @export
rasterpic_img.stars <- function(
  x,
  img,
  halign = 0.5,
  valign = 0.5,
  expand = 0,
  crop = FALSE,
  ...
) {
  box <- unname(sf::st_bbox(x))
  crs <- sf::st_crs(x)$wkt

  rasterpic_img_impl(
    box = box,
    img = img,
    halign = halign,
    valign = valign,
    expand = expand,
    crop = crop,
    crs = crs
  )
}

#' @rdname rasterpic_img
#' @export
rasterpic_img.bbox <- function(
  x,
  img,
  halign = 0.5,
  valign = 0.5,
  expand = 0,
  crop = FALSE,
  ...,
  crs = NULL
) {
  x <- sf::st_as_sfc(x)

  crs_orig <- sf::st_crs(x)
  if (is.na(crs_orig)) {
    sf::st_crs(x) <- unique(c(crs, NA))[1]
  }

  rasterpic_img(
    x,
    img = img,
    halign = halign,
    valign = valign,
    expand = expand,
    crop = crop
  )
}

#' @rdname rasterpic_img
#' @export
rasterpic_img.numeric <- function(
  x,
  img,
  halign = 0.5,
  valign = 0.5,
  expand = 0,
  crop = FALSE,
  ...,
  crs = NULL
) {
  if (length(x) != 4) {
    cli::cli_abort("Cannot extract a bounding box from {.arg x}.")
  }

  rasterpic_img_impl(
    box = x,
    img = img,
    halign = halign,
    valign = valign,
    expand = expand,
    crop = crop,
    crs = crs
  )
}

#' @rdname rasterpic_img
#' @export
rasterpic_img.SpatRaster <- function(
  x,
  img,
  halign = 0.5,
  valign = 0.5,
  expand = 0,
  crop = FALSE,
  ...
) {
  processed <- rpic_input_spat(x)

  box <- processed$box
  x <- processed$x
  crs <- processed$crs

  rasterpic_img_impl(
    box = box,
    img = img,
    halign = halign,
    valign = valign,
    expand = expand,
    crop = crop,
    crs = crs
  )
}

#' @rdname rasterpic_img
#' @export
rasterpic_img.SpatVector <- function(
  x,
  img,
  halign = 0.5,
  valign = 0.5,
  expand = 0,
  crop = FALSE,
  ...,
  mask = FALSE,
  inverse = FALSE
) {
  processed <- rpic_input_spat(x)

  box <- processed$box
  x <- processed$x
  crs <- processed$crs

  new_rast <- rasterpic_img_impl(
    box = box,
    img = img,
    halign = halign,
    valign = valign,
    expand = expand,
    crop = crop,
    crs = crs
  )

  # Mask the raster when requested. ----

  if (mask) {
    # Match the vector CRS to the output raster.
    terra::crs(x) <- terra::crs(new_rast)
    new_rast <- terra::mask(new_rast, x, inverse = inverse)
  }

  add_rgb_channels(new_rast)
}

#' @rdname rasterpic_img
#' @export
rasterpic_img.SpatExtent <- function(
  x,
  img,
  halign = 0.5,
  valign = 0.5,
  expand = 0,
  crop = FALSE,
  ...,
  crs = NULL
) {
  box <- c(terra::xmin(x), terra::ymin(x), terra::xmax(x), terra::ymax(x))

  rasterpic_img_impl(
    box = box,
    img = img,
    halign = halign,
    valign = valign,
    expand = expand,
    crop = crop,
    crs = crs
  )
}

rasterpic_img_impl <- function(
  box,
  img,
  halign = 0.5,
  valign = 0.5,
  expand = 0,
  crop = FALSE,
  crs = NULL,
  ...
) {
  # Validate alignment inputs.
  rpic_check_unit_interval(halign, "halign")
  rpic_check_unit_interval(valign, "valign")

  # Normalize missing CRS values.
  crs <- rpic_crs(crs)

  if (!nzchar(crs)) {
    cli::cli_alert_info("No CRS supplied in {.arg crs}.")
  } else if (terra::is.lonlat(crs, warn = FALSE)) {
    cli::cli_alert_info(
      "{.arg x} uses geographic coordinates. Assuming planar coordinates."
    )
  }

  # A. Read the `img` file. ----
  rast <- rpic_read(img, crs)

  # Warn when the image does not have the expected number of layers.
  if (terra::nlyr(rast) < 3) {
    n_layers <- terra::nlyr(rast) # nolint
    cli::cli_alert_warning(paste0(
      "{.arg img} has {.val {n_layers}} layer{?s}, not ",
      "{.val {3}} or {.val {4}}. Result will not have an RGB specification."
    ))
  }

  # B. Geotag the image. ----
  placement <- rpic_place_extent(
    box = box,
    rast = rast,
    halign = halign,
    valign = valign,
    expand = expand
  )

  # Copy the raster before updating its extent.
  new_rast <- rast
  terra::ext(new_rast) <- terra::ext(placement$ext)

  # C. Optionally crop. ----
  new_rast <- rpic_crop(crop, placement$box_marg, new_rast)

  add_rgb_channels(new_rast)
}

add_rgb_channels <- function(new_rast) {
  # Assign RGB if there are at least 3 layers and no RGB specification.
  if (terra::nlyr(new_rast) >= 3) {
    if (!terra::has.RGB(new_rast)) {
      terra::RGB(new_rast) <- c(1, 2, 3)
    }

    # Rename RGB channels.
    nms <- names(new_rast)
    nms[c(1, 2, 3)] <- c("r", "g", "b")

    if (length(nms) >= 4) {
      nms[4] <- "alpha"
    }
    names(new_rast) <- nms
  }

  new_rast
}
