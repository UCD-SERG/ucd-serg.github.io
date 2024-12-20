devtools::load_all()

library(rcrossref)
library(dplyr)


dois <- read.csv("papers/DOIs.csv") |> 
  dplyr::pull(DOI) 


bibtex_entries <-
  cr_cn(dois, format = "bibtex") |>
  unlist() |>
  stringr::str_trim(side = "left")
bibtex_entries |>
  cat(file = "publications.bib")

bibtex_entries |> create_pub_listing()
