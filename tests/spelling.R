if (requireNamespace("spelling", quietly = TRUE)) {
  spelling::spell_check_test(vignettes = TRUE, error = FALSE,
                             skip_on_cran = TRUE)

  # Also check Quarto markdown files, which spell_check_test() ignores by default
  wordlist <- if (file.exists("inst/WORDLIST")) readLines("inst/WORDLIST") else character()
  qmd_files <- list.files(".", pattern = "\\.qmd$", recursive = TRUE, full.names = TRUE)
  if (length(qmd_files) > 0) {
    results <- spelling::spell_check_files(qmd_files, ignore = wordlist, lang = "en-US")
    if (nrow(results) > 0) {
      print(results)
      stop("Spelling errors found in .qmd files")
    }
  }
}
