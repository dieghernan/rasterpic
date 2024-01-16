# Check how it works with single layers files

    Code
      raster <- rasterpic_img(x, img)
    Condition
      Warning in `rasterpic_img()`:
      img has 1 not 3 or 4
    Message
      Result does not have a RGB property: Missing channels

# Check how it works with 2 layer file

    Code
      r_new <- rasterpic_img(x2, tmp_tiff)
    Condition
      Warning in `rasterpic_img()`:
      img has 2 not 3 or 4
    Message
      Result does not have a RGB property: Missing channels

# Check how it works with 6 layer file

    Code
      r_new <- rasterpic_img(x2, tmp_tiff)
    Message
      img has 8, selecting layers 1 to 3

