#' Compute aspect ratio of an object
#'
#' @description
#' Helper function. Ratio is computed as width/height (or col/rows).
#' @param x A `SpatRaster` object, an `sf/sfc` object or a numeric vector of
#'   length 4 with coordinates c(`xmin`, `ymin`, `xmax`, `ymax`), as created by
#'   [sf::st_bbox()]
#'
#' @return The aspect ratio
#' @export
#' @examples
#'
#' library(terra)
#'
#' x <- rast(system.file("tiff/elev.tiff", package = "rasterpic"))
#' plot(x)
#' asp_ratio(x)
asp_ratio <- function(x) {
  if (inherits(x, "SpatRaster")) {
    ratio <- terra::ncol(x) / terra::nrow(x)
  } else if (inherits(x, "sf") || inherits(x, "sfc")) {
    bbox <- as.double(sf::st_bbox(x))
    ratio <- (bbox[3] - bbox[1]) / (bbox[4] - bbox[2])
  } else if (length(x) == 4 && is.numeric(x)) {
    # Case of a bbox xmin, ymin, xmax, ymax
    ratio <- (x[3] - x[1]) / (x[4] - x[2])
  } else {
    stop("Don't know how to compute the ratio", call. = FALSE)
  }

  ratio <- as.double(ratio)
  return(ratio)
}

rpic_crop <- function(crop, box_marg, new_rast) {
  if (crop) {
    crop_extent <- terra::ext(
      box_marg[c(1, 3, 2, 4)]
    )
    new_rast <- terra::crop(
      new_rast,
      crop_extent
    )
  }

  return(new_rast)
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
        return(TRUE)
      },
      error = function(x) {
        return(TRUE)
      }
    )

    # On error
    if (err_dwnload) {
      stop("Cannot reach img on url ",
        img,
        call. = FALSE
      )
    }
    # nocov end
    # If everything is well, rename img
    img <- tmp
  }

  if (!file.exists(img)) stop("'img' file not found", call. = FALSE)

  # pngs
  if (tools::file_ext(img) %in% c("png")) {
    pngfile <- png::readPNG(img) * 255
    # Give transparency if available
    if (dim(pngfile)[3] == 4) {
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
    stop("'img' only accepts 'png', 'jpg' or 'jpeg' files",
      call. = FALSE
    )
  }
}


rpic_input <- function(x, crs) {
  # Convert sf to SpatVector

  if (inherits(x, "sf") || inherits(x, "sfc")) {
    x <- terra::vect(x)
  }

  if (inherits(x, "SpatRaster") || inherits(x, "SpatVector")) {
    if (terra::is.lonlat(x)) {
      message(
        "Warning: x has geographic coordinates. ",
        "Assuming planar coordinates."
      )
    }

    crs <- terra::crs(x)

    box <- c(
      terra::xmin(x),
      terra::ymin(x),
      terra::xmax(x),
      terra::ymax(x)
    )
  } else if (inherits(x, "sfg")) {
    x <- terra::vect(x)
    box <- c(
      terra::xmin(x),
      terra::ymin(x),
      terra::xmax(x),
      terra::ymax(x)
    )
  } else if (inherits(x, "SpatExtent")) {
    box <- c(
      terra::xmin(x),
      terra::ymin(x),
      terra::xmax(x),
      terra::ymax(x)
    )
  } else if (inherits(x, "bbox") && length(x) == 4) {
    box <- c(
      x["xmin"],
      x["ymin"],
      x["xmax"],
      x["ymax"]
    )
    box <- unname(box)
  } else if (is.numeric(x) && length(x) == 4) {
    box <- c(
      x[1],
      x[2],
      x[3],
      x[4]
    )
  } else {
    stop("Don't know how to extract a bounding box from 'x'")
  }



  if (missing(crs)) {
    message("'crs' is NA.")
    crs <- NA
  }

  # Output object is a list
  result <- list(
    x = x,
    box = box,
    crs = crs
  )

  return(result)
}
