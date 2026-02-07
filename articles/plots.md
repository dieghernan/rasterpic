# Plotting \*\*terra\*\* rasters

This article shows how to plot the `SpatRaster` produced by
[`rasterpic_img()`](https://dieghernan.github.io/rasterpic/reference/rasterpic_img.md)
with several packages.

## Base plots

The most straightforward option is to use the base
[`plot()`](https://rspatial.github.io/terra/reference/plot.html) methods
provided by the package **terra**
([`terra::plotRGB()`](https://rspatial.github.io/terra/reference/plotRGB.html)):

``` r
library(rasterpic)
library(terra)

# The flag of the United Kingdom
img <- system.file("img/UK_flag.png",
  package = "rasterpic"
)

uk <- sf::st_read(
  system.file("gpkg/UK.gpkg",
    package = "rasterpic"
  ),
  quiet = TRUE
)

uk_img <- rasterpic_img(uk, img, mask = TRUE, inverse = TRUE)
plotRGB(uk_img)
```

![Example: plot with terra package](plots_files/figure-html/setup-1.png)

## With ggplot2 + tidyterra

**tidyterra** provides full support for **terra** `SpatRaster` objects:

``` r
library(ggplot2)
library(tidyterra)

ggplot() +
  geom_spatraster_rgb(data = uk_img)
```

![Example: plot with tidyterra
package](plots_files/figure-html/tterra-1.png)

## With tmap

**tmap** can also be used to create great maps:

``` r
library(tmap)

tm_shape(uk_img) +
  tm_graticules() +
  tm_rgb()
```

![Example: plot with tmap package](plots_files/figure-html/tmap-1.png)

## With mapsf

**mapsf** also provides this functionality:

``` r
library(mapsf)

mf_raster(uk_img)
mf_scale()
mf_inset_on(x = "worldmap", pos = "topright")
mf_worldmap(uk)
mf_inset_off()
```

![Example: plot with mapsf package](plots_files/figure-html/mapsf-1.png)

## With maptiles

**maptiles** is an interesting package that provides the ability to
download map tiles from different providers. It also has a specific
function for plotting **terra** `SpatRaster` objects:

``` r
library(maptiles)

other_tile <- get_tiles(uk, crop = TRUE, zoom = 6)

other_tile_crop <- terra::crop(other_tile, uk_img)

plot_tiles(other_tile_crop)
plot_tiles(uk_img, add = TRUE)
```

![Example: plot with maptiles
package](plots_files/figure-html/maptiles-1.png)

## References

Tennekes M (2018). “tmap: Thematic Maps in R.” *Journal of Statistical
Software*, **84**(6), 1–39.
[doi:10.18637/jss.v084.i06](https://doi.org/10.18637/jss.v084.i06).

Giraud T (2026). *mapsf: Thematic Cartography*.
[doi:10.32614/CRAN.package.mapsf](https://doi.org/10.32614/CRAN.package.mapsf).

Hernangómez D (2023). “Using the tidyverse with terra objects: the
tidyterra package.” *Journal of Open Source Software*, **8**(91), 5751.
ISSN 2475-9066,
[doi:10.21105/joss.05751](https://doi.org/10.21105/joss.05751),
<https://doi.org/10.21105/joss.05751>.

Hijmans R (2026). *terra: Spatial Data Analysis*. R package version
1.8-93, <https://rspatial.org/>.

Wickham H (2016). *ggplot2: Elegant Graphics for Data Analysis*.
Springer-Verlag New York. ISBN 978-3-319-24277-4,
<https://ggplot2.tidyverse.org>.

## Session info

Details

    #> ─ Session info ───────────────────────────────────────────────────────────────
    #>  setting  value
    #>  version  R version 4.5.2 (2025-10-31 ucrt)
    #>  os       Windows Server 2022 x64 (build 26100)
    #>  system   x86_64, mingw32
    #>  ui       RTerm
    #>  language en
    #>  collate  English_United States.utf8
    #>  ctype    English_United States.utf8
    #>  tz       UTC
    #>  date     2026-02-07
    #>  pandoc   3.1.11 @ C:/HOSTED~1/windows/pandoc/31F387~1.11/x64/PANDOC~1.11/ (via rmarkdown)
    #>  quarto   NA
    #> 
    #> ─ Packages ───────────────────────────────────────────────────────────────────
    #>  package      * version   date (UTC) lib source
    #>  abind          1.4-8     2024-09-12 [1] RSPM
    #>  base64enc      0.1-6     2026-02-02 [1] RSPM
    #>  bslib          0.10.0    2026-01-26 [1] RSPM
    #>  cachem         1.1.0     2024-05-16 [1] RSPM
    #>  class          7.3-23    2025-01-01 [3] CRAN (R 4.5.2)
    #>  classInt       0.4-11    2025-01-08 [1] RSPM
    #>  cli            3.6.5     2025-04-23 [1] RSPM
    #>  codetools      0.2-20    2024-03-31 [3] CRAN (R 4.5.2)
    #>  colorspace     2.1-2     2025-09-22 [1] RSPM
    #>  cols4all       0.10      2025-10-27 [1] RSPM
    #>  crosstalk      1.2.2     2025-08-26 [1] RSPM
    #>  curl           7.0.0     2025-08-19 [1] RSPM
    #>  data.table     1.18.2.1  2026-01-27 [1] RSPM
    #>  DBI            1.2.3     2024-06-02 [1] RSPM
    #>  desc           1.4.3     2023-12-10 [1] RSPM
    #>  digest         0.6.39    2025-11-19 [1] RSPM
    #>  dplyr          1.2.0     2026-02-03 [1] RSPM
    #>  e1071          1.7-17    2025-12-18 [1] RSPM
    #>  evaluate       1.0.5     2025-08-27 [1] RSPM
    #>  farver         2.1.2     2024-05-13 [1] RSPM
    #>  fastmap        1.2.0     2024-05-15 [1] RSPM
    #>  fs             1.6.6     2025-04-12 [1] RSPM
    #>  generics       0.1.4     2025-05-09 [1] RSPM
    #>  ggplot2      * 4.0.2     2026-02-03 [1] RSPM
    #>  glue           1.8.0     2024-09-30 [1] RSPM
    #>  gtable         0.3.6     2024-10-25 [1] RSPM
    #>  htmltools      0.5.9     2025-12-04 [1] RSPM
    #>  htmlwidgets    1.6.4     2023-12-06 [1] RSPM
    #>  jquerylib      0.1.4     2021-04-26 [1] RSPM
    #>  jsonlite       2.0.0     2025-03-27 [1] RSPM
    #>  KernSmooth     2.23-26   2025-01-01 [3] CRAN (R 4.5.2)
    #>  knitr          1.51      2025-12-20 [1] RSPM
    #>  lattice        0.22-7    2025-04-02 [3] CRAN (R 4.5.2)
    #>  leafem         0.2.5     2025-08-28 [1] RSPM
    #>  leaflegend     1.2.1     2024-05-09 [1] RSPM
    #>  leaflet        2.2.3     2025-09-04 [1] RSPM
    #>  leafsync       0.1.0     2019-03-05 [1] RSPM
    #>  lifecycle      1.0.5     2026-01-08 [1] RSPM
    #>  logger         0.4.1     2025-09-11 [1] RSPM
    #>  lwgeom         0.2-15    2026-01-12 [1] RSPM
    #>  magrittr       2.0.4     2025-09-12 [1] RSPM
    #>  maplegend      0.5.0     2026-01-10 [1] RSPM
    #>  mapsf        * 1.1.0     2026-01-10 [1] RSPM
    #>  maptiles     * 0.11.0    2025-12-12 [1] RSPM
    #>  otel           0.2.0     2025-08-29 [1] RSPM
    #>  pillar         1.11.1    2025-09-17 [1] RSPM
    #>  pkgconfig      2.0.3     2019-09-22 [1] RSPM
    #>  pkgdown        2.2.0     2025-11-06 [1] RSPM
    #>  png            0.1-8     2022-11-29 [1] RSPM
    #>  proxy          0.4-29    2025-12-29 [1] RSPM
    #>  purrr          1.2.1     2026-01-09 [1] RSPM
    #>  R6             2.6.1     2025-02-15 [1] RSPM
    #>  ragg           1.5.0     2025-09-02 [1] RSPM
    #>  raster         3.6-32    2025-03-28 [1] RSPM
    #>  rasterpic    * 0.3.1     2026-02-07 [1] local
    #>  RColorBrewer   1.1-3     2022-04-03 [1] RSPM
    #>  Rcpp           1.1.1     2026-01-10 [1] RSPM
    #>  rlang          1.1.7     2026-01-09 [1] RSPM
    #>  rmarkdown      2.30      2025-09-28 [1] RSPM
    #>  s2             1.1.9     2025-05-23 [1] RSPM
    #>  S7             0.2.1     2025-11-14 [1] RSPM
    #>  sass           0.4.10    2025-04-11 [1] RSPM
    #>  scales         1.4.0     2025-04-24 [1] RSPM
    #>  sessioninfo  * 1.2.3     2025-02-05 [1] any (@1.2.3)
    #>  sf             1.0-24    2026-01-13 [1] RSPM
    #>  sp             2.2-0     2025-02-01 [1] RSPM
    #>  spacesXYZ      1.6-0     2025-06-06 [1] RSPM
    #>  stars          0.7-0     2025-12-14 [1] RSPM
    #>  systemfonts    1.3.1     2025-10-01 [1] RSPM
    #>  terra        * 1.8-93    2026-01-12 [1] RSPM
    #>  textshaping    1.0.4     2025-10-10 [1] RSPM
    #>  tibble         3.3.1     2026-01-11 [1] RSPM
    #>  tidyr          1.3.2     2025-12-19 [1] RSPM
    #>  tidyselect     1.2.1     2024-03-11 [1] RSPM
    #>  tidyterra    * 1.0.0     2026-01-23 [1] RSPM
    #>  tmap         * 4.2       2025-09-10 [1] RSPM
    #>  tmaptools      3.3       2025-07-24 [1] RSPM
    #>  units          1.0-0     2025-10-09 [1] RSPM
    #>  vctrs          0.7.1     2026-01-23 [1] RSPM
    #>  withr          3.0.2     2024-10-28 [1] RSPM
    #>  wk             0.9.5     2025-12-18 [1] RSPM
    #>  xfun           0.56      2026-01-18 [1] RSPM
    #>  XML            3.99-0.20 2025-11-08 [1] RSPM
    #>  yaml           2.3.12    2025-12-10 [1] RSPM
    #> 
    #>  [1] D:/a/_temp/Library
    #>  [2] C:/R/site-library
    #>  [3] C:/R/library
    #>  * ── Packages attached to the search path.
    #> 
    #> ──────────────────────────────────────────────────────────────────────────────
