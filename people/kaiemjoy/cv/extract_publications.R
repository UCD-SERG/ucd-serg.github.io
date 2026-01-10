#!/usr/bin/env Rscript
#
# Extract publications for Dr. Kristen Aiemjoy from the main publications.yml file
#

library(yaml)

#' Format author list with Aiemjoy in bold markers
#' 
#' @param authors List of author objects
#' @return Character string of formatted authors
format_authors <- function(authors) {
  author_strs <- sapply(authors, function(author) {
    given <- ifelse(is.null(author$given), "", author$given)
    family <- ifelse(is.null(author$family), "", author$family)
    name <- trimws(paste(given, family))
    
    if (!is.null(author$family) && author$family == "Aiemjoy") {
      name <- paste0("**", name, "**")
    }
    name
  })
  
  paste(author_strs, collapse = ", ")
}

#' Extract publications where Aiemjoy is an author
#' 
#' @param input_file Path to input publications.yml file
#' @param output_file Path to output publications.yml file
extract_aiemjoy_publications <- function(input_file = "publications.yml", 
                                         output_file = "people/kaiemjoy/cv/publications.yml") {
  tryCatch({
    # Read the YAML file
    publications <- yaml::read_yaml(input_file)
    
    if (is.null(publications) || length(publications) == 0) {
      message("No publications found in input file")
      return(invisible())
    }
    
    # Filter publications where Aiemjoy is an author
    aiemjoy_pubs <- list()
    
    for (pub in publications) {
      if (!is.null(pub$author)) {
        for (author in pub$author) {
          if (!is.null(author$family) && author$family == "Aiemjoy") {
            # Add formatted author field
            pub$authors_formatted <- format_authors(pub$author)
            
            # Extract year from issued
            if (!is.null(pub$issued)) {
              issued <- pub$issued
              tryCatch({
                if (is.character(issued)) {
                  pub$year <- substr(issued, 1, 4)
                } else if (is.numeric(issued)) {
                  pub$year <- as.character(issued)
                } else {
                  year_str <- as.character(issued)
                  pub$year <- ifelse(nchar(year_str) >= 4, substr(year_str, 1, 4), "")
                }
              }, error = function(e) {
                pub$year <- ""
              })
            }
            
            aiemjoy_pubs[[length(aiemjoy_pubs) + 1]] <- pub
            break
          }
        }
      }
    }
    
    message("Found ", length(aiemjoy_pubs), " publications for Dr. Aiemjoy")
    
    # Write to output file
    yaml::write_yaml(aiemjoy_pubs, output_file)
    
    message("Saved to ", output_file)
    
  }, error = function(e) {
    if (grepl("cannot open", e$message)) {
      message("File ", input_file, " not found")
      quit(status = 1)
    } else if (grepl("yaml", tolower(e$message))) {
      message("Error parsing YAML: ", e$message)
      quit(status = 1)
    } else {
      message("Unexpected error: ", e$message)
      quit(status = 1)
    }
  })
}

# Run main function if script is executed directly
if (!interactive()) {
  extract_aiemjoy_publications()
}
