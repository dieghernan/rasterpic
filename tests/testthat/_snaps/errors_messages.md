# Error on bad x formatting

    Code
      rasterpic_img(x, img)
    Condition
      Error in `rpic_input()`:
      ! Don't know how to extract a bounding box from 'x'

# Error on bad img formatting

    Code
      rasterpic_img(x, img)
    Condition
      Error:
      ! 'img' file not found

---

    Code
      rasterpic_img(x, img2)
    Condition
      Error:
      ! 'img' only accepts 'png', 'jpg' or 'jpeg' files

# Error on invalid parameters

    Code
      rasterpic_img(x, img, valign = 1.2)
    Condition
      Error in `rasterpic_img()`:
      ! 'valign' should be between 0 and 1

---

    Code
      rasterpic_img(x, img, valign = -1.2)
    Condition
      Error in `rasterpic_img()`:
      ! 'valign' should be between 0 and 1

---

    Code
      rasterpic_img(x, img, halign = 1.2)
    Condition
      Error in `rasterpic_img()`:
      ! 'halign' should be between 0 and 1

---

    Code
      rasterpic_img(x, img, halign = -1.2)
    Condition
      Error in `rasterpic_img()`:
      ! 'halign' should be between 0 and 1

