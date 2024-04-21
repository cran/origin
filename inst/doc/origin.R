## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----eval=FALSE---------------------------------------------------------------
#  originize_file(file = "testscript.R",
#                 pkgs = .packages(),
#                 overwrite = TRUE,
#                 ask_before_applying_changes = TRUE,
#                 ignore_comments = TRUE,
#                 check_conflicts = TRUE,
#                 add_base_packages = FALSE,
#                 check_base_conflicts = TRUE,
#                 check_local_conflicts = TRUE,
#                 excluded_functions = list(dplyr = c("%>%", "across"),
#                                           data.table = c(":=", "%like%"),
#                                           # exclude from all packages:
#                                           c("first", "last")),
#                 verbose = TRUE,
#                 use_markers = TRUE)

## ----eval=FALSE---------------------------------------------------------------
#  options(origin.pkgs = c("dplyr", "data.table"),
#          origin.overwrite = TRUE)

