# Test vector

    Code
      raster <- rasterpic_img(x, img)
    Message
      i No CRS was supplied in `crs`.

---

    Code
      rasterpic_img(x[1:3], img)
    Condition
      Error in `rasterpic_img()`:
      ! Cannot extract a bounding box from `x`.

