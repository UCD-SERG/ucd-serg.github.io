source_file <- file.path("R", "create_pub_listing.R")
if (!file.exists(source_file)) {
  source_file <- file.path("..", "R", "create_pub_listing.R")
}
source(source_file)

month_names <- c(month.name, "Sept")
month_macros <- c(tolower(month.abb), "sep")

for (i in seq_along(month_names)) {
  for (delimiter in c("bare", "braced", "quoted")) {
    value <- switch(
      delimiter,
      bare = month_names[[i]],
      braced = paste0("{", month_names[[i]], "}"),
      quoted = paste0('"', month_names[[i]], '"')
    )
    input <- paste0("@article{key, month=", value, "}")
    expected <- paste0("@article{key, month=", month_macros[[i]], "}")
    stopifnot(identical(normalize_bibtex_months(input), expected))
  }
}

unchanged <- c(
  "@article{key, month={Marching}}",
  "@article{key, month={September 15}}",
  "@article{key, month={May 2025}}",
  "@article{key, month=jul}",
  "@article{key, title={month=July}}",
  "@article{key, note={foo, month=March, bar}}",
  "@article{key, title={prefix, month=July}}"
)
stopifnot(identical(normalize_bibtex_months(unchanged), unchanged))
