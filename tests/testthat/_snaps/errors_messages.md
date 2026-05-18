# Error on bad x formatting

    Code
      rasterpic_img(x, img)
    Condition
      Error in `rasterpic_img.numeric()`:
      ! Cannot extract a bounding box from 'x'.

# Error on bad img formatting

    Code
      rasterpic_img(x, img)
    Condition
      Error:
      ! File supplied to 'img' not found.

---

    Code
      rasterpic_img(x, img2)
    Condition
      Error:
      ! Only 'png', 'jpg', 'jpeg', 'tif' and 'tiff' files are accepted for 'img'.

# Error on invalid parameters

    Code
      rasterpic_img(x, img, valign = 1.2)
    Condition
      Error in `rasterpic_img_impl()`:
      ! 'valign' must be between 0 and 1.

---

    Code
      rasterpic_img(x, img, valign = -1.2)
    Condition
      Error in `rasterpic_img_impl()`:
      ! 'valign' must be between 0 and 1.

---

    Code
      rasterpic_img(x, img, halign = 1.2)
    Condition
      Error in `rasterpic_img_impl()`:
      ! 'halign' must be between 0 and 1.

---

    Code
      rasterpic_img(x, img, halign = -1.2)
    Condition
      Error in `rasterpic_img_impl()`:
      ! 'halign' must be between 0 and 1.

