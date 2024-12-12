read_bib_file = function(bib_file)
{
  bib <- strsplit(paste(readLines(bib_file), collapse = "\n"), "\n@")[[1]]
}