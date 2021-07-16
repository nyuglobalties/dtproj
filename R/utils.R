stop0 <- function(...) {
  stop(..., call. = FALSE)
}

dtproj_path <- function(...) {
  system.file(..., package = "dtproj")
}

cat_line <- function(...) {
  cat(..., "\n", sep = "")
}

dtproj_abort <- function(msg, path = ".") {
  usethis::ui_oops("An error occurred!")
  res <- ui_no("Would you like to save your changes?")

  if (res) {
    purge_dir(normalizePath(path))
  }

  usethis::ui_stop(msg)
}

purge_dir <- function(path) {
  withr::with_dir(path, {
    files <- fs::dir_ls(all = TRUE)

    for (f in files) {
      fs::file_delete(f)
    }
  })
}
