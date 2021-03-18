dtprj_use_engine <- function(
  path = usethis::proj_get(),
  struct_mode = "vanilla",
  ...
) {
  usethis::ui_info(paste0(
    "Available engines are ",
    "{ui_value('targets')} and {ui_value('drake')}"
  ))
  eng <- tolower(readline("Which engine would you like to use? [targets] "))

  if (identical(eng, "") || identical(eng, "targets")) {
    eng <- "targets"
  } else if (identical(eng, "drake")) {
    usethis::ui_warn(c(
      "drake has been superseded by targets.",
      "It is prefered to use drake on a UNIX-like system.",
      "It has difficulties on Windows."
    ))
    eng <- "drake"
  } else {
    dtproj_abort(
      "Unknown engine selected. Please try again.",
      path = path
    )
  }

  switch(eng,
    targets = dtprj_use_targets(struct_mode, ...),
    drake = dtprj_use_drake(struct_mode, ...)
  )

  eng
}

dtprj_use_drake <- function(struct_mode, ...) {
  dat_list <- list(...)
  dat_list[["engine"]] <- quote(drake)

  use_templ(
    struct_mode,
    "_drake.R",
    save_as = "_drake.R",
    data = dat_list
  )

  use_templ(
    struct_mode,
    "plan.R",
    save_as = "config/plan.R"
  )

  use_templ(
    struct_mode,
    "packages.R",
    save_as = "config/packages.R",
    data = dat_list
  )

  dt_git_ignore(".drake", path = usethis::proj_get())
}

dtprj_use_targets <- function(struct_mode, ...) {
  dat_list <- list(...)
  dat_list[["engine"]] <- quote(targets)

  use_templ(
    struct_mode,
    "_targets.R",
    save_as = "_targets.R",
    data = dat_list
  )

  use_templ(
    struct_mode,
    "packages.R",
    save_as = "config/packages.R",
    data = dat_list
  )

  dt_git_ignore("_targets", path = usethis::proj_get())
}