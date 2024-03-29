testthat::test_that("solve_local_duplicates triggers the expected messages", {

  dir <- tempfile()
  dir.create(dir)

  # create 20 empty files
  # checks trigger of originizing many files and ignoring emptxy files
  lapply(1:20, function(i) {
    writeLines("", con = file.path(dir, sprintf("testfile_empty_%s.R", i)))
  })

  # In einem Schritt, mit crosschecks
  testthat::expect_message(
    testthat::expect_equal(
      originize_dir(dir,
                    pkgs = c("data.table",
                             "dplyr"
                    ), check_local_conflicts = FALSE),
      NULL
    ),
    regexp = "All provided scripts are empty"
  )


  test_file_path1 <- file.path(dir, "testfile1.R")
  test_file_path2 <- file.path(dir, "testfile2.R")
  test_empty_file_path <- file.path(dir, "empty_testfile.R")
  target_file_path1 <- file.path(dir, "targetfile1.R")
  target_file_path2 <- file.path(dir, "targetfile2.R")

  # works only when package is build
  datapath <- system.file("testdata", package = "origin")

  test_text <- utils::read.csv2(file = file.path(datapath, "testscript.csv"),
                                na.strings = "NA",
                                encoding = "UTF-8",
                                stringsAsFactors = FALSE)

  # windows adds X.U.FEFF to the first variable name in read.csv2.
  # Therefore, the following bulletproof way to access the
  # correct variable / vector
  nms <- names(test_text)
  writeLines(test_text[1:20,
                       grepl("TARGET", nms, fixed = TRUE)],
             con = target_file_path1)

  writeLines(test_text[21:nrow(test_text),
                       grepl("TARGET", nms, fixed = TRUE)],
             con = target_file_path2)

  writeLines(test_text[1:20,
                       grepl("TESTSKRIPT", nms, fixed = TRUE)],
             con = test_file_path1)

  writeLines(test_text[21:nrow(test_text),
                       grepl("TESTSKRIPT", nms, fixed = TRUE)],
             con = test_file_path2)

  writeLines(c("", "", ""),
             con = test_empty_file_path)



  # In einem Schritt, mit crosschecks
  originize_dir(dir,
                pkgs = c("data.table",
                         "dplyr",
                         "purrr"
                ),
                overwrite = TRUE,
                add_base_packages = FALSE,
                ask_before_applying_changes = FALSE,
                excluded_functions = list(dplyr = "last"),
                use_markers = FALSE,
                check_local_conflicts = FALSE,
                verbose = FALSE)

  testfile_after1 <- readLines(test_file_path1)
  testfile_after2 <- readLines(test_file_path2)
  testempty_file_after <- readLines(test_empty_file_path)

  testthat::expect_equal(testfile_after1[1:20],
                         test_text[1:20, grepl("TARGET", nms, fixed = TRUE)])
  testthat::expect_equal(testfile_after2,
                         test_text[21:nrow(test_text),
                                   grepl("TARGET", nms, fixed = TRUE)])
  testthat::expect_equal(testempty_file_after,
                         c("", "", ""))


  # reset
  writeLines(test_text[1:20,
                       grepl("TESTSKRIPT", nms, fixed = TRUE)],
             con = test_file_path1)

  writeLines(test_text[21:nrow(test_text),
                       grepl("TESTSKRIPT", nms, fixed = TRUE)],
             con = test_file_path2)


  # erwartete Fehlermeldungen prüfen
  testthat::expect_error(originize_dir(dir,
                                       pkgs = "data.table",
                                       check_base_conflicts = FALSE,
                                       add_base_packages = TRUE),
                         "checking for potential conflicts is required")

  testthat::expect_error(originize_dir(dir,
                                       pkgs = "data.table",
                                       exclude_files = "blubb.R"),
                         "File to exclude not in given path")




  # exkludiere bestimmte files
  originize_dir(dir,
                pkgs = c("data.table",
                         "dplyr",
                         "purrr"
                ),
                exclude_files = test_file_path2,
                overwrite = TRUE,
                add_base_packages = FALSE,
                ask_before_applying_changes = FALSE,
                excluded_functions = list(dplyr = "last"),
                use_markers = FALSE,
                check_local_conflicts = FALSE,
                verbose = FALSE)

  testfile_after1 <- readLines(test_file_path1)
  testfile_after2 <- readLines(test_file_path2)

  testthat::expect_equal(testfile_after1,
                         test_text[1:20, grepl("TARGET", nms, fixed = TRUE)])
  testthat::expect_equal(testfile_after2,
                         test_text[21:nrow(test_text),
                                   grepl("TESTSKRIPT", nms, fixed = TRUE)])


})
