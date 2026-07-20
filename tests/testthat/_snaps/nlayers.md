# Check how it works with single layers files

    Code
      raster <- rasterpic_img(x, img)
    Message
      ! The file supplied to `img` has 1 layer, not 3 or 4. The result will not have an RGB specification.

# Check how it works with 2 layer file

    Code
      r_new <- rasterpic_img(x2, tmp_tiff)
    Message
      ! The file supplied to `img` has 2 layers, not 3 or 4. The result will not have an RGB specification.

