# List of DOIs
dois <- c("10.1038/s41586-019-1666-5")

# Fetch metadata for each DOI and add container-title-short if missing
references <- lapply(dois, function(doi) {
  metadata <- cr_cn(doi, format = "citeproc-json")
  
  if (is.null(metadata$`container-title-short`)) {
    metadata$`container-title-short` <- metadata$`container-title`  # Fallback
  }
  metadata$date = metadata$issued
  to_keep = c("author","title", "type", "container-title", "container-title-short", "date")
  metadata = metadata[to_keep]
  return(metadata)
})

# Combine into a single list
quarto_metadata <- list(references = references)

# Convert to YAML and save
yaml_output <- as.yaml(quarto_metadata)
writeLines(yaml_output, "metadata_with_short_container.yaml")