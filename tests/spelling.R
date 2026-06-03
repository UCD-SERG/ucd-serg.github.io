if (requireNamespace("spelling", quietly = TRUE)) {
  # error = FALSE: the vignette/.Rmd check reports spelling problems but does
  # not fail the test run, so pre-existing/tolerated issues there don't block
  # CI. The .qmd check below intentionally uses a hard stop() instead: .qmd
  # spelling is newly covered and starts clean, so any new error should fail.
  spelling::spell_check_test(vignettes = TRUE, error = FALSE,
                             skip_on_cran = TRUE)

  # Also check .qmd files, which spell_check_test() skips by default
  wordlist <- if (file.exists("inst/WORDLIST")) {
    readLines("inst/WORDLIST")
  } else {
    character()
  }
  qmd_files <- list.files(
    ".",
    pattern = "\\.qmd$",
    recursive = TRUE,
    full.names = TRUE
  )
  if (length(qmd_files) > 0) {
    results <- spelling::spell_check_files(
      qmd_files,
      ignore = wordlist,
      lang = "en-US"
    )
    if (nrow(results) > 0) {
      print(results)
      stop("Spelling errors found in .qmd files")
    }
  }
}
