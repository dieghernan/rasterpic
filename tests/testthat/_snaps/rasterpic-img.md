# unsupported S3 classes report the missing rasterpic_img() method

    Code
      rasterpic_img(x, NULL)
    Condition
      Error in `rasterpic_img()`:
      ! S3 method `rasterpic_img()` is not implemented for <character> objects.

---

    Code
      rasterpic_img(x, NULL)
    Condition
      Error in `rasterpic_img()`:
      ! S3 method `rasterpic_img()` is not implemented for <foo.bar> objects.

# numeric input with the wrong length reports bbox requirements

    Code
      rasterpic_img(x, img)
    Condition
      Error in `rasterpic_img()`:
      ! `x` must be a numeric vector of length 4.
      i Use `c(xmin, ymin, xmax, ymax)` order for bounding box coordinates.

# missing files and unsupported extensions report actionable errors

    Code
      rasterpic_img(x, img)
    Condition
      Error in `rasterpic_img()`:
      ! File 'nofile' supplied to `img` does not exist.

---

    Code
      rasterpic_img(x, img2)
    Condition
      Error in `rasterpic_img()`:
      ! Unsupported `img` extension "gpkg".
      i `img` must use one of: "png", "jpg", "jpeg", "tif", and "tiff".

# alignment values outside the unit interval report their bounds

    Code
      rasterpic_img(x, img, valign = 1.2)
    Condition
      Error in `rasterpic_img()`:
      ! `valign` must be from 0 to 1, inclusive.

---

    Code
      rasterpic_img(x, img, valign = -1.2)
    Condition
      Error in `rasterpic_img()`:
      ! `valign` must be from 0 to 1, inclusive.

---

    Code
      rasterpic_img(x, img, halign = 1.2)
    Condition
      Error in `rasterpic_img()`:
      ! `halign` must be from 0 to 1, inclusive.

---

    Code
      rasterpic_img(x, img, halign = -1.2)
    Condition
      Error in `rasterpic_img()`:
      ! `halign` must be from 0 to 1, inclusive.

# nonscalar and nonnumeric alignments report scalar requirements

    Code
      rasterpic_img(x, img, halign = NA_real_)
    Condition
      Error in `rasterpic_img()`:
      ! `halign` must be a single number from 0 to 1, inclusive.

---

    Code
      rasterpic_img(x, img, halign = c(0, 1))
    Condition
      Error in `rasterpic_img()`:
      ! `halign` must be a single number from 0 to 1, inclusive.

---

    Code
      rasterpic_img(x, img, valign = "top")
    Condition
      Error in `rasterpic_img()`:
      ! `valign` must be a single number from 0 to 1, inclusive.

---

    Code
      rasterpic_img(x, img, halign = 0.5 + 0+0i)
    Condition
      Error in `rasterpic_img()`:
      ! `halign` must be a single number from 0 to 1, inclusive.

# invalid image arguments report a scalar path requirement

    Code
      rasterpic_img(x, NA_character_)
    Condition
      Error in `rasterpic_img()`:
      ! `img` must be a single nonempty string containing a file path or URL.

---

    Code
      rasterpic_img(x, character())
    Condition
      Error in `rasterpic_img()`:
      ! `img` must be a single nonempty string containing a file path or URL.

---

    Code
      rasterpic_img(x, c("a.png", "b.png"))
    Condition
      Error in `rasterpic_img()`:
      ! `img` must be a single nonempty string containing a file path or URL.

---

    Code
      rasterpic_img(x, "")
    Condition
      Error in `rasterpic_img()`:
      ! `img` must be a single nonempty string containing a file path or URL.

# invalid expansion values report finite nonnegative requirements

    Code
      rasterpic_img(x, img, expand = -0.1)
    Condition
      Error in `rasterpic_img()`:
      ! `expand` must be a single finite number greater than or equal to 0.

---

    Code
      rasterpic_img(x, img, expand = Inf)
    Condition
      Error in `rasterpic_img()`:
      ! `expand` must be a single finite number greater than or equal to 0.

---

    Code
      rasterpic_img(x, img, expand = c(0, 1))
    Condition
      Error in `rasterpic_img()`:
      ! `expand` must be a single finite number greater than or equal to 0.

# nonlogical control flags report TRUE or FALSE requirements

    Code
      rasterpic_img(bbox, img, crop = NA)
    Condition
      Error in `rasterpic_img()`:
      ! `crop` must be TRUE or FALSE.

---

    Code
      rasterpic_img(x, img, mask = 1)
    Condition
      Error in `rasterpic_img()`:
      ! `mask` must be TRUE or FALSE.

---

    Code
      rasterpic_img(x, img, inverse = NA)
    Condition
      Error in `rasterpic_img()`:
      ! `inverse` must be TRUE or FALSE.

# invalid CRS values report optional scalar string requirements

    Code
      rasterpic_img(x, img, crs = 4326)
    Condition
      Error in `rasterpic_img()`:
      ! `crs` must be `NULL`, `NA` or a single string.

---

    Code
      rasterpic_img(x, img, crs = c("EPSG:4326", "EPSG:3857"))
    Condition
      Error in `rasterpic_img()`:
      ! `crs` must be `NULL`, `NA` or a single string.

# geographic sf input warns before planar placement

    Code
      s <- rasterpic_img(x, img)
    Condition
      Warning:
      `x` uses geographic coordinates. Treating them as planar.

# geographic SpatRaster input warns before planar placement

    Code
      s <- rasterpic_img(x, img)
    Condition
      Warning:
      `x` uses geographic coordinates. Treating them as planar.

# single-layer input warns and remains without RGB metadata

    Code
      raster <- rasterpic_img(x, img)
    Condition
      Warning:
      The file supplied to `img` has 1 layer, not 3 or 4. The result will not have an RGB specification.

# two-layer input warns and remains without RGB metadata

    Code
      r_new <- rasterpic_img(x2, tmp_tiff)
    Condition
      Warning:
      The file supplied to `img` has 2 layers, not 3 or 4. The result will not have an RGB specification.

# download warnings become rasterpic_img() errors with their cause

    Code
      rasterpic_img(x, img)
    Condition
      Error in `rasterpic_img()`:
      ! Cannot download `img` from <http://this_is_an_error_url.fake>.
      Caused by warning in `rpic_download_file()`:
      ! Cannot open URL

# download errors become rasterpic_img() errors with their cause

    Code
      rasterpic_img(x, img)
    Condition
      Error in `rasterpic_img()`:
      ! Cannot download `img` from <http://this_is_an_error_url.fake>.
      Caused by error in `rpic_download_file()`:
      ! Cannot open URL

# nonzero download statuses become rasterpic_img() errors

    Code
      rasterpic_img(x, img)
    Condition
      Error in `rasterpic_img()`:
      ! Cannot download `img` from <http://this_is_an_error_url.fake>.

# sfg input uses empty CRS when none is supplied

    Code
      raster <- rasterpic_img(x, img)
    Message
      i No CRS was supplied via `crs`.

# SpatExtent input uses empty CRS when none is supplied

    Code
      raster <- rasterpic_img(x, img)
    Message
      i No CRS was supplied via `crs`.

# stars input expands to contain the source bounds

    Code
      raster <- rasterpic_img(x, img)
    Condition
      Warning:
      `x` uses geographic coordinates. Treating them as planar.

# stars input uses empty CRS when none is supplied

    Code
      raster <- rasterpic_img(x, img)
    Message
      i No CRS was supplied via `crs`.

# numeric bounding box input uses empty CRS when none is supplied

    Code
      raster <- rasterpic_img(x, img)
    Message
      i No CRS was supplied via `crs`.

---

    Code
      rasterpic_img(x[1:3], img)
    Condition
      Error in `rasterpic_img()`:
      ! `x` must be a numeric vector of length 4.
      i Use `c(xmin, ymin, xmax, ymax)` order for bounding box coordinates.

# numeric bounding box input rejects invalid coordinates

    Code
      rasterpic_img(c(NA, 0, 1, 1), img)
    Condition
      Error in `rasterpic_img()`:
      ! `x` must contain finite bounding box coordinates.

---

    Code
      rasterpic_img(c(0, 0, Inf, 1), img)
    Condition
      Error in `rasterpic_img()`:
      ! `x` must contain finite bounding box coordinates.

---

    Code
      rasterpic_img(c(1, 0, 0, 1), img)
    Condition
      Error in `rasterpic_img()`:
      ! `x` must be ordered as `c(xmin, ymin, xmax, ymax)` with `xmax` > `xmin` and `ymax` > `ymin`.

---

    Code
      rasterpic_img(c(0, 0, 1, 0), img)
    Condition
      Error in `rasterpic_img()`:
      ! `x` must be ordered as `c(xmin, ymin, xmax, ymax)` with `xmax` > `xmin` and `ymax` > `ymin`.

