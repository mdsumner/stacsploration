## features
##   have geometry
##   have assets
##      have names and href


## functions for items from stac_search() |> post_request()
get_geom <- function(x) {
  ## assuming POLYGON
  poly <- \(.x ) wk::wk_polygon(wk::xy(.x[,1], .x[,2]))
  get_coords <- \(.x) do.call(rbind, .x$coordinates[[1]])
  do.call(c, lapply(x$features, \(.x) poly( get_coords(.x$geometry))))
}
get_properties <- function(x) {
  lapply(x$features, \(.x) tibble::as_tibble(.x$properties))
}
get_stac <- function(x) {
  get_assets <- function(.x) {
    title <- .x$title
    hrefs <- .x$href
    tibble::tibble(title = rep(title, length(hrefs)), href = hrefs, roles = .x$roles)
  }
  get_ids <- function(x) {
    vapply(x$features, \(.x) .x$id, "")
  }
  tibble::tibble(id = get_ids(x), assets =  lapply(x$features, function(.x) do.call(rbind, lapply(.x$assets, get_assets))),
                 properties = get_properties(x),
                 geom = get_geom(x))
}
