#!/usr/bin/env Rscript
#
# Generate HTML publications file from publications.yml
# This ensures proper HTML rendering without escaping
#

library(yaml)

# Read publications
pubs <- read_yaml("people/kaiemjoy/cv/publications.yml")

# Generate HTML
html_lines <- c('<div class="publications-list" style="margin-top: 1em;">')

for (pub in pubs) {
  formatted <- pub$formatted
  html_line <- paste0(
    '  <p style="margin-bottom: 0.8em;">',
    formatted,
    '</p>'
  )
  html_lines <- c(html_lines, html_line)
}

html_lines <- c(html_lines, '</div>')

# Write to file
writeLines(html_lines, "people/kaiemjoy/cv/publications_include.html")

message("Generated HTML with ", length(pubs), " publications")
