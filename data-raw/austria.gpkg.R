## code to prepare `Austria.gpkg` dataset goes here

library(dplyr)
library(giscoR)
library(sf)

austria <- gisco_get_nuts(
  country = "Austria", nuts_level = 0, resolution = 60,
  epsg = 3035
)


austria <- austria %>%
  mutate(name = "Austria") %>%
  select(name)
plot(austria)

austria <- st_make_valid(austria)

st_write(austria, "inst/gpkg/austria.gpkg", append = FALSE)

# Check

austria_test <- st_read("inst/gpkg/austria.gpkg")
plot(austria_test)
