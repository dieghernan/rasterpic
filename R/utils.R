rpic_crop <- function(crop, box_marg, new_rast) {
  if (crop) {
    crop_extent <- terra::ext(box_marg[c(1, 3, 2, 4)])
    new_rast <- terra::crop(new_rast, crop_extent)
  }

  new_rast
}

rpic_read <- function(img, crs = NA, call = NULL) {
  img <- rpic_local_img(img, call = call)
  rpic_check_img_ext(img, call = call)

  ext <- tools::file_ext(img)

  if (ext == "png") {
    rast <- rpic_read_png(img)
  } else {
    rast <- rpic_read_raster_img(img)
  }

  terra::crs(rast) <- crs
  rast
}

rpic_local_img <- function(img, call = NULL) {
  if (grepl("^http:|^https:", img)) {
    tmp <- tempfile(fileext = paste0(".", tools::file_ext(img)))

    download_result <- tryCatch(
      rpic_download_file(img, tmp, quiet = TRUE, mode = "wb"),
      warning = identity,
      error = identity
    )

    if (inherits(download_result, "condition")) {
      cli::cli_abort(
        "Cannot download {.arg img} from {.url {img}}.",
        parent = download_result,
        call = call
      )
    }

    if (isTRUE(download_result != 0)) {
      cli::cli_abort(
        "Cannot download {.arg img} from {.url {img}}.",
        call = call
      )
    }

    # Use the downloaded file path for `img`.
    img <- tmp
  }

  if (!file.exists(img)) {
    cli::cli_abort(
      "File {.file {img}} supplied to {.arg img} does not exist.",
      call = call
    )
  }

  img
}

rpic_download_file <- function(url, destfile, quiet = TRUE, mode = "wb", ...) {
  utils::download.file(url, destfile, quiet = quiet, mode = mode, ...)
}

rpic_check_img_ext <- function(img, call = NULL) {
  ext <- tools::file_ext(img)
  supported_ext <- c("png", "jpg", "jpeg", "tif", "tiff")

  if (!ext %in% supported_ext) {
    cli::cli_abort(
      c(
        "Unsupported {.arg img} extension {.val {ext}}.",
        "i" = paste0(
          "{.arg img} must use one of: ",
          "{.val {supported_ext}}."
        )
      ),
      call = call
    )
  }
}

rpic_read_png <- function(img) {
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

  terra::rast(pngfile)
}

rpic_read_raster_img <- function(img) {
  terra::rast(img, noflip = TRUE)
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

rpic_check_img <- function(x, call = NULL) {
  if (
    !is.character(x) ||
      length(x) != 1 ||
      is.na(x) ||
      !nzchar(x)
  ) {
    cli::cli_abort(
      paste0(
        "{.arg img} must be a single nonempty string containing a file path ",
        "or URL."
      ),
      call = call
    )
  }
}

rpic_check_bool <- function(x, arg, call = NULL) {
  if (!is.logical(x) || length(x) != 1 || is.na(x)) {
    cli::cli_abort(
      "{.arg {arg}} must be {.val {TRUE}} or {.val {FALSE}}.",
      call = call
    )
  }
}

rpic_check_expand <- function(x, call = NULL) {
  is_real <- is.double(x) || is.integer(x)

  if (!is_real || length(x) != 1 || is.na(x) || !is.finite(x) || x < 0) {
    cli::cli_abort(
      paste0(
        "{.arg expand} must be a single finite number greater than or equal ",
        "to {.val {0}}."
      ),
      call = call
    )
  }
}

rpic_check_crs <- function(x, call = NULL) {
  is_missing <- length(x) == 1 && is.na(x)

  if (!is.null(x) && !is_missing && (!is.character(x) || length(x) != 1)) {
    cli::cli_abort(
      "{.arg crs} must be {.code NULL}, {.code NA} or a single string.",
      call = call
    )
  }
}

rpic_check_unit_interval <- function(x, arg, call = NULL) {
  is_real <- is.double(x) || is.integer(x)

  if (!is_real || length(x) != 1 || is.na(x)) {
    cli::cli_abort(
      paste0(
        "{.arg {arg}} must be a single number from {.val {0}} to ",
        "{.val {1}}, inclusive."
      ),
      call = call
    )
  }

  if (x < 0 || x > 1) {
    cli::cli_abort(
      paste0(
        "{.arg {arg}} must be from {.val {0}} to {.val {1}}, ",
        "inclusive."
      ),
      call = call
    )
  }
}

rpic_check_bbox <- function(x, arg, call = NULL) {
  is_real <- is.double(x) || is.integer(x)

  if (!is_real || length(x) != 4) {
    cli::cli_abort(
      c(
        "{.arg {arg}} must be a numeric vector of length 4.",
        "i" = paste0(
          "Use {.code c(xmin, ymin, xmax, ymax)} order for bounding box ",
          "coordinates."
        )
      ),
      call = call
    )
  }

  if (!all(is.finite(x))) {
    cli::cli_abort(
      "{.arg {arg}} must contain finite bounding box coordinates.",
      call = call
    )
  }

  if (x[3] <= x[1] || x[4] <= x[2]) {
    cli::cli_abort(
      paste0(
        "{.arg {arg}} must be ordered as {.code c(xmin, ymin, xmax, ymax)} ",
        "with {.var xmax} > {.var xmin} and {.var ymax} > {.var ymin}."
      ),
      call = call
    )
  }
}

rpic_expand_box <- function(box, expand) {
  innermarg <- min((box[3] - box[1]), (box[4] - box[2])) * expand
  box + c(rep(-innermarg, 2), rep(innermarg, 2))
}

rpic_place_extent <- function(
  box,
  rast,
  halign = 0.5,
  valign = 0.5,
  expand = 0
) {
  box_marg <- rpic_expand_box(box, expand)

  ratio_raster <- asp_ratio(rast)
  ratio_x <- asp_ratio(box_marg)

  w <- box_marg[3] - box_marg[1]
  h <- box_marg[4] - box_marg[2]

  if (ratio_x <= ratio_raster) {
    new_h <- h
    y_init <- box_marg[2]

    new_w <- h * ratio_raster
    x_init <- box_marg[1] - halign * (new_w - w)
  } else {
    new_w <- w
    x_init <- box_marg[1]

    new_h <- w / ratio_raster
    y_init <- box_marg[2] - valign * (new_h - h)
  }

  list(
    box_marg = box_marg,
    ext = c(x_init, x_init + new_w, y_init, y_init + new_h)
  )
}
