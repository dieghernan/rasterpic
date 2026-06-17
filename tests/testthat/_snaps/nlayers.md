# Check how it works with single layers files

    Code
      raster <- rasterpic_img(x, img)
    Message
      ! `img` has 1 layer, not 3 or 4. Result will not have an RGB specification.

# Check how it works with 2 layer file

    Code
      r_new <- rasterpic_img(x2, tmp_tiff)
    Message
      ! `img` has 2 layers, not 3 or 4. Result will not have an RGB specification.

