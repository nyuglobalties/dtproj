#' @export
init <- function(path = ".", force = FALSE) {
  if (!interactive()) {
    usethis::ui_stop("Please use dtproj::init() interactively")
  }

  path <- normalizePath(path, mustWork = FALSE)

  if (isTRUE(force)) {
    usethis::ui_info("Purging contents of {path}")
    purge_dir(path)
  }

  check_path_existing(path)
  usethis::create_project(path, rstudio = TRUE, open = FALSE)
  
  dt_use_git(path)

  renv <- FALSE
  auth_osf <- FALSE
  auth_kobo <- FALSE
  unit_tests <- FALSE

  usethis::with_project(path, {
    usethis::use_directory("R")
    usethis::use_directory("config")

    auth_osf <- dtprj_use_osf()
    auth_kobo <- dtprj_use_kobo()

    unit_tests <- dtprj_use_tests()

    engine <- dtprj_use_engine(
      unit_tests = unit_tests,
      auth_kobo = auth_kobo
    )
    renv <- dtprj_use_renv()

  })

  todo_messages(
    auth_osf = auth_osf,
    auth_kobo = auth_kobo,
    renv = renv
  )
}

check_path_existing <- function(path) {
  if (!fs::dir_exists(path)) {
    res <- usethis::ui_yeah(c(
      "'{path}' does not exist.",
      "Would you like to create it?"
    ))

    if (isTRUE(res)) {
      fs::dir_create(path, recurse = TRUE)
    }
  }

  if (!fs::is_dir(path)) {
    usethis::ui_stop("Please provide a directory to dtproj::init()")
  }

  if (length(list.files(path)) > 0) {
    usethis::ui_stop(c(
      "dtproj does not support overwriting existing contents.",
      "Please choose another directory."
    ))
  }

  invisible(TRUE)
}

todo_messages <- function(
  auth_osf = FALSE,
  auth_kobo = FALSE,
  renv = FALSE
) {
  struct <- list(
    osf = list(
      value = auth_osf,
      todo = c(
        "Set the 'OSF_PAT' environment variable in your .Renviron to your OSF token. ",
        "See details here: https://docs.ropensci.org/osfr/articles/auth"
      )
    ),
    kobo = list(
      value = auth_kobo,
      todo = c(
        "Set the 'KPI_TOKEN' environment variable in your .Renviron to your KPI token. ",
        "See details here: https://support.kobotoolbox.org/api.html#getting-your-api-token"
      )
    ),
    renv = list(
      value = renv,
      todo = "Run `renv::init()`"
    )
  )

  for (el in struct) {
    if (isTRUE(el$value)) {
      usethis::ui_todo(el$todo)
    }
  }
}