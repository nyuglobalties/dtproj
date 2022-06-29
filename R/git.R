dt_use_git <- function(path = ".") {
  path <- normalizePath(path)
  repo <- tryCatch(gert::git_find(path), error = function(e) NULL)

  if (!is.null(repo)) {
    usethis::ui_info("{ui_value(path)} is already a git repository")
  }

  gert::git_init(path)
  usethis::ui_done("Initialized git repo in {ui_value(path)}")

  invisible(path)
}

dt_git_ignore <- function(..., path = ".") {
  path <- normalizePath(path)
  repo <- tryCatch(gert::git_find(path), error = function(e) NULL)

  if (is.null(repo)) {
    usethis::ui_stop("{path} is not a git repository")
  }

  gitignore_file <- file.path(path, ".gitignore")

  if (!fs::file_exists(gitignore_file)) {
    usethis::ui_done("Creating {ui_value('.gitignore')}")
    fs::file_create(gitignore_file)
  }

  ignores <- as.character(list(...))

  for (ig in ignores) {
    usethis::ui_done("Adding {ui_value(ig)} to {ui_value('.gitignore')}")
    cat_line(ig, file = gitignore_file, append = TRUE)
  }

  ignores
}

dt_use_standard_git_ignores <- function(path = ".") {
  usethis::use_git_ignore(
    c(
      # R
      ".RData",
      ".Renviron",
      ".Rhistory",
      ".Rproj.user",
      ".Ruserdata",
      # LibreOffice
      ".~lock.*#",
      # Microsoft Office
      "~$*.doc*",
      "~$*.xls*",
      "~$*.ppt*"
    ),
    directory = path
  )
}
