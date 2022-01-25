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
  } else if (inherits(x, "sf") | inherits(x, "sfc")) {
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

rpic_read <- function(img, crs) {
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


    rast <- terra::rast(pngfile,
      crs = crs
    )

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
