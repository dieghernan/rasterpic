# Changelog

## rasterpic 0.3.0

CRAN release: 2025-03-19

- When the output has 3 or more layers, the first three are renamed as
  `"r", "g", "b"`. In cases with 4 layers or more the fourth layer is
  renames as `"alpha"`. This allows compatibility with **tmap** `>= 4.0`
  avoiding error
  `! [subset] you cannot select a layer with a name that is not unique`.

## rasterpic 0.2.6

CRAN release: 2024-12-17

- Update documentation.

## rasterpic 0.2.5

CRAN release: 2024-04-12

- Update documentation.
- Title and Description of the package are more specific.

## rasterpic 0.2.4

CRAN release: 2024-01-18

- Ensure `SpatVector`s always have `crs`.
- If the image has less than 3 channels the raster output does not have
  the property RGB
  ([`terra::has.RGB()`](https://rspatial.github.io/terra/reference/RGB.html)
  is `FALSE`). This is expected to be a corner case.
- If the image file (i.e. `tiff`) already has a RGB definition, keep
  that in the output.
- Update docs and tests.

## rasterpic 0.2.3

CRAN release: 2023-09-08

- Now
  [`asp_ratio()`](https://dieghernan.github.io/rasterpic/reference/asp_ratio.md)
  is an internal function.
- Improve docs and tests.

## rasterpic 0.2.2

CRAN release: 2023-04-18

- Remove unused dependencies
- Improve docs.
- Fix typos on messages.
- Declares output as RGB raster with
  [`terra::RGB()`](https://rspatial.github.io/terra/reference/RGB.html).
- Add **ggplot2** to “Suggests”.

## rasterpic 0.2.1

CRAN release: 2022-06-10

- Add **tidyterra** to “Suggests”.

## rasterpic 0.2.0

CRAN release: 2022-02-18

- Add support for:
  - **terra**: `SpatVector`, `SpatExtent`.
  - **sf**: `sfg`,
    [`sf::st_bbox()`](https://r-spatial.github.io/sf/reference/st_bbox.html).
  - Numeric vectors `c(xmin, ymin, xmax, ymax).`
- Now `img` parameter on
  [`rasterpic_img()`](https://dieghernan.github.io/rasterpic/reference/rasterpic_img.md)
  accepts online images.
- Add an
  [article](https://dieghernan.github.io/rasterpic/articles/plots.html)
  to the pkgdown site.
- Fix **CRAN** errors.

## rasterpic 0.1.0

CRAN release: 2022-01-27

- Initial release
