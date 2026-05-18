rpic_crop <- function(crop, box_marg, new_rast) {
  if (crop) {
    crop_extent <- terra::ext(box_marg[c(1, 3, 2, 4)])
    new_rast <- terra::crop(new_rast, crop_extent)
  }

  new_rast
}

rpic_read <- function(img, crs = NA) {
  # Download `img` to a temporary file when it is a URL.
  if (grepl("^http:|^https:", img)) {
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

    if (err_dwnload) {
      stop(sprintf("Cannot reach 'img' URL '%s'.", img), call. = FALSE)
    }

    # Use the downloaded file path for `img`.
    img <- tmp
  }

  if (!file.exists(img)) {
    stop("File supplied to 'img' not found.", call. = FALSE)
  }

  if (!tools::file_ext(img) %in% c("jpg", "jpeg", "tif", "tiff", "png")) {
    stop(
      paste0(
        "Only 'png', 'jpg', 'jpeg', 'tif' and 'tiff' files are ",
        "accepted for 'img'."
      ),
      call. = FALSE
    )
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

rpic_input_spat <- function(x) {
  box <- c(terra::xmin(x), terra::ymin(x), terra::xmax(x), terra::ymax(x))
  list(x = x, box = box, crs = terra::crs(x))
}

rpic_crs <- function(crs) {
  if (any(is.null(crs), is.na(crs))) {
    return("")
  }

  crs
}
