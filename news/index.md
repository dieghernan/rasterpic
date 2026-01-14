# Changelog

## rasterpic 0.3.1

- New logo.
- Minimum **R** version required is now 4.1.0.
- Minor internal and documentation improvements.

## rasterpic 0.3.0

CRAN release: 2025-03-19

- When the output has 3 or more layers, the first three are renamed as
  `"r", "g", "b"`. In cases with 4 layers or more the fourth layer is
  renamed as `"alpha"`. This allows compatibility with **tmap** `>= 4.0`
  avoiding error
  `! [subset] you cannot select a layer with a name that is not unique`.

## rasterpic 0.2.6

CRAN release: 2024-12-17

- Updated documentation.

## rasterpic 0.2.5

CRAN release: 2024-04-12

- Updated documentation.
- `DESCRIPTION` file: Made Title and Description of the package more
  specific.

## rasterpic 0.2.4

CRAN release: 2024-01-18

- Ensured that `SpatVector`s always have `crs`.
- If the image has fewer than 3 channels, the raster output does not
  have the RGB property
  ([`terra::has.RGB()`](https://rspatial.github.io/terra/reference/RGB.html)
  is `FALSE`). This is expected to be a corner case.
- If the image file (e.g., `tiff`) already has an RGB definition,
  preserve it in the output.
- Updated docs and tests.

## rasterpic 0.2.3

CRAN release: 2023-09-08

- Made
  [`asp_ratio()`](https://dieghernan.github.io/rasterpic/reference/asp_ratio.md)
  an internal function.
- Improved docs and tests.

## rasterpic 0.2.2

CRAN release: 2023-04-18

- Removed unused dependencies.
- Improved docs.
- Fixed typos in messages.
- Declared output as RGB raster with
  [`terra::RGB()`](https://rspatial.github.io/terra/reference/RGB.html).
- Added **ggplot2** to “Suggests”.

## rasterpic 0.2.1

CRAN release: 2022-06-10

- Added **tidyterra** to “Suggests”.

## rasterpic 0.2.0

CRAN release: 2022-02-18

- Added support for:
  - **terra**: `SpatVector`, `SpatExtent`.
  - **sf**: `sfg`,
    [`sf::st_bbox()`](https://r-spatial.github.io/sf/reference/st_bbox.html).
  - Numeric vectors `c(xmin, ymin, xmax, ymax)`.
- The `img` parameter in
  [`rasterpic_img()`](https://dieghernan.github.io/rasterpic/reference/rasterpic_img.md)
  now accepts online images.
- Added an
  [article](https://dieghernan.github.io/rasterpic/articles/plots.html)
  to the pkgdown site.
- Fixed **CRAN** errors.

## rasterpic 0.1.0

CRAN release: 2022-01-27

- Initial release.
