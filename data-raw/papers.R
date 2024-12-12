library(rcrossref)

dois = readLines("papers/DOIs.txt")

bibtex_entries <- 
  cr_cn(dois, format = "bibtex") |> 
  unlist() |> 
  stringr::str_trim(side = "left")
bibtex_entries |>
  cat(file = "publications.bib")

# usethis::use_data(papers, overwrite = TRUE)
bibtex_entries |> create_pub_listing()


library(rcrossref)
library(jsonlite)
library(rmarkdown)
library(yaml)
# Define the DOI
doi <- dois[1]  # Replace with your DOI
doi = "10.1038/s41586-019-1666-5"
# Fetch metadata
metadata <- cr_cn(doi, format = "citeproc-json")

metadata_list <- list(
  references = list(metadata[c("title", 'container-title-short', 'date', "author")])
)

# Convert to YAML format
yaml_output <- as.yaml(metadata_list)

# Save YAML to a file
writeLines(yaml_output, "reference.yaml")
