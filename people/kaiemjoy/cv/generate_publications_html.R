#!/usr/bin/env Rscript
#
# Fetch publications from NCBI for Dr. Aiemjoy and create HTML output
# This script fetches from her personal NCBI My Bibliography profile
#

# Note: This script requires network access to NCBI
# NCBI My Bibliography URL:
# https://www.ncbi.nlm.nih.gov/myncbi/1xIGpkekG9FQP/bibliography/public/

# For now, we read from the main publications.yml which is synced with NCBI
# In the future, this can be enhanced to fetch directly from
# NCBI E-utilities API

library(yaml)

#' Extract initials from a given name
get_initials <- function(given_name) {
  if (is.null(given_name) || given_name == "") {
    return("")
  }
  parts <- strsplit(gsub("\\.", "", given_name), " ")[[1]]
  initials <- paste(toupper(substring(parts[parts != ""], 1, 1)), collapse = "")
  return(initials)
}

#' Format author as: Last FI (where F is first initial, I is middle initial)
format_author <- function(last, given) {
  initials <- get_initials(given)
  if (initials == "") {
    return(last)
  }
  formatted <- paste(last, initials)
  # Bold Aiemjoy
  if (last == "Aiemjoy") {
    formatted <- paste0("\\textbf{", formatted, "}")
  }
  return(formatted)
}

#' Generate HTML publication entry with proper bolding
format_publication_html <- function(pub) {
  # Format authors
  authors_list <- pub$author
  if (is.null(authors_list)) {
    authors_list <- list()
  }

  author_parts <- sapply(authors_list, function(author) {
    last <- ifelse(is.null(author$family), "", author$family)
    given <- ifelse(is.null(author$given), "", author$given)
    initials <- get_initials(given)
    if (initials == "") {
      return(last)
    }
    name <- paste(last, initials)
    # Return with marker for bolding
    if (last == "Aiemjoy") {
      return(paste0("**BOLD**", name, "**ENDBOLD**"))
    }
    return(name)
  })

  authors_str <- paste(author_parts, collapse = ", ")

  # Get title
  title <- ifelse(is.null(pub$title), "", pub$title)

  # Get DOI
  doi <- ifelse(is.null(pub$doi), "", pub$doi)

  # Get journal
  journal <- pub$`journal-title`
  if (is.null(journal)) {
    journal <- pub$`container-title`
  }
  if (is.null(journal)) {
    journal <- ""
  }
  journal <- gsub("^\\*+|\\*+$", "", journal)

  # Get year
  issued <- pub$issued
  if (is.null(issued)) {
    issued <- pub$date
  }
  if (is.character(issued)) {
    year <- substr(issued, 1, 4)
  } else if (!is.null(issued)) {
    year <- as.character(issued)
  } else {
    year <- ""
  }

  # Build formatted HTML string
  html <- paste0('<p style="margin-bottom: 0.5em;">')

  # Add authors with proper bold tags
  authors_str <- gsub("\\*\\*BOLD\\*\\*", "<strong>", authors_str)
  authors_str <- gsub("\\*\\*ENDBOLD\\*\\*", "</strong>", authors_str)
  html <- paste0(html, authors_str, ". ")

  # Add hyperlinked title
  if (doi != "") {
    doi_url <- paste0("https://doi.org/", doi)
    html <- paste0(html, '<a href="', doi_url, '">', title, '</a>. ')
  } else {
    url <- pub$url
    if (is.null(url)) {
      url <- pub$path
    }
    if (!is.null(url) && url != "") {
      html <- paste0(html, '<a href="', url, '">', title, '</a>. ')
    } else {
      html <- paste0(html, title, '. ')
    }
  }

  # Add journal in italics
  if (journal != "") {
    html <- paste0(html, "<em>", journal, "</em>. ")
  }

  # Add year
  if (year != "") {
    html <- paste0(html, year, ". ")
  }

  # Add DOI
  if (doi != "") {
    html <- paste0(html, "DOI: ", doi, ".")
  }

  html <- paste0(html, '</p>')

  return(list(
    html = html,
    year = year,
    title = title,
    doi = doi
  ))
}

#' Main function
main <- function() {
  # Read from main publications file (which is synced with NCBI)
  input_file <- "/tmp/original_pubs.yml"

  publications <- tryCatch({
    yaml::read_yaml(input_file)
  }, error = function(e) {
    message("File not found: ", input_file)
    message("Using publications from current directory instead")

    input_file <- "publications.yml"
    all_pubs <- yaml::read_yaml(input_file)

    # Filter for Aiemjoy publications
    pubs <- list()
    for (pub in all_pubs) {
      if (!is.null(pub$author)) {
        for (author in pub$author) {
          if (!is.null(author$family) && author$family == "Aiemjoy") {
            pubs[[length(pubs) + 1]] <- pub
            break
          }
        }
      }
    }
    pubs
  })

  if (length(publications) == 0) {
    stop("No publications found")
  }

  message("Processing ", length(publications), " publications...")

  # Format all publications
  formatted_pubs <- list()

  for (i in seq_along(publications)) {
    pub <- publications[[i]]
    formatted_pub <- format_publication_html(pub)
    formatted_pubs[[i]] <- formatted_pub

    # Print first few for verification
    if (i <= 3) {
      message("\n", i, ". ", formatted_pub$html, "\n")
    }
  }

  # Sort by year descending
  years <- sapply(formatted_pubs, function(x) x$year)
  formatted_pubs <- formatted_pubs[order(years, decreasing = TRUE)]

  # Write HTML output
  output_file <- "people/kaiemjoy/cv/publications.html"
  html_output <- paste0(
    '<div class="publications-list">\n',
    paste(sapply(formatted_pubs, function(p) p$html), collapse = "\n"),
    '\n</div>'
  )

  writeLines(html_output, output_file)

  message("\nSaved ", length(formatted_pubs), " publications to ", output_file)
}

# Run main function if script is executed directly
if (!interactive()) {
  main()
}
