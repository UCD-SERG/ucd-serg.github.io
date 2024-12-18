
devtools::load_all()

library(rcrossref)

dois <- read.csv("papers/DOIs.csv") |> 
  pull(DOI) 

bibtex_entries <- 
  cr_cn(dois, format = "bibtex") |> 
  unlist() |> 
  stringr::str_trim(side = "left")
bibtex_entries |>
  cat(file = "publications.bib")

# usethis::use_data(papers, overwrite = TRUE)
bibtex_entries |> create_pub_listing()

