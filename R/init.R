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

post_messages <- function(type, ...) {
  known_messages <- list(
    auth_osf = c(
        "Set the 'OSF_PAT' environment variable in your .Renviron to your OSF token. ",
        "See details here: https://docs.ropensci.org/osfr/articles/auth"
    ),
    auth_kobo = c(
        "Set the 'KPI_TOKEN' environment variable in your .Renviron to your KPI token. ",
        "See details here: https://support.kobotoolbox.org/api.html#getting-your-api-token"
    ),
    renv = "Run `renv::init()`",
    unit_tests = "See the testthat docs to learn how to create your own tests"
    )

  args <- list(...)
  struct <- lapply(names(args), function(nx) {
    if (!nx %in% names(known_messages)) {
      stop0("Message ID not found in `known_messages`: '", nx, "'")
    }

    list(
      value = args[[nx]],
      msg = known_messages[[nx]]
  )
  })

  for (el in struct) {
    if (isTRUE(el$value)) {
      switch(type,
        todo = usethis::ui_todo(el$msg),
        info = usethis::ui_info(el$msg)
      )
    }
  }
}

info_messages <- function(
  unit_tests = FALSE
) {
  post_messages(
    "info",
    unit_tests = unit_tests
  )
  }

todo_messages <- function(
  auth_osf = FALSE,
  auth_kobo = FALSE,
  renv = FALSE
) {
  post_messages(
    "todo",
    auth_osf = auth_osf,
    auth_kobo = auth_kobo,
    renv = renv
  )
}