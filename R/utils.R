rpic_crop <- function(crop, box_marg, new_rast) {
  if (crop) {
    crop_extent <- terra::ext(box_marg[c(1, 3, 2, 4)])
    new_rast <- terra::crop(new_rast, crop_extent)
  }

  new_rast
}

rpic_read <- function(img, crs = NA) {
  img <- rpic_local_img(img)
  rpic_check_img_ext(img)

  ext <- tools::file_ext(img)

  if (ext == "png") {
    rast <- rpic_read_png(img)
  } else {
    rast <- rpic_read_raster_img(img)
  }

  terra::crs(rast) <- crs
  rast
}

rpic_local_img <- function(img) {
  if (grepl("^http:|^https:", img)) {
    tmp <- tempfile(fileext = paste0(".", tools::file_ext(img)))

    err_dwnload <- tryCatch(
      utils::download.file(img, tmp, quiet = TRUE, mode = "wb"),
      warning = function(x) {
        TRUE
      },
      error = function(x) {
        TRUE # nocov
      }
    )

    if (err_dwnload) {
      cli::cli_abort(
        "Cannot download {.arg img} from {.url {img}}.",
        call = sys.call(-1)
      )
    }

    # Use the downloaded file path for `img`.
    img <- tmp
  }

  if (!file.exists(img)) {
    cli::cli_abort(
      "File supplied to {.arg img} does not exist.",
      call = sys.call(-1)
    )
  }

  img
}

rpic_check_img_ext <- function(img) {
  if (!tools::file_ext(img) %in% c("jpg", "jpeg", "tif", "tiff", "png")) {
    cli::cli_abort(
      paste0(
        "{.arg img} must have extension {.val png}, {.val jpg}, ",
        "{.val jpeg}, {.val tif} or {.val tiff}."
      ),
      call = sys.call(-1)
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

rpic_check_unit_interval <- function(x, arg) {
  if (x < 0 || x > 1) {
    cli::cli_abort(
      "{.arg {arg}} must be between 0 and 1.",
      call = sys.call(-1)
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
