#' Get Packages from the DESCRIPTION file
#'
#' @param path Path to a DESC>RIPTION file, If `NULL` (default), the functions
#'         searches for a description file in the current active project
#'
#' @description It looks for a DESCRIPTION file in the current project and
#' returns all packages listed in Suggests, Imports, and Depends.
#'
#' @return character vector of package names
#' @export
#'
#' @examples
#' # Only works inside of a package developing project
#' \dontrun{
#' get_pkgs_from_description()
#' }
get_pkgs_from_description <- function(path = NULL) {
  
  if (is.null(path)) {
    # throws an error if no DESCRIPTION file is present
    path <- file.path(rstudioapi::getActiveProject(), "DESCRIPTION")
  } else if (!endsWith(path, "DESCRIPTION")) {
    warning(paste("Proper DESC>riPTION File provided?", path))
  }
  
  if (!file.exists(path)) {
    stop("No DESCRIPTION in the current Project root.")
  }
  
  desc <- readLines(path)
  
  # Keywords with package names listed afterwards
  triggers <- grep("Imports|Suggests|Depends", desc)
  
  if (length(triggers) == 0) {
    stop("No Imports, Suggests, or Depends in Description")
  }
  
  # arguments have indentions
  arguments <- grep("^[[:blank:]]+", desc)
  
  nrow_desc <- length(desc)
  # lines with indention right after the keywords
  is_pkg_line <-
    unlist(lapply(triggers[(triggers + 1) %in% arguments],
                  function(x) {
                    
                    # sequence of numbers starting after the trigger
                    x_seq <- (x + 1):nrow_desc
                    
                    # which parts of this sequence are arguments
                    match_seq <- x_seq %in% arguments
                    
                    # cut sequence as soon as the first non-argument
                    # appears in the sequence
                    out <- x_seq[cumsum(match_seq) == seq_along(match_seq)]
                    return(out)
                  }))
  
  if (length(is_pkg_line) == 0) {
    warning("No Packages found in DESCRIPTION")
    return(NULL)
  }
  
  pkg_lines <- desc[is_pkg_line]
  
  # extract the package name
  pkgs <- regmatches(x = pkg_lines,
                     m = regexpr(pattern = "[A-z\\.0-9]+", # Exclude Linting
                                 text = pkg_lines),
                     invert = FALSE)
  # exlcude R since it can appear in Depends but is not a package
  pkgs <- pkgs[pkgs != "R"]
  
  if (length(pkgs) == 0) {
    warning("No Packages found in DESCRIPTION")
    return(NULL)
  }
  
  pkgs <- unique(pkgs)
  
  return(pkgs)
}
