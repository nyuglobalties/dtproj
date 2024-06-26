#' Create a Data Team Pipeline project
#'
#' Sets up the necessary infrastructure to get a pipeline spun up
#' real quick!
#'
#' @param path Where the project should be created. Defaults to
#'   the current working directory.
#' @param force If content already exists in `path`, removes it for
#'   creation of project architecture. **Be careful!!** Use only
#'   when absolutely needed.
#' @return The path of the project, invisibly
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
  asana_notif <- FALSE
  auth_osf <- FALSE
  auth_kobo <- FALSE
  unit_tests <- FALSE

  usethis::with_project(
    path = path,
    code = {
      dt_use_standard_git_ignores()
      usethis::use_directory("R")
      usethis::use_directory("config")

      use_templ(
        "common",
        "utils.R",
        save_as = "R/utils.R"
      )

      use_templ(
        "common", "Renviron",
        save_as = ".Renviron"
      )

      use_templ(
        "common", "environment.R",
        save_as = "config/environment.R"
      )

      asana_notif <- dtprj_use_asana()
      auth_osf <- dtprj_use_osf()
      auth_kobo <- dtprj_use_kobo()

      unit_tests <- dtprj_use_tests()

      engine <- dtprj_use_engine(
        unit_tests = unit_tests,
        auth_kobo = auth_kobo
      )
      renv <- dtprj_use_renv()
    },
    quiet = TRUE
  )

  usethis::ui_done("Project created!")
  info_messages(
    unit_tests = unit_tests
  )

  cat_line()
  message("To Do:")
  todo_messages(
    asana_notif = asana_notif,
    auth_osf = auth_osf,
    auth_kobo = auth_kobo,
    renv = renv
  )

  invisible(path)
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
    asana_notif = "Replace :user and :repo in 'asana-pr-open.yaml'",
    auth_osf = c(
      "Set the 'OSF_PAT' environment variable in your project's .Renviron to your OSF token. ",
      "See details here: https://docs.ropensci.org/osfr/articles/auth"
    ),
    auth_kobo = c(
      "Set the 'KPI_TOKEN' environment variable in your project's .Renviron to your KPI token. ",
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

info_messages <- function(...) {
  post_messages(
    "info",
    ...
  )
}

todo_messages <- function(...) {
  post_messages(
    "todo",
    ...
  )
}
