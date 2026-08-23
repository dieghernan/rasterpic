# unit interval validation reports invalid type, length and range

    Code
      rpic_check_unit_interval(NA_real_, "halign")
    Condition
      Error:
      ! `halign` must be a single number from 0 to 1, inclusive.

---

    Code
      rpic_check_unit_interval(c(0, 1), "halign")
    Condition
      Error:
      ! `halign` must be a single number from 0 to 1, inclusive.

---

    Code
      rpic_check_unit_interval("top", "valign")
    Condition
      Error:
      ! `valign` must be a single number from 0 to 1, inclusive.

---

    Code
      rpic_check_unit_interval(-0.1, "valign")
    Condition
      Error:
      ! `valign` must be from 0 to 1, inclusive.

---

    Code
      rpic_check_unit_interval(1.1, "valign")
    Condition
      Error:
      ! `valign` must be from 0 to 1, inclusive.

# bounding box validation reports length, finiteness and ordering

    Code
      rpic_check_bbox(c(1, 2, 3), "x")
    Condition
      Error:
      ! `x` must be a numeric vector of length 4.
      i Use `c(xmin, ymin, xmax, ymax)` order for bounding box coordinates.

---

    Code
      rpic_check_bbox(c(NA, 0, 1, 1), "x")
    Condition
      Error:
      ! `x` must contain finite bounding box coordinates.

---

    Code
      rpic_check_bbox(c(0, 0, Inf, 1), "x")
    Condition
      Error:
      ! `x` must contain finite bounding box coordinates.

---

    Code
      rpic_check_bbox(c(1, 0, 0, 1), "x")
    Condition
      Error:
      ! `x` must be ordered as `c(xmin, ymin, xmax, ymax)` with `xmax` > `xmin` and `ymax` > `ymin`.

---

    Code
      rpic_check_bbox(c(0, 0, 1, 0), "x")
    Condition
      Error:
      ! `x` must be ordered as `c(xmin, ymin, xmax, ymax)` with `xmax` > `xmin` and `ymax` > `ymin`.

---

    Code
      rpic_check_bbox(c(0, 0, 1, 1) + 0+0i, "x")
    Condition
      Error:
      ! `x` must be a numeric vector of length 4.
      i Use `c(xmin, ymin, xmax, ymax)` order for bounding box coordinates.

