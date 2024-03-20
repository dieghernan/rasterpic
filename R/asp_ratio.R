#' Compute aspect ratio of an object
#'
#' @description
#' Helper function. Ratio is computed as width/height (or col/rows).
#'
#' @param x A `SpatRaster` object, an `sf/sfc` object or a numeric vector of
#'   length 4 with coordinates c(`xmin`, `ymin`, `xmax`, `ymax`), as created by
#'   [sf::st_bbox()].
#'
#' @return The aspect ratio
#' @export
#' @keywords internal
#' @examples
#' \donttest{
#' library(terra)
#'
#' x <- rast(system.file("tiff/elev.tiff", package = "rasterpic"))
#' plot(x)
#' asp_ratio(x)
#' }
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
