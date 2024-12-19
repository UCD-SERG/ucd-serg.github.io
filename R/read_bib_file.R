read_bib_file <- function(bib_file) {
  strsplit(paste(readLines(bib_file), collapse = "\n"), "\n@")[[1]]
}
