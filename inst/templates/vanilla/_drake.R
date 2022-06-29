src_files <- list.files(
  here::here("R"),
  pattern = "\\.[rR]$",
  full.names = TRUE
)

for (f in src_files) {
  source(f)
}

# Edit 'config/packages.R' to attach packages needed for your pipeline
# NB: If you use renv, add `package::function` references to enable
#     renv to track "Suggested" packages, which are not always picked
#     up with `renv::snapshot()`
source(here::here("config/packages.R"))

# Edit 'config/environment.R' to define globals from environment vars
source(here::here("config/environment.R"))

# Edit 'config/plan.R' to configure the drake pipeline
source(here::here("config/plan.R"))

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

# Load blueprints
full_plan <- load_blueprints(full_plan)

drake_config(
  full_plan,
  verbose = 2
)
