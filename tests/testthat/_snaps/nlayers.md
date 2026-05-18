# Check how it works with single layers files

    Code
      raster <- rasterpic_img(x, img)
    Condition
      Warning in `rasterpic_img_impl()`:
      'img' has 1 layer, not 3 or 4 layers. Result does not have an RGB property.

# Check how it works with 2 layer file

    Code
      r_new <- rasterpic_img(x2, tmp_tiff)
    Condition
      Warning in `rasterpic_img_impl()`:
      'img' has 2 layers, not 3 or 4 layers. Result does not have an RGB property.

