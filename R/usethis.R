ui_yea <- function(x) {
  usethis::ui_yeah(
    x,
    yes = "Yes",
    no = "No",
    n_no = 1,
    n_yes = 1
  )
}

ui_no <- function(x) {
  usethis::ui_nope(
    x,
    yes = "Yes",
    no = "No",
    n_no = 1,
    n_yes = 1
  )
}

use_templ <- function(
  struct_mode,
  file,
  ...
) {
  usethis::use_template(
    file.path(struct_mode, file),
    package = "dtproj",
    ...
  )
}