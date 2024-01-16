## code to prepare `UK.gpkg` dataset goes here

library(dplyr)
library(giscoR)
library(sf)

UK <- gisco_get_nuts(
  country = "UK", nuts_level = 0, resolution = 60,
  epsg = 3857
)


UK <- UK %>%
  mutate(name = "United Kingdom") %>%
  select(name)
plot(UK)

UK <- st_make_valid(UK)

st_write(UK, "inst/gpkg/UK.gpkg", append = FALSE)

# Check

UK_test <- st_read("inst/gpkg/UK.gpkg")
plot(UK_test)
