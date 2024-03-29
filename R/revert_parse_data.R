# converse parsed data back to its input
revert_parse_data <- function(parse_data, recover_empty_lines = TRUE) {
  # Strings that cover multiple lines
  to_split <- parse_data$token == "STR_CONST" &
    parse_data$line1 != parse_data$line2

  if (any(to_split)) {
    dfs <- parse_data[to_split, ]

    # how many lines does each string cover
    rep <- dfs$line2 - dfs$line1 + 1

    # recover one row for each line
    # get string for each line
    string_cut <- unlist(strsplit(dfs$text, split = "\n"))
    # repeat ddf-rows as often
    dfs <- dfs[rep(seq_len(nrow(dfs)), rep), ]

    # assign string for eahc line
    dfs$text <- string_cut

    # helper for info recovery
    dfs$rep <- unlist(lapply(rep, seq_len)) - 1

    # start line is initial start + number of lines covered
    dfs$line1 <- dfs$line1 + dfs$rep
    #start line is end line
    dfs$line2 <- dfs$line1

    # recover column values
    dfs[dfs$rep > 0, "col1"] <- 1
    dfs[dfs$rep > 0, "col2"] <- nchar(dfs[dfs$rep > 0, "text"])
    dfs[dfs$rep == 0, "col2"] <-
      nchar(dfs[dfs$rep == 0, "text"]) + dfs[dfs$rep == 0, "col1"]
    dfs$rep <- NULL

    # combine initial and recovered data
    parse_data <- rbind(parse_data[!to_split, ],
                        dfs)

    # bring in correct order
    parse_data <- parse_data[order(parse_data$file,
                                   parse_data$line1,
                                   parse_data$col1), ]
  }

  res <- by(data = parse_data,
            # consider each line separately
            # TODO: exclude loop
            INDICES = list(parse_data$line1, parse_data$file),
            FUN = function(args) {
              # determine number of tokens in the line
              n_cases <- length(args$text)

              # determine width of white space needed prior to each token
              # it is its starting position minus 
              # the end position of the precessing token minus 1 
              # since positions are including
              n_ws <- args$col1 - c(0, args$col2[-n_cases]) - 1

              # create needed whitespace
              ws <- strrep(" ", times = n_ws)

              # add whitespaces to the tokens
              paste(ws, args$text, collapse = "", sep = "")
            })
  res <- as.character(res)

  # recover empty lines if needed
  if (recover_empty_lines) {
    out <- character(max(parse_data$line1))
    out[unique(parse_data$line1)] <- res
    return(out)
  } else {
    return(res)
  }

}
