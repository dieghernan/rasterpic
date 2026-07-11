testhelp_load_rast <- function(path) {
  ext <- tools::file_ext(path)
  tmp_dir <- withr::local_tempdir(.local_envir = parent.frame())
  tmp <- withr::local_tempfile(
    tmpdir = tmp_dir,
    fileext = paste0(".", ext),
    .local_envir = parent.frame()
  )
  file.copy(path, tmp, overwrite = TRUE)

  x <- terra::rast(tmp)

  x
}

testhelp_logo_url <- function() {
  paste0(
    "https://raw.githubusercontent.com/dieghernan/rasterpic/",
    "main/man/figures/logo.png"
  )
}
