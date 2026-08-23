#' Compute the aspect ratio of spatial input
#'
#' @description
#' Compute the aspect ratio as width divided by height or columns divided by
#' rows.
#'
#' @param x A `SpatRaster`, `sf` or `sfc` object or a numeric vector
#'   of length 4 with coordinates `c(xmin, ymin, xmax, ymax)`, as created by
#'   [sf::st_bbox()].
#'
#' @returns A numeric scalar giving the aspect ratio.
#' @family geotagging
#' @keywords internal
#' @export
#' @encoding UTF-8
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
    # Handle a bounding box in `xmin`, `ymin`, `xmax`, `ymax` order.
    ratio <- (x[3] - x[1]) / (x[4] - x[2])
  } else {
    cli::cli_abort(c(
      "Cannot compute the aspect ratio of {.arg x}.",
      "i" = paste0(
        "{.arg x} must be a {.cls SpatRaster}, {.cls sf} or {.cls sfc} ",
        "object or a numeric vector of length {.val {4}}."
      )
    ))
  }

  ratio <- as.double(ratio)
  ratio
}
