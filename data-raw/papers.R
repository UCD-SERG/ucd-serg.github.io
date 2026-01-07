devtools::load_all()

library(rcrossref)
library(dplyr)


dois_df <- read.csv("papers/DOIs.csv")
dois <- dois_df |> dplyr::pull(DOI)

# Identify preprints based on nickname
is_preprint <- grepl("preprint", dois_df$nickname, ignore.case = TRUE)
categories <- ifelse(is_preprint, "preprint", "")

bibtex_entries <-
  cr_cn(dois, format = "bibtex") |>
  unlist() |>
  stringr::str_trim(side = "left")

bibtex_entries |>
  cat(file = "publications.bib")

bibtex_entries |> create_pub_listing(categories = categories)
