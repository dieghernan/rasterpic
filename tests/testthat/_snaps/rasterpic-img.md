# rasterpic_img() errors for unsupported S3 classes

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

# rasterpic_img() errors for invalid numeric coordinates

    Code
      rasterpic_img(x, img)
    Condition
      Error in `rasterpic_img()`:
      ! `x` must be a numeric vector of length 4.
      i Use `c(xmin, ymin, xmax, ymax)` order for bounding box coordinates.

# rasterpic_img() errors for missing and unsupported image files

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

# rasterpic_img() errors for alignment values outside [0, 1]

    Code
      rasterpic_img(x, img, valign = 1.2)
    Condition
      Error in `rasterpic_img()`:
      ! `valign` must be between 0 and 1.

---

    Code
      rasterpic_img(x, img, valign = -1.2)
    Condition
      Error in `rasterpic_img()`:
      ! `valign` must be between 0 and 1.

---

    Code
      rasterpic_img(x, img, halign = 1.2)
    Condition
      Error in `rasterpic_img()`:
      ! `halign` must be between 0 and 1.

---

    Code
      rasterpic_img(x, img, halign = -1.2)
    Condition
      Error in `rasterpic_img()`:
      ! `halign` must be between 0 and 1.

# rasterpic_img() errors for invalid alignment types

    Code
      rasterpic_img(x, img, halign = NA_real_)
    Condition
      Error in `rasterpic_img()`:
      ! `halign` must be a number between 0 and 1.

---

    Code
      rasterpic_img(x, img, halign = c(0, 1))
    Condition
      Error in `rasterpic_img()`:
      ! `halign` must be a number between 0 and 1.

---

    Code
      rasterpic_img(x, img, valign = "top")
    Condition
      Error in `rasterpic_img()`:
      ! `valign` must be a number between 0 and 1.

# rasterpic_img() informs for geographic sf coordinates

    Code
      s <- rasterpic_img(x, img)
    Message
      i `x` uses geographic coordinates. Assuming planar coordinates.

# rasterpic_img() informs for geographic raster coordinates

    Code
      s <- rasterpic_img(x, img)
    Message
      i `x` uses geographic coordinates. Assuming planar coordinates.

# single-layer images warn and do not get RGB metadata

    Code
      raster <- rasterpic_img(x, img)
    Condition
      Warning:
      The file supplied to `img` has 1 layer, not 3 or 4. The result will not have an RGB specification.

# two-layer images warn and do not get RGB metadata

    Code
      r_new <- rasterpic_img(x2, tmp_tiff)
    Condition
      Warning:
      The file supplied to `img` has 2 layers, not 3 or 4. The result will not have an RGB specification.

# remote image download warnings become rasterpic_img() errors

    Code
      rasterpic_img(x, img)
    Condition
      Error in `rasterpic_img()`:
      ! Cannot download `img` from <http://this_is_an_error_url.fake>.

# sfg input uses empty CRS when none is supplied

    Code
      raster <- rasterpic_img(x, img)
    Message
      i No CRS was supplied in `crs`.

# SpatExtent input uses empty CRS when none is supplied

    Code
      raster <- rasterpic_img(x, img)
    Message
      i No CRS was supplied in `crs`.

# stars input expands to contain the source bounds

    Code
      raster <- rasterpic_img(x, img)
    Message
      i `x` uses geographic coordinates. Assuming planar coordinates.

# stars input uses empty CRS when none is supplied

    Code
      raster <- rasterpic_img(x, img)
    Message
      i No CRS was supplied in `crs`.

# numeric bounding box input uses empty CRS when none is supplied

    Code
      raster <- rasterpic_img(x, img)
    Message
      i No CRS was supplied in `crs`.

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

