dtprj_use_tests <- function(path = usethis::proj_get()) {
  res <- ui_yea(c(
    "It is strongly recommend to use unit tests.",
    "Would you like to use them?"
  ))

  if (res) {
    usethis::use_directory("tests")

    if (!requireNamespace("testthat", quietly = TRUE)) {
      usethis::ui_done("Installing testthat")
      remotes::install_cran("testthat")
    } else {
      usethis::ui_info("testthat already installed")
    }

    use_templ(
      "common",
      "test-example.R",
      save_as = "tests/test-example.R"
    )
  }

  res
}