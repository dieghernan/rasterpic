# rasterpic 0.5.1

- User-facing errors, warnings and notes now use **cli** alerts and inline
  markup for consistent argument, file and URL formatting.
- `rasterpic_img()` with `mask = TRUE`, `inverse = TRUE` or both again returns a
  `SpatRaster` with an RGB specification (`terra::has.RGB()` returns `TRUE`).

# rasterpic 0.5.0

- Package documentation was reviewed and updated with AI-assisted editing.
- `rasterpic_img()` is now an S3 generic with methods for supported spatial
  input classes (#39).
- `rasterpic_img()` now supports `stars` objects.

# rasterpic 0.4.0

- Migrated vignettes to Quarto.

# rasterpic 0.3.1

- New logo.
- The minimum required **R** version is now 4.1.0.
- Minor internal and documentation improvements.

# rasterpic 0.3.0

- When the output has 3 or more layers, the first three are renamed as `"r"`,
  `"g"` and `"b"`. In cases with 4 layers or more, the fourth layer is renamed
  as `"alpha"`. This allows compatibility with **tmap** `>= 4.0` and avoids the
  error `! [subset] you cannot select a layer with a name that is not unique`.

# rasterpic 0.2.6

- Updated documentation.

# rasterpic 0.2.5

- Updated documentation.
- Made the `Title` and `Description` fields in `DESCRIPTION` more specific.

# rasterpic 0.2.4

- Ensured that `SpatVector` objects always have a CRS.
- If the image has fewer than 3 layers, the raster output does not have an RGB
  specification (`terra::has.RGB()` is `FALSE`). This is expected to be a corner
  case.
- If the image file (e.g., `tiff`) already has an RGB specification, preserve it
  in the output.
- Updated documentation and tests.

# rasterpic 0.2.3

- Made `asp_ratio()` an internal function.
- Improved documentation and tests.

# rasterpic 0.2.2

- Removed unused dependencies.
- Improved documentation.
- Fixed typos in messages.
- Declared the output as an RGB raster with `terra::RGB()`.
- Added **ggplot2** to "Suggests".

# rasterpic 0.2.1

- Added **tidyterra** to "Suggests".

# rasterpic 0.2.0

- Added support for:
  - **terra**: `SpatVector`, `SpatExtent`.
  - **sf**: `sfg`, `sf::st_bbox()`.
  - Numeric vectors `c(xmin, ymin, xmax, ymax)`.
- The `img` parameter in `rasterpic_img()` now accepts image URLs.
- Added an [article](https://dieghernan.github.io/rasterpic/articles/plots.html)
  to the pkgdown site.
- Fixed **CRAN** errors.

# rasterpic 0.1.0

- Initial release.
