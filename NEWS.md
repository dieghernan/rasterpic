# rasterpic 0.3.0

-   When the output has 3 or more layers, the first three are renamed as
    `"r", "g", "b"`. In cases with 4 layers or more the fourth layer is renames
    as `"alpha"`. This allows compatibility with **tmap** `>= 4.0` avoiding
    error `! [subset] you cannot select a layer with a name that is not unique`.

# rasterpic 0.2.6

-   Update documentation.

# rasterpic 0.2.5

-   Update documentation.
-   Title and Description of the package are more specific.

# rasterpic 0.2.4

-   Ensure `SpatVector`s always have `crs`.
-   If the image has less than 3 channels the raster output does not have the
    property RGB (`terra::has.RGB()` is `FALSE`). This is expected to be a
    corner case.
-   If the image file (i.e. `tiff`) already has a RGB definition, keep that in
    the output.
-   Update docs and tests.

# rasterpic 0.2.3

-   Now `asp_ratio()` is an internal function.
-   Improve docs and tests.

# rasterpic 0.2.2

-   Remove unused dependencies
-   Improve docs.
-   Fix typos on messages.
-   Declares output as RGB raster with `terra::RGB()`.
-   Add **ggplot2** to "Suggests".

# rasterpic 0.2.1

-   Add **tidyterra** to "Suggests".

# rasterpic 0.2.0

-   Add support for:
    -   **terra**: `SpatVector`, `SpatExtent`.
    -   **sf**: `sfg`, `sf::st_bbox()`.
    -   Numeric vectors `c(xmin, ymin, xmax, ymax).`
-   Now `img` parameter on `rasterpic_img()` accepts online images.
-   Add an [article](https://dieghernan.github.io/rasterpic/articles/plots.html)
    to the pkgdown site.
-   Fix **CRAN** errors.

# rasterpic 0.1.0

-   Initial release
