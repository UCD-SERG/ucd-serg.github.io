# taken from
# https://github.com/mcanouil/mickael.canouil.fr/blob/main/publications.r # nolint: line_length_linter

create_pub_listing <- function(bib = bibtex::read.bib(bib_file),
                               bib_file = "publications.bib",
                               author = "Canouil",
                               highlight = seq_along(bibtex_entries) < 3, # nolint: line_length_linter
                               categories = NULL) { # nolint: line_length_linter
  articles <- lapply(
    X = bib[bib != ""],
    FUN = function(ibib) {
      f <- tempfile()
      on.exit(unlink(f))
      writeLines(ibib, f)
      article <- tail(
        head(
          system(
            command = glue::glue(
              "pandoc {f} --standalone --from=bibtex --to=markdown"
            ),
            intern = TRUE
          ),
          -2
        ),
        -3
      )

      article <- c(
        article,
        grep("  container-title:", article, value = TRUE) |>
          stringr::str_replace(
            "  container-title: (.*)",
            "  journal-title: '*\\1*'"
          ),
        grep("  issued:", article, value = TRUE) |>
          stringr::str_replace("  issued: ", "  date: "),
        grep("doi:", article, value = TRUE) |>
          stringr::str_replace("  doi: ", "  path: https://doi.org/")
      )
      article
    }
  )
  articles <- mapply(
    FUN = function(x, h) c(x, paste("  highlight:", as.integer(h))),
    articles, highlight
  )
  if (!is.null(categories)) {
    articles <- mapply(
      FUN = function(x, cat) {
        if (!is.na(cat) && cat != "") {
          c(x, paste0("  categories: [", cat, "]"))
        } else {
          x
        }
      },
      articles, categories
    )
  }
  writeLines(text = unlist(articles),
             con = sub("\\.bib$", ".yml", bib_file))

}
