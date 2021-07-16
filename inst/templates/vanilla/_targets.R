src_files <- list.files(
  here::here("R"),
  pattern = "\\.[rR]$",
  full.names = TRUE
)

for (f in src_files) {
  source(f)
}

# Edit 'config/packages.R' to attach packages needed for your pipeline
source(here::here("config/packages.R"))

# Edit 'config/environment.R' to define globals from environment vars
source(here::here("config/environment.R"))

{{#auth_osf}}
# OSF authorization
osfr::osf_auth(token = Sys.getenv("OSF_PAT"))
{{/auth_osf}}

{{#auth_kobo}}
# KoBo authorization
if (is.null(karpi::kpi_auth_token())) {
  stop0(c(
    "Please set up your KoBo auth token with the 'KPI_TOKEN' ",
    "environment variable."
  ))
}
{{/auth_kobo}}

{{#unit_tests}}
# Run tests if configured
if (isTRUE(F_RUN_TESTS)) {
  library(testthat)
  
  run_unit_tests()
}
{{/unit_tests}}

# Add tar_targets() to this list to define the pipeline
list(
  tar_blueprints()
)