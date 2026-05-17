rpic_crop <- function(crop, box_marg, new_rast) {
  if (crop) {
    crop_extent <- terra::ext(box_marg[c(1, 3, 2, 4)])
    new_rast <- terra::crop(new_rast, crop_extent)
  }

  new_rast
}

rpic_read <- function(img, crs = NA) {
  # Download `img` when it is a URL.
  if (grepl("^http:|^https:", img)) {
    # Try the download.
    tmp <- tempfile(fileext = paste0(".", tools::file_ext(img)))

    err_dwnload <- tryCatch(
      download.file(img, tmp, quiet = TRUE, mode = "wb"),
      warning = function(x) {
        TRUE
      },
      error = function(x) {
        TRUE # nocov
      }
    )

    # Stop when the download fails.
    if (err_dwnload) {
      stop(sprintf("Cannot reach img on url '%s'.", img), call. = FALSE)
    }

    # Use the downloaded file path for `img`.
    img <- tmp
  }

  if (!file.exists(img)) {
    stop("'img' file not found.", call. = FALSE)
  }

  if (!tools::file_ext(img) %in% c("jpg", "jpeg", "tif", "tiff", "png")) {
    stop("'img' only accepts 'png', 'jpg' or 'jpeg' files.", call. = FALSE)
  }

  # Handle PNG files.
  if ("png" %in% tools::file_ext(img)) {
    pngfile <- png::readPNG(img) * 255

    # Preserve transparency when an alpha channel is available.
    if (all(dim(pngfile)[3] == 4, !is.na(dim(pngfile)[3]))) {
      nrow <- dim(pngfile)[1]

      for (i in seq_len(nrow)) {
        row <- pngfile[i, , ]
        alpha <- row[, 4] == 0
        row[alpha, ] <- NA
        pngfile[i, , ] <- row
      }
    }

    rast <- terra::rast(pngfile)

    terra::crs(rast) <- crs

    rast
  } else if (tools::file_ext(img) %in% c("jpg", "jpeg", "tif", "tiff")) {
    # Handle JPEG and TIFF files.

    rast <- terra::rast(img, noflip = TRUE)
    terra::crs(rast) <- crs
    rast
  }

  rast
}

rpic_input <- function(x, crs = NULL) {
  UseMethod("rpic_input")
}

#' @export
rpic_input.default <- function(x, crs = NULL) {
  stop("Don't know how to extract a bounding box from 'x'.")
}

#' @export
rpic_input.sf <- function(x, crs = NULL) {
  rpic_input(terra::vect(x), crs = crs)
}

#' @export
rpic_input.sfc <- rpic_input.sf

#' @export
rpic_input.SpatRaster <- function(x, crs = NULL) {
  rpic_input_spat(x)
}

#' @export
rpic_input.SpatVector <- function(x, crs = NULL) {
  rpic_input_spat(x)
}

#' @export
rpic_input.sfg <- function(x, crs = NULL) {
  x <- terra::vect(x)
  box <- c(terra::xmin(x), terra::ymin(x), terra::xmax(x), terra::ymax(x))
  rpic_input_box(x = x, box = box, crs = crs)
}

#' @export
rpic_input.SpatExtent <- function(x, crs = NULL) {
  box <- c(terra::xmin(x), terra::ymin(x), terra::xmax(x), terra::ymax(x))
  rpic_input_box(x = x, box = box, crs = crs)
}

#' @export
rpic_input.bbox <- function(x, crs = NULL) {
  box <- c(x["xmin"], x["ymin"], x["xmax"], x["ymax"])
  rpic_input_box(x = x, box = unname(box), crs = crs)
}

#' @export
rpic_input.numeric <- function(x, crs = NULL) {
  if (length(x) != 4) {
    stop("Don't know how to extract a bounding box from 'x'.")
  }

  rpic_input_box(x = x, box = x, crs = crs)
}

rpic_input_spat <- function(x) {
  if (terra::is.lonlat(x)) {
    message(
      "Warning: x has geographic coordinates. ",
      "Assuming planar coordinates."
    )
  }

  box <- c(terra::xmin(x), terra::ymin(x), terra::xmax(x), terra::ymax(x))
  list(x = x, box = box, crs = terra::crs(x))
}

rpic_input_box <- function(x, box, crs) {
  if (any(is.null(crs), is.na(crs))) {
    message("'crs' is NA.")
    crs <- NA
  }

  list(x = x, box = box, crs = crs)
}
