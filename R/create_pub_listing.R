# taken from
# https://github.com/mcanouil/mickael.canouil.fr/blob/main/publications.r # nolint: line_length_linter

normalize_bibtex_months <- function(entries) {
  # Crossref can emit full month names (and "Sept"); Pandoc only retains
  # the month when BibTeX uses a standard three-letter month macro.
  month_names <- c(month.name, "Sept")
  month_macros <- c(tolower(month.abb), "sep")

  unname(vapply(
    entries,
    FUN = function(entry) {
      characters <- strsplit(entry, "", fixed = TRUE)[[1]]
      depth <- 0L
      field_start <- FALSE
      in_quotes <- FALSE
      escaped <- FALSE
      index <- 1L

      while (index <= length(characters)) {
        character <- characters[[index]]
        if (in_quotes) {
          if (character == '"' && !escaped) {
            in_quotes <- FALSE
          }
          escaped <- character == "\\" && !escaped
          index <- index + 1L
          next
        }
        if (character == "{") {
          depth <- depth + 1L
        } else if (character == "}") {
          depth <- depth - 1L
        } else if (character == '"') {
          in_quotes <- TRUE
        } else if (depth == 1L && character == ",") {
          field_start <- TRUE
        } else if (depth == 1L && field_start && !grepl("\\s", character)) {
          field_start <- FALSE
          field_end <- index + 4L
          if (field_end <= length(characters)) {
            field_name <- tolower(
              paste0(characters[index:field_end], collapse = "")
            )
          }
          if (field_end <= length(characters) && field_name == "month") {
            value_start <- field_end + 1L
            while (value_start <= length(characters) &&
                   grepl("\\s", characters[[value_start]])) { # nolint: indentation_linter
              value_start <- value_start + 1L
            }
            if (value_start <= length(characters) &&
                characters[[value_start]] == "=") { # nolint: indentation_linter
              value_start <- value_start + 1L
              while (value_start <= length(characters) &&
                     grepl("\\s", characters[[value_start]])) { # nolint: indentation_linter
                value_start <- value_start + 1L
              }
              value_end <- value_start
              if (characters[[value_start]] == "{") {
                value_depth <- 1L
                value_end <- value_end + 1L
                while (value_end <= length(characters) && value_depth > 0L) {
                  value_depth <- value_depth +
                    (characters[[value_end]] == "{") -
                    (characters[[value_end]] == "}")
                  value_end <- value_end + 1L
                }
                value_end <- value_end - 1L
                value <- paste0(
                  characters[(value_start + 1L):(value_end - 1L)],
                  collapse = ""
                )
              } else if (characters[[value_start]] == '"') {
                value_end <- value_end + 1L
                while (value_end <= length(characters) &&
                       characters[[value_end]] != '"') { # nolint: indentation_linter
                  value_end <- value_end + 1L
                }
                value <- paste0(
                  characters[(value_start + 1L):(value_end - 1L)],
                  collapse = ""
                )
              } else {
                while (value_end <= length(characters) &&
                       !characters[[value_end]] %in% c(",", "}")) { # nolint: indentation_linter
                  value_end <- value_end + 1L
                }
                value_end <- value_end - 1L
                value <- paste0(
                  characters[value_start:value_end],
                  collapse = ""
                )
              }
              month_index <- match(tolower(trimws(value)), tolower(month_names))
              if (!is.na(month_index)) {
                return(paste0(
                  paste0(characters[seq_len(value_start - 1L)], collapse = ""),
                  month_macros[[month_index]],
                  paste0(
                    characters[seq.int(value_end + 1L, length(characters))],
                    collapse = ""
                  )
                ))
              }
            }
          }
        }
        index <- index + 1L
      }
      entry
    },
    FUN.VALUE = character(1)
  ))
}

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
      # Quote dates so YAML doesn't interpret year-only values as numbers
      article <- article |>
        stringr::str_replace(
          "^(\\s*issued:\\s*)(\\d{4}(?:-\\d{2}(?:-\\d{2})?)?)\\s*$",
          '\\1"\\2"'
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
