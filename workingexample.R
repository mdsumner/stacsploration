library(rstac)
s <- stac("https://earth-search.aws.element84.com/v0")

ex <- c(147.0446, 147.5354, -43.03, -42.6697) ## Hobart
items <- s  |>  stac_search(collections = "sentinel-s2-l2a-cogs",
                       bbox = ex[c(1, 3, 2, 4)],
                       datetime = paste0(Sys.Date() + c(-155, 0), collapse = "/"),
                       limit = 500) |>
  post_request()




stac <- get_stac(items)

library(dplyr)
a <- lapply(stac$assets, \(.x) filter(.x, title == "True color image"))[[1]]
plot(stac$geom)
maps::map(add = TRUE)
library(tidyr)
library(dplyr)
library(vapour)
#tn <- unnest(stac, cols = c(assets)) |> filter(title == "Thumbnail") |> slice(1) |> pull(href)
## get all of the True color images
tc <- unnest(stac, cols = c(assets)) |> filter(title == "True color image", roles == "overview")  |> pull(href)
info <- vapour_raster_info(tc[1])


## but, see from properties that we have overlaps, so we probably want to group by these rather than date time
files <- unnest(stac, cols = c(properties, assets)) |> filter(title == "True color image", roles == "overview") |>
  select(`sentinel:grid_square`, `sentinel:latitude_band`, datetime, href, geom)
## there's only two grid squares
plot(files$geom)
files <- files[grep("TCI", files$href), ]
## so now we have grid square EN,DN for each date
files$href[1:2]
im <- gdal_raster_image(files$href[1:2], target_dim = c(512, 0))
ximage(im)
