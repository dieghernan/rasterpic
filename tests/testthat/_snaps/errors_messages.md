# Error on bad x formatting

    Code
      rasterpic_img(x, img)
    Condition
      Error in `rasterpic_img()`:
      ! Cannot extract a bounding box from `x`.

# Error on bad img formatting

    Code
      rasterpic_img(x, img)
    Condition
      Error in `rpic_read()`:
      ! File supplied to `img` does not exist.

---

    Code
      rasterpic_img(x, img2)
    Condition
      Error in `rpic_read()`:
      ! `img` must have extension "png", "jpg", "jpeg", "tif" or "tiff".

# Error on invalid parameters

    Code
      rasterpic_img(x, img, valign = 1.2)
    Condition
      Error in `rasterpic_img_impl()`:
      ! `valign` must be between 0 and 1.

---

    Code
      rasterpic_img(x, img, valign = -1.2)
    Condition
      Error in `rasterpic_img_impl()`:
      ! `valign` must be between 0 and 1.

---

    Code
      rasterpic_img(x, img, halign = 1.2)
    Condition
      Error in `rasterpic_img_impl()`:
      ! `halign` must be between 0 and 1.

---

    Code
      rasterpic_img(x, img, halign = -1.2)
    Condition
      Error in `rasterpic_img_impl()`:
      ! `halign` must be between 0 and 1.

# Message in lonlat sf

    Code
      s <- rasterpic_img(x, img)
    Message
      i `x` uses geographic coordinates. Assuming planar coordinates.

# Message in lonlat raster

    Code
      s <- rasterpic_img(x, img)
    Message
      i `x` uses geographic coordinates. Assuming planar coordinates.

