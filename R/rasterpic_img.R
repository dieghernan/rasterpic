#' Convert an image into a geotagged `SpatRaster`
#'
#' @description
#'
#' Geotags an image based on the coordinates of a spatial object.
#'
#' `rasterpic_img()` is an S3 generic. \CRANpkg{rasterpic} provides methods for
#' the following classes:
#'
#' `r doclisting::methods_list("rasterpic_img")`
#'
#' @rdname rasterpic_img
#' @param x An **R** object (see **S3 methods**).
#'
#' @param img An image to be geotagged. It can be a local file or a URL
#'   (e.g. `"https://i.imgur.com/6yHmlwT.jpeg"`). Accepted extensions are
#'   `png`, `jpeg`/`jpg` and `tiff`/`tif`.
#'
#' @param halign A number between `0` and `1` giving the horizontal alignment of
#'   `img` relative to `x`. `0` aligns `x` with the left edge, `1` aligns with
#'   the right edge and `0.5` centers it horizontally.
#' @param valign A number between `0` and `1` giving the vertical alignment of
#'   `img` relative to `x`. `0` aligns `x` with the bottom edge, `1` aligns with
#'   the top edge and `0.5` centers it vertically.
#' @seealso `vignette("rasterpic", package = "rasterpic")` for examples.
#'
#' @param expand An expansion factor of the bounding box of `x`. `0` means that
#'   no expansion is added, `1` means that the bounding box is expanded to
#'   double the original size. See **Details**.
#'
#' @param crop Logical. Should the raster be cropped to the (expanded) bounding
#'   box of `x`? See **Details**.
#'
#' @param mask Logical, available for vector methods. Should the raster be
#'   [masked][terra::mask] to the shape of `x`? See **Details**.
#'
#' @param inverse Logical. This only has an effect when `mask = TRUE`. If
#'   `TRUE`, areas of the raster covered by `x` are masked.
#'
#' @param crs Character string describing a CRS. This parameter only applies
#'   when `x` is a `SpatExtent`, `sfg`, `bbox` or a numeric coordinate vector.
#'   See **CRS** section.
#'
#' @param ... Further arguments passed to methods.
#'
#' @return
#' A `SpatRaster` object (see [terra::rast()]) where each layer corresponds to
#' a color channel of `img`:
#'
#' - If `img` has at least 3 layers, the result will have
#'   an additional property setting layers 1 to 3 as the red, green and blue
#'   channels with names `"r"`, `"g"` and `"b"` and `alpha` if applicable.
#' - If `img` already has a definition of RGB values (this may be the case for
#'   `tiff`/`tif` files) the result will keep that channel definition.
#'
#' The resulting `SpatRaster` will have an RGB specification as explained in
#' `terra::RGB()`.
#'
#' @details
#'
#' `vignette("rasterpic", package = "rasterpic")` explains, with examples, the
#' effect of parameters `halign`, `valign`, `expand`, `crop` and `mask`.
#'
#' ## S3 methods
#'
#' \CRANpkg{rasterpic} supports the following input classes:
#'
#' - **sf** classes: `sf`, `sfc`, `sfg` or `bbox`.
#' - **terra** classes: `SpatRaster`, `SpatVector` and `SpatExtent`.
#' - **stars** classes: `stars`.
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
#' `crs` can be in a WKT format, as a `"authority:number"` code such as
#' `"EPSG:4326"` or a PROJ-string format such as `"+proj=utm +zone=12"`. It can
#' also be retrieved with:
#'
#' - [`sf::st_crs(25830)$wkt`][sf::st_crs].
#' - [terra::crs()].
#' - [tidyterra::pull_crs()].
#'
#' See **Value** and **Notes** in [terra::crs()].
#'
#' @seealso
#'
#' From \CRANpkg{sf}:
#'
#' - [sf::st_crs()].
#' - [sf::st_bbox()].
#' - `vignette("sf1", package = "sf")` to understand how \CRANpkg{sf} organizes
#'   **R** objects.
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
#' # Default configuration.
#' ex1 <- rasterpic_img(x, img)
#'
#' ex1
#'
#' autoplot(ex1) +
#'   geom_sf(data = x, fill = NA, color = "white", linewidth = 0.5)
#'
#' # Expand.
#' ex2 <- rasterpic_img(x, img, expand = 0.5)
#'
#' autoplot(ex2) +
#'   geom_sf(data = x, fill = NA, color = "white", linewidth = 0.5)
#'
#' # Align.
#' ex3 <- rasterpic_img(x, img, halign = 0)
#'
#' autoplot(ex3) +
#'   geom_sf(data = x, fill = NA, color = "white", linewidth = 0.5)
#' labs(title = "Align")
#'
#' # Crop.
#' ex4 <- rasterpic_img(x, img, crop = TRUE)
#'
#' autoplot(ex4) +
#'   geom_sf(data = x, fill = NA, color = "white", linewidth = 0.5) +
#'   labs(title = "Crop")
#'
#' # Mask.
#' ex5 <- rasterpic_img(x, img, mask = TRUE)
#'
#' autoplot(ex5) +
#'   geom_sf(data = x, fill = NA, color = "white", linewidth = 0.5) +
#'   labs(title = "Mask")
#'
#' # Inverse mask.
#' ex6 <- rasterpic_img(x, img, mask = TRUE, inverse = TRUE)
#'
#' autoplot(ex6) +
#'   geom_sf(data = x, fill = NA, color = "white", linewidth = 0.5) +
#'   labs(title = "Mask Inverse")
#'
#' # Combine inverse masking and cropping.
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
  # Report unsupported S3 classes clearly.
  msg <- paste0(
    "S3 method `rasterpic_img` not implemented for `",
    paste0(class(x), collapse = "."),
    "` objects."
  )
  stop(msg)
}

#' @rdname rasterpic_img
#' @export
#' @encoding UTF-8
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
#' @encoding UTF-8
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
#' @encoding UTF-8
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
#' @encoding UTF-8
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
#' @encoding UTF-8
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
#' @encoding UTF-8
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
    stop("Cannot extract a bounding box from 'x'.")
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
#' @encoding UTF-8
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
#' @encoding UTF-8
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

  # Optionally mask the raster. ----

  if (mask) {
    # Ensure the same CRS.
    terra::crs(x) <- terra::crs(new_rast)
    new_rast <- terra::mask(new_rast, x, inverse = inverse)
  }

  new_rast
}

#' @rdname rasterpic_img
#' @export
#' @encoding UTF-8
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
  if (halign < 0 || halign > 1) {
    stop("'halign' must be between 0 and 1.")
  }
  if (valign < 0 || valign > 1) {
    stop("'valign' must be between 0 and 1.")
  }

  # Normalize missing CRS values.
  crs <- rpic_crs(crs)

  if (crs == "") {
    message("Argument 'crs' is NA.")
  } else if (terra::is.lonlat(crs, warn = FALSE)) {
    message(
      "Input 'x' has geographic coordinates. ",
      "Assuming planar coordinates."
    )
  }

  # A. Read the `img` file. ----
  rast <- rpic_read(img, crs)

  # Warn when the image does not have the expected number of layers.
  if (terra::nlyr(rast) < 3) {
    n_layers <- terra::nlyr(rast)
    warning(
      "'img' has ",
      n_layers,
      " ",
      if (n_layers == 1) "layer" else "layers",
      ", not 3 or 4 layers. ",
      "Result does not have an RGB property."
    )
  }

  # B. Geotag the image. ----
  ## 1. Create an expanded bounding box. ----
  innermarg <- min((box[3] - box[1]), (box[4] - box[2])) * expand

  box_marg <- box + c(rep(-innermarg, 2), rep(innermarg, 2))

  ## 2. Adjust extent. ----
  # Compute the raster width-height ratio.
  ratio_raster <- asp_ratio(rast)
  ratio_x <- asp_ratio(box_marg)

  # Use planar coordinates from this point onward.
  # Compute width and height of `x` after expansion.
  w <- box_marg[3] - box_marg[1]
  h <- box_marg[4] - box_marg[2]

  # Place the raster relative to `x`.
  if (ratio_x <= ratio_raster) {
    # Adjust the width.
    new_h <- h
    y_init <- box_marg[2]

    new_w <- h * ratio_raster
    # Apply horizontal alignment.
    x_init <- box_marg[1] - halign * (new_w - w)
  } else {
    # Adjust the height.
    new_w <- w
    x_init <- box_marg[1]

    new_h <- w / ratio_raster
    # Apply vertical alignment.
    y_init <- box_marg[2] - valign * (new_h - h)
  }

  # Create the final raster extent.
  ext <- c(x_init, x_init + new_w, y_init, y_init + new_h)

  # Copy the raster before updating its extent.
  new_rast <- rast
  terra::ext(new_rast) <- terra::ext(ext)

  # C. Optionally crop. ----
  new_rast <- rpic_crop(crop, box_marg, new_rast)

  # Assign RGB if there are at least 3 layers and no RGB definition.
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
