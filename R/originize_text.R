#' Add Explicit Package Names to its Functions
#'
#'
#' @param text string to originize
#' @template  pkgs
#' @template overwrite
#' @template ask_before_applying_changes
#' @template check_conflicts
#' @template check_base_conflicts
#' @template check_local_conflicts
#' @template path_to_local_functions
#' @template add_base_packages
#' @template excluded_functions
#' @template verbose
#' @template use_markers
#'
#' @return No return value, called for side effects
#'
#' @noRd
originize_text <-
  function(
    text,
    pkgs = getOption("origin.pkgs", .packages()),
    overwrite = getOption("origin.overwrite", TRUE),
    ask_before_applying_changes =
      getOption("origin.ask_before_applying_changes", TRUE),
    check_conflicts = getOption("origin.check_conflicts", TRUE),
    check_base_conflicts = getOption("origin.check_base_conflicts", TRUE),
    add_base_packages = getOption("origin.add_base_packages", FALSE),
    excluded_functions = getOption("origin.excluded_functions", list()),
    verbose = getOption("origin.verbose", FALSE),
    use_markers = getOption("origin.use_markers_for_logging", TRUE),
    path_to_local_functions = getOption("origin.path_to_local_functions", NULL),
    check_local_conflicts = getOption("origin.check_local_conflicts", TRUE)
  ) {

    if (interactive()) {
      file <- rstudioapi::getSourceEditorContext()$path # nocov
    } else {
      file <- ""
    }

    # if function is run in a unsaved script, use root path a dummy path
    # needed for sourceMarkers
    if (file == "") {
      # TODO: .
      file <- "." #nocov
    }

    # read file
    script <- strsplit(text, split = "\\n")

    out <-
      originize_wrap(scripts = list(script),
                     files = file,
                     type = "paste",
                     pkgs = pkgs,
                     overwrite = overwrite,
                     ask_before_applying_changes = ask_before_applying_changes,
                     check_conflicts = check_conflicts,
                     check_base_conflicts = check_base_conflicts,
                     add_base_packages = add_base_packages,
                     excluded_functions = excluded_functions,
                     verbose = verbose,
                     use_markers = use_markers,
                     path_to_local_functions = path_to_local_functions,
                     check_local_conflicts = check_local_conflicts)


    return(out)
  }
