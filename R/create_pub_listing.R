# taken from https://github.com/mcanouil/mickael.canouil.fr/blob/main/publications.r

create_pub_listing <- function(bib = read_bib_file(bib_file),
                               bib_file = "publications.bib", 
                               author = "Canouil"
                                 ) {
  
  articles <- lapply(
    X = bib[bib != ""],
    FUN = function(ibib) {
      f <- tempfile()
      on.exit(unlink(f))
      writeLines(ibib, f)
      article <- tail(
        head(
          system(
            command = paste("pandoc", f, "--standalone", "--from=bibtex", "--to=markdown"),
            intern = TRUE
          ),
          -2
        ),
        -3
      )
      
      authors <- sub(".*- family: ", "", grep("- family:", article, value = TRUE))
      # if (isTRUE(grepl("first", grep("annote:", article, value = TRUE)))) {
      #   first <- "  first: '*As first or co-first*'"
      # } else {
      #   first <- sprintf("  first: '%s'", paste(rep("&emsp;", 3), collapse = ""))
      # }
      # position <- sprintf("  position: '%s/%s'", grep(author, authors), length(authors))
      article <- c(
        article,
        sub("  container-title: (.*)", "  journal-title: '*\\1*'", grep("  container-title:", article, value = TRUE)),
        sub("  issued: ", "  date: ", grep("  issued:", article, value = TRUE)),
        sub("  doi: ", "  path: https://doi.org/", grep("doi:", article, value = TRUE))
        # position,
        # first
      )
      article
    }
  )
  writeLines(text = unlist(articles), con = sub("\\.bib$", ".yml", bib_file))
}

