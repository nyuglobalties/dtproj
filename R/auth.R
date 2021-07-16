dtprj_use_kobo <- function(path = usethis::proj_get()) {
  res <- ui_yea("Would you like to integrate with KoBo?")

  if (res) {
    if (!requireNamespace("karpi", quietly = TRUE)) {
      usethis::ui_done("Installing 'karpi'")
      remotes::install_github("nyuglobalties/karpi@v0.1.1")
    } else {
      usethis::ui_info("karpi already installed")
    }

    use_templ(
      "common",
      "kobo.R",
      save_as = "R/kobo.R"
    )

    usethis::use_git_ignore("_kobocache")
    usethis::ui_done("Adding KPI auth statement to workflow script")
  }

  res
}

dtprj_use_osf <- function(path = usethis::proj_get()) {
  res <- ui_yea("Would you like to integrate with the OSF?")

  if (res) {
    if (!requireNamespace("osfr", quietly = TRUE)) {
      usethis::ui_done("Installing 'osfr'")
      remotes::install_cran("osfr")
    } else {
      usethis::ui_info("osfr already installed")
    }

    if (!requireNamespace("osfutils", quietly = TRUE)) {
      usethis::ui_done("Installing 'osfutils'")
      remotes::install_github("nyuglobalties/osfutils@v0.1.0")
    } else {
      usethis::ui_info("osfutils already installed")
    }

    usethis::use_git_ignore("_osfcache")
    usethis::ui_done("Adding OSF auth statement to workflow script")
  }

  res
}