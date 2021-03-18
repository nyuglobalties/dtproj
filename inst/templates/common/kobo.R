KPI_CACHE_LOCATION <- here::here("_kobocache")

#' Retrieve an object from the KoBo cache
#'
#' By default, objects downloaded from KoBo will be stored in the "_kobocache"
#' folder. In that folder there are two folders: "meta" and "assets".
#' The "meta" stores serialized JSON metadata objects, and the
#' "assets" folder keeps the downloads in RDS format. If the requested object
#' doesn't exist in the cache or is outdated, the most recently updated
#' object will be downloaded.
#'
#' @param asset_id The asset ID on KoBo for the desired object.
#' @param cache_dir The KoBo cache location.
#' @param create_cache_dir Create the cache directories if they don't exist.
#' @param ... Parameters passed to `karpi::kpi_get_data()`
#' @return The current JSON list associated with the requested object
#' @export
kpicache_get <- function(
  asset_id, 
  cache_dir = KPI_CACHE_LOCATION,
  create_cache_dir = TRUE,
  ...
) {
  kpicache <- kpicache_init(cache_dir, create_cache_dir)
  meta_dir <- kpicache$meta

  remote_meta <- karpi::kpi_asset_info(asset_id)

  is_outdated <- kpicache_is_outdated(
    asset_id,
    cache_dir = cache_dir,
    create_cache_dir = create_cache_dir
  )

  if (!is_outdated) {
    active_meta <- readRDS(file.path(meta_dir, asset_id))
  } else {
    active_meta <- kpicache_download(remote_meta, kpicache, ...)
  }

  active_meta
}

#' Check to see if cache is outdated
#'
#' Fetches the most recent meta with asset ID `asset_id` to see if
#' 1. the requested object exists in the cache
#' 1. the cache's version of the object is outdated
#'
#' @param asset_id A KoBo asset ID
#' @param cache_dir Where the cache is located
#' @param create_cache_dir If cache dir doesn't exist it, create it if TRUE
#' @return Logical if the cache is outdated
#'
#' @export
kpicache_is_outdated <- function(
  asset_id,
  cache_dir = KPI_CACHE_LOCATION,
  create_cache_dir = TRUE
) {
  kpicache <- kpicache_init(cache_dir, create_cache_dir)
  meta_dir <- kpicache$meta
  asset_dir <- kpicache$asset

  remote_meta <- karpi::kpi_asset_info(asset_id)

  if (file.exists(file.path(meta_dir, asset_id))) {
    cached_meta <- readRDS(file.path(meta_dir, asset_id))

    return(kpi_last_updated(remote_meta) > kpi_last_updated(cached_meta))
  }

  TRUE
}

kpicache_init <- function(cache_dir, create_cache_dir) {
  meta_dir <- file.path(cache_dir, "meta")
  asset_dir <- file.path(cache_dir, "assets")

  if (!dir.exists(meta_dir) || !dir.exists(asset_dir)) {
    if (!isTRUE(create_cache_dir)) {
      stop0(
        "KoBo cache directories not found. ",
        "Set `create_cache_dir` to `TRUE` to automatically create them."
      )
    }

    dir.create(meta_dir, recursive = TRUE)
    dir.create(asset_dir, recursive = TRUE)
  }

  list(
    meta = meta_dir,
    asset = asset_dir
  )
}

kpicache_download <- function(asset_info, kpicache, ...) {
  asset_id <- kpi_asset_id(asset_info)
  target_path <- file.path(kpicache$asset, asset_id)

  data <- karpi::kpi_get_data(asset_id, ...)

  asset_info$local_path <- target_path
  saveRDS(data, file = target_path)
  saveRDS(asset_info, file = file.path(kpicache$meta, asset_id))

  asset_info
}

kpi_asset_id <- function(asset_info) {
  asset_info$uid
}

kpi_path <- function(asset_info) {
  asset_info$local_path
}

kpi_last_updated <- function(asset_info) {
  lubridate::ymd_hms(asset_info$date_modified)
}

kpi_get <- function(asset_id, ...) {
  current <- kpicache_get(asset_id, ...)
  readRDS(kpi_path(current))
}

kpi_get_nogroups <- function(asset_id, ...) {
  current <- kpicache_get(asset_id, ...)
  data <- readRDS(kpi_path(current))

  data %>% 
    dplyr::as_tibble() %>% 
    dplyr::rename_with(
      .cols = matches("^(?:group_.*\\/)+([a-zA-Z0-9._]+)$"),
      .fn = function(x) {
        gsub("^(?:group_.*\\/)+([a-zA-Z0-9._]+)$", "\\1", x, perl = TRUE)
      }
    )
}