#!/usr/bin/env Rscript
#
# Reformat publications for Dr. Aiemjoy's CV in LaTeX style
# Reads from the original publications and reformats them
#

library(yaml)

#' Extract initials from a given name
#' 
#' @param given_name Character string of the given name
#' @return Character string of initials
#' @examples
#' get_initials("Jessica C.") # Returns "JC"
#' get_initials("Kristen") # Returns "K"
#' get_initials("Alice S.") # Returns "AS"
get_initials <- function(given_name) {
  if (is.null(given_name) || given_name == "") {
    return("")
  }
  
  # Remove periods and split
  parts <- strsplit(gsub("\\.", "", given_name), " ")[[1]]
  
  # Get first letter of each part
  initials <- paste(toupper(substring(parts[parts != ""], 1, 1)), collapse = "")
  
  return(initials)
}

#' Format author as: Last FI (where F is first initial, I is middle initial)
#' 
#' @param last Character string of last name
#' @param given Character string of given name(s)
#' @return Formatted author string
format_author <- function(last, given) {
  initials <- get_initials(given)
  
  if (initials == "") {
    return(last)
  }
  
  formatted <- paste(last, initials)
  
  # Bold Aiemjoy using HTML tags (not markdown)
  if (last == "Aiemjoy") {
    formatted <- paste0("<strong>", formatted, "</strong>")
  }
  
  return(formatted)
}

#' Format publication in LaTeX CV style
#' 
#' @param pub List representing a publication
#' @return Formatted publication string
format_publication <- function(pub) {
  # Format authors
  authors_list <- pub$author
  if (is.null(authors_list)) {
    authors_list <- list()
  }
  
  formatted_authors <- sapply(authors_list, function(author) {
    last <- ifelse(is.null(author$family), "", author$family)
    given <- ifelse(is.null(author$given), "", author$given)
    format_author(last, given)
  })
  
  authors_str <- paste(formatted_authors, collapse = ", ")
  
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
  
  # Remove markdown asterisks from journal if present
  journal <- gsub("^\\*+|\\*+$", "", journal)
  
  # Get date/year
  issued <- pub$issued
  if (is.null(issued)) {
    issued <- pub$date
  }
  
  if (is.character(issued)) {
    # Extract just the year from full dates like "2025-06-23"
    year <- substr(issued, 1, 4)
  } else if (!is.null(issued)) {
    year <- as.character(issued)
  } else {
    year <- ""
  }
  
  # Build formatted string
  formatted <- paste0(authors_str, ". ")
  
  # Add hyperlinked title
  if (doi != "") {
    formatted <- paste0(formatted, "[", title, "](https://doi.org/", doi, "). ")
  } else {
    url <- pub$url
    if (is.null(url)) {
      url <- pub$path
    }
    if (!is.null(url) && url != "") {
      formatted <- paste0(formatted, "[", title, "](", url, "). ")
    } else {
      formatted <- paste0(formatted, title, ". ")
    }
  }
  
  # Add journal in italics (using HTML tags)
  if (journal != "") {
    formatted <- paste0(formatted, "<em>", journal, "</em>. ")
  }
  
  # Add year
  if (year != "") {
    formatted <- paste0(formatted, year, ". ")
  }
  
  # Add DOI
  if (doi != "") {
    formatted <- paste0(formatted, "DOI: ", doi, ".")
  }
  
  return(trimws(formatted))
}

#' Main function to reformat publications
main <- function() {
  # Read original publications file
  # First try from temp location (if running after git show command)
  # Otherwise read from main publications.yml
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
    formatted_str <- format_publication(pub)
    
    # Extract year for sorting
    issued <- pub$issued
    if (is.null(issued)) {
      issued <- pub$date
    }
    
    if (is.character(issued)) {
      year <- substr(issued, 1, 4)
    } else if (!is.null(issued)) {
      year <- as.character(issued)
    } else {
      year <- "0"
    }
    
    formatted_pub <- list(
      formatted = formatted_str,
      year = year,
      title = ifelse(is.null(pub$title), "", pub$title),
      doi = ifelse(is.null(pub$doi), "", pub$doi)
    )
    
    formatted_pubs[[i]] <- formatted_pub
    
    # Print first few for verification
    if (i <= 3) {
      message("\n", i, ". ", formatted_str, "\n")
    }
  }
  
  # Sort by year descending
  years <- sapply(formatted_pubs, function(x) x$year)
  formatted_pubs <- formatted_pubs[order(years, decreasing = TRUE)]
  
  # Write to output file
  output_file <- "people/kaiemjoy/cv/publications.yml"
  yaml::write_yaml(formatted_pubs, output_file)
  
  message("\nSaved ", length(formatted_pubs), " publications to ", output_file)
}

# Run main function if script is executed directly
if (!interactive()) {
  main()
}
