#!/usr/bin/env Rscript
#
# fetch_from_ncbi.R
#
# Fetch publications from NCBI My Bibliography for Dr. Kristen Aiemjoy
# using NCBI E-utilities API
#
# Usage: Rscript fetch_from_ncbi.R
#
# Output: publications.yml in LaTeX CV format
#
# NCBI My Bibliography Collection:
# https://www.ncbi.nlm.nih.gov/myncbi/1xIGpkekG9FQP/bibliography/public/

# Check and load required packages
required_packages <- c("yaml", "jsonlite", "xml2")
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message("Installing required package: ", pkg)
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
  suppressPackageStartupMessages(library(pkg, character.only = TRUE))
}

# NCBI E-utilities base URLs
ESEARCH_URL <- "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi"
EFETCH_URL <- "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi"
ESUMMARY_URL <- "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi"

#' Fetch PubMed IDs for an author
#'
#' @param author_name Author name (e.g., "Aiemjoy K")
#' @param retmax Maximum number of results to return
#' @return Vector of PubMed IDs
fetch_pubmed_ids <- function(author_name, retmax = 100) {
  # Build search query
  query <- paste0(author_name, "[Author]")
  
  # Construct URL
  url <- paste0(
    ESEARCH_URL,
    "?db=pubmed",
    "&term=", URLencode(query, reserved = TRUE),
    "&retmax=", retmax,
    "&retmode=json"
  )
  
  cat("Fetching PubMed IDs for:", author_name, "\n")
  cat("URL:", url, "\n")
  
  # Fetch data
  tryCatch({
    response <- readLines(url, warn = FALSE)
    data <- jsonlite::fromJSON(paste(response, collapse = ""))
    
    if (!is.null(data$esearchresult$idlist)) {
      pmids <- data$esearchresult$idlist
      cat("Found", length(pmids), "publications\n")
      pmids
    } else {
      cat("No publications found\n")
      character(0)
    }
  }, error = function(e) {
    cat("Error fetching PubMed IDs:", e$message, "\n")
    character(0)
  })
}

#' Fetch publication details for PubMed IDs
#'
#' @param pmids Vector of PubMed IDs
#' @return List of publication records
fetch_publication_details <- function(pmids) {
  if (length(pmids) == 0) {
    cat("No PMIDs provided\n")
    return(list())
  }
  
  # Process in batches of 100
  batch_size <- 100
  all_pubs <- list()
  
  for (i in seq(1, length(pmids), by = batch_size)) {
    batch_end <- min(i + batch_size - 1, length(pmids))
    batch_pmids <- pmids[i:batch_end]
    
    cat("Fetching details for PMIDs", i, "to", batch_end, "\n")
    
    # Construct URL for efetch
    pmid_str <- paste(batch_pmids, collapse = ",")
    url <- paste0(
      EFETCH_URL,
      "?db=pubmed",
      "&id=", pmid_str,
      "&retmode=xml"
    )
    
    tryCatch({
      # Fetch XML data
      xml_data <- xml2::read_xml(url)
      
      # Parse each article
      articles <- xml2::xml_find_all(xml_data, ".//PubmedArticle")
      
      for (article in articles) {
        pub <- parse_pubmed_article(article)
        if (!is.null(pub)) {
          all_pubs <- c(all_pubs, list(pub))
        }
      }
      
      # Be polite to NCBI servers
      Sys.sleep(0.4)
    }, error = function(e) {
      cat("Error fetching details:", e$message, "\n")
    })
  }
  
  cat("Successfully parsed", length(all_pubs), "publications\n")
  all_pubs
}

#' Parse a PubMed article XML node
#'
#' @param article XML node for a PubmedArticle
#' @return List with publication details
parse_pubmed_article <- function(article) {
  tryCatch({
    # Extract basic info
    medline <- xml2::xml_find_first(article, ".//MedlineCitation")
    pmid <- xml2::xml_text(
      xml2::xml_find_first(medline, ".//PMID")
    )
    
    # Extract article details
    art <- xml2::xml_find_first(medline, ".//Article")
    
    # Title
    title <- xml2::xml_text(
      xml2::xml_find_first(art, ".//ArticleTitle")
    )
    
    # Journal
    journal <- xml2::xml_text(
      xml2::xml_find_first(art, ".//Journal/Title")
    )
    
    # Authors
    author_nodes <- xml2::xml_find_all(art, ".//Author")
    authors <- sapply(author_nodes, function(auth) {
      last_name <- xml2::xml_text(
        xml2::xml_find_first(auth, ".//LastName")
      )
      initials <- xml2::xml_text(
        xml2::xml_find_first(auth, ".//Initials")
      )
      if (nchar(last_name) > 0 && nchar(initials) > 0) {
        paste(last_name, initials)
      } else {
        NA
      }
    })
    authors <- authors[!is.na(authors)]
    
    # Publication date
    pub_date_node <- xml2::xml_find_first(art, ".//PubDate")
    year <- xml2::xml_text(
      xml2::xml_find_first(pub_date_node, ".//Year")
    )
    month <- xml2::xml_text(
      xml2::xml_find_first(pub_date_node, ".//Month")
    )
    day <- xml2::xml_text(
      xml2::xml_find_first(pub_date_node, ".//Day")
    )
    
    # Format date
    if (nchar(month) > 0) {
      month_num <- match(
        month,
        c("Jan", "Feb", "Mar", "Apr", "May", "Jun",
          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
      )
      if (is.na(month_num)) {
        month_num <- as.integer(month)
      }
      if (nchar(day) > 0) {
        date <- sprintf("%s-%02d-%02d",
                       year, month_num, as.integer(day))
      } else {
        date <- sprintf("%s-%02d-01", year, month_num)
      }
    } else {
      date <- paste0(year, "-01-01")
    }
    
    # DOI
    doi_node <- xml2::xml_find_first(
      art,
      ".//ELocationID[@EIdType='doi']"
    )
    if (length(doi_node) > 0) {
      doi <- xml2::xml_text(doi_node)
    } else {
      doi <- NA
    }
    
    # Return publication record
    list(
      id = paste0("pmid-", pmid),
      title = title,
      authors = authors,
      date = date,
      journal = journal,
      doi = if (!is.na(doi)) doi else NULL,
      pmid = pmid
    )
  }, error = function(e) {
    cat("Error parsing article:", e$message, "\n")
    NULL
  })
}

#' Format authors in LaTeX CV style with bolded Aiemjoy
#'
#' @param authors Vector of author names in "Last FI" format
#' @return Formatted author string with HTML tags
format_authors_latex <- function(authors) {
  formatted <- sapply(authors, function(auth) {
    if (grepl("Aiemjoy", auth, ignore.case = TRUE)) {
      paste0("<strong>", auth, "</strong>")
    } else {
      auth
    }
  })
  paste(formatted, collapse = ", ")
}

#' Save publications to YAML file in LaTeX CV format
#'
#' @param publications List of publication records
#' @param output_file Output YAML file path
save_publications_yaml <- function(publications, output_file) {
  # Format publications for YAML
  yaml_pubs <- lapply(publications, function(pub) {
    # Format authors
    author_str <- format_authors_latex(pub$authors)
    
    # Create title with hyperlink if DOI exists
    if (!is.null(pub$doi) && !is.na(pub$doi)) {
      doi_url <- paste0("https://doi.org/", pub$doi)
      title_html <- paste0(
        "<a href=\"", doi_url, "\">", pub$title, "</a>"
      )
    } else {
      title_html <- pub$title
    }
    
    # Format journal in italics
    journal_html <- paste0("<em>", pub$journal, "</em>")
    
    # Extract year
    year <- substr(pub$date, 1, 4)
    
    # Build description in LaTeX CV format
    desc_parts <- c(
      author_str,
      title_html,
      journal_html,
      year
    )
    
    if (!is.null(pub$doi) && !is.na(pub$doi)) {
      desc_parts <- c(desc_parts, paste0("DOI: ", pub$doi))
    }
    
    description <- paste(desc_parts, collapse = ". ")
    description <- paste0(description, ".")
    
    list(
      id = pub$id,
      title = pub$title,
      authors = pub$authors,
      date = pub$date,
      journal = pub$journal,
      doi = pub$doi,
      pmid = pub$pmid,
      description = description
    )
  })
  
  # Write to YAML
  yaml::write_yaml(yaml_pubs, output_file)
  cat("Saved", length(yaml_pubs), "publications to", output_file, "\n")
}

#' Main function
main <- function() {
  cat("=== Fetching Dr. Aiemjoy's publications from NCBI ===\n\n")
  
  # Fetch PMIDs
  pmids <- fetch_pubmed_ids("Aiemjoy K", retmax = 100)
  
  if (length(pmids) == 0) {
    cat("No publications found. Exiting.\n")
    return(invisible(NULL))
  }
  
  # Fetch details
  publications <- fetch_publication_details(pmids)
  
  if (length(publications) == 0) {
    cat("No publication details retrieved. Exiting.\n")
    return(invisible(NULL))
  }
  
  # Sort by date (most recent first)
  publications <- publications[
    order(
      sapply(publications, function(p) p$date),
      decreasing = TRUE
    )
  ]
  
  # Determine output file path
  # Try to get script location, fall back to current directory
  script_path <- tryCatch({
    normalizePath(sys.frame(1)$ofile)
  }, error = function(e) {
    # If that fails, try commandArgs
    tryCatch({
      args <- commandArgs(trailingOnly = FALSE)
      file_arg <- grep("^--file=", args, value = TRUE)
      if (length(file_arg) > 0) {
        normalizePath(sub("^--file=", "", file_arg))
      } else {
        NULL
      }
    }, error = function(e2) NULL)
  })
  
  if (!is.null(script_path) && file.exists(script_path)) {
    output_file <- file.path(dirname(script_path), "publications.yml")
  } else {
    # Fall back to current working directory
    output_file <- "publications.yml"
  }
  
  save_publications_yaml(publications, output_file)
  
  cat("\n=== Complete! ===\n")
  cat("Publications saved to:", output_file, "\n")
  cat("Total publications:", length(publications), "\n")
  
  invisible(publications)
}

# Run main function if script is executed directly
if (!interactive()) {
  main()
}
