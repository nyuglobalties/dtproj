dtprj_use_asana <- function(path = usethis::proj_get()) {
  res <- ui_yea("Would you like to integrate with Asana?")
  workflow_dir <- ".github/workflows"

  if (res) {
    if (!dir.exists(file.path(path, ".github/workflows"))) {
      usethis::use_directory(".github/workflows")
    }

    use_templ(
      "common",
      "asana-pr-close.yaml",
      save_as = file.path(workflow_dir, "asana-pr-close.yaml")
    )

    use_templ(
      "common",
      "asana-pr-open.yaml",
      save_as = file.path(workflow_dir, "asana-pr-open.yaml")
    )

    usethis::ui_done("Added Github Actions workflows for Asana")
  }

  res
}