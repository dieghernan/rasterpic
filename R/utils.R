rpic_crop <- function(crop, box_marg, new_rast) {
  if (crop) {
    crop_extent <- terra::ext(box_marg[c(1, 3, 2, 4)])
    new_rast <- terra::crop(new_rast, crop_extent)
  }

  new_rast
}

rpic_read <- function(img, crs = NA) {
  # Try to check if it is a local image or http
  if (grepl("^http:|^https:", img)) {
    # Try to download
    tmp <- tempfile(fileext = paste0(".", tools::file_ext(img)))

    # nocov start
    err_dwnload <- tryCatch(
      download.file(img, tmp,
        quiet = TRUE,
        mode = "wb"
      ),
      warning = function(x) {
        TRUE
      },
      error = function(x) {
        TRUE
      }
    )

    # On error
    if (err_dwnload) {
      stop("Cannot reach img on url ", img, call. = FALSE)
    }
    # nocov end

    # If everything is well, rename img
    img <- tmp
  }

  if (!file.exists(img)) stop("'img' file not found", call. = FALSE)
  # pngs
  if ("png" %in% tools::file_ext(img)) {
    pngfile <- png::readPNG(img) * 255


    # Give transparency if available
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

    return(rast)
  } else if (tools::file_ext(img) %in% c("jpg", "jpeg", "tif", "tiff")) {
    # jpg/jpeg and tif/tiff

    rast <- suppressWarnings(terra::rast(img))
    terra::crs(rast) <- crs
    return(rast)
  } else {
    stop("'img' only accepts 'png', 'jpg' or 'jpeg' files", call. = FALSE)
  }
}


rpic_input <- function(x, crs) {
  # Convert sf to SpatVector
  if (any(inherits(x, "sf"), inherits(x, "sfc"))) {
    x <- terra::vect(x)
  }

  if (any(inherits(x, "SpatRaster"), inherits(x, "SpatVector"))) {
    if (terra::is.lonlat(x)) {
      message(
        "Warning: x has geographic coordinates. ",
        "Assuming planar coordinates."
      )
    }

    crs <- terra::crs(x)
    box <- c(terra::xmin(x), terra::ymin(x), terra::xmax(x), terra::ymax(x))
    # Output object is a list
    result <- list(x = x, box = box, crs = crs)
    return(result)
  }

  # Case of no CRS
  if (inherits(x, "sfg")) {
    x <- terra::vect(x)
    box <- c(terra::xmin(x), terra::ymin(x), terra::xmax(x), terra::ymax(x))
  } else if (inherits(x, "SpatExtent")) {
    box <- c(terra::xmin(x), terra::ymin(x), terra::xmax(x), terra::ymax(x))
  } else if (all(inherits(x, "bbox"), length(x) == 4)) {
    box <- c(x["xmin"], x["ymin"], x["xmax"], x["ymax"])
    box <- unname(box)
  } else if (all(is.numeric(x), length(x) == 4)) {
    box <- c(x[1], x[2], x[3], x[4])
  } else {
    stop("Don't know how to extract a bounding box from 'x'")
  }

  if (any(is.null(crs), is.na(crs))) {
    message("'crs' is NA.")
    crs <- NA
  }

  # Output object is a list
  result <- list(x = x, box = box, crs = crs)

  result
}
