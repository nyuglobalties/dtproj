dtprj_use_renv <- function(path = usethis::proj_get()) {
  res <- ui_yea("Would you like to use renv?")

  if (res) {
    if (!requireNamespace("renv", quietly = TRUE)) {
      usethis::ui_done("Installing renv")
      remotes::install_cran("renv")
    } else {
      usethis::ui_info("renv already installed")
    }
  }

  res
}