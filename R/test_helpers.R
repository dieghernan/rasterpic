# These functions are used only for testing purposes

# Load a test raster using the temp directory

testhelp_load_rast <- function(path) {
  ext <- tools::file_ext(path)
  tmp <- tempfile(fileext = paste0(".", ext))
  file.copy(path, tmp, overwrite = TRUE)

  x <- terra::rast(tmp)

  x
}
