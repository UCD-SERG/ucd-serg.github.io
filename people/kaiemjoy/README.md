# Dr. Kristen Aiemjoy - CV

This directory contains Dr. Aiemjoy's CV page and related files.

## Current Status

**Important**: The CV currently displays **17 publications** from the lab's main `publications.yml` file. Dr. Aiemjoy's complete NCBI My Bibliography profile contains **41 publications**. 

To update with all 41 publications, please:
1. Fetch publications directly from [NCBI](https://www.ncbi.nlm.nih.gov/myncbi/1xIGpkekG9FQP/bibliography/public/) when network access is available, OR
2. Manually export and add the missing publications to the lab's `publications.yml` file

## Files

- `kaiemjoy-cv.qmd` - The main CV page in Quarto markdown format
- `cv/publications.yml` - Formatted publications data (17 publications)
- `cv/publications_include.html` - HTML file for publications with proper hyperlinks
- `cv/fetch_from_ncbi.R` - **NEW** R script to fetch publications directly from NCBI E-utilities API
- `cv/reformat_publications.R` - R script to reformat publications in LaTeX CV style
- `cv/generate_html.R` - R script to generate HTML file from publications.yml
- `cv/generate_publications_html.R` - R script to generate HTML with proper hyperlinks
- `cv/extract_publications.R` - R script to extract Dr. Aiemjoy's publications from main publications.yml

## Updating Publications

### Option 1: Fetch Directly from NCBI (Recommended)

Use the `fetch_from_ncbi.R` script to fetch all publications directly from Dr. Aiemjoy's NCBI My Bibliography profile:

```bash
cd /path/to/ucd-serg.github.io

# Step 1: Fetch all publications from NCBI E-utilities API
Rscript people/kaiemjoy/cv/fetch_from_ncbi.R

# Step 2: Generate HTML file (ensures proper hyperlinks and rendering)
Rscript people/kaiemjoy/cv/generate_html.R

# Step 3: Render the CV
quarto render people/kaiemjoy/kaiemjoy-cv.qmd
```

**Requirements**: The `fetch_from_ncbi.R` script requires the following R packages:
- `yaml`
- `jsonlite`
- `xml2`

Install them with:
```r
install.packages(c("yaml", "jsonlite", "xml2"))
```

### Option 2: Use Lab's publications.yml File

When new publications are added to the lab's `publications.yml`, run the following commands to update the CV:

```bash
cd /path/to/ucd-serg.github.io

# Step 1: Reformat publications from main lab file
Rscript people/kaiemjoy/cv/reformat_publications.R

# Step 2: Generate HTML file (ensures proper hyperlinks and rendering)
Rscript people/kaiemjoy/cv/generate_html.R

# Step 3: Render the CV
quarto render people/kaiemjoy/kaiemjoy-cv.qmd
```

The reformatting script (`reformat_publications.R`):
1. Extracts publications where Dr. Aiemjoy is an author
2. Formats them in LaTeX CV style with HTML links: `Last FI, Last FI, **Aiemjoy K**, ... <a href="DOI">title</a>. Journal. Year. DOI: xxx.`
3. Saves to `cv/publications.yml`

The NCBI fetch script (`fetch_from_ncbi.R`):
1. Queries NCBI E-utilities API for all publications by Dr. Aiemjoy
2. Fetches full publication details including authors, title, journal, DOI, PMID
3. Formats them in LaTeX CV style with HTML links
4. Saves directly to `cv/publications.yml`

The HTML generation script (`generate_html.R`):
1. Reads the formatted publications from YAML
2. Generates proper HTML with bolding, italics, and clickable hyperlinks
3. Saves to `cv/publications_include.html` which is included in the CV page

## Publication Format

Publications are displayed with:
- Full author lists with initials (e.g., "Seidman JC, **Aiemjoy K**, Adnan M, ...")
- **Aiemjoy K** bolded using HTML `<strong>` tags
- **Hyperlinked titles** using HTML `<a>` tags (clickable links to DOI)
- Journal names in italics using HTML `<em>` tags
- Year and DOI information

## R Package Requirements

The R scripts require the following packages:

- `yaml` - Required by all scripts
- `jsonlite` - Required by `fetch_from_ncbi.R` for JSON parsing
- `xml2` - Required by `fetch_from_ncbi.R` for XML parsing

Install them with:

```r
install.packages(c("yaml", "jsonlite", "xml2"))
```

## Publication Source

The CV can pull publications from two sources:

1. **NCBI E-utilities API** (Recommended) - Use `fetch_from_ncbi.R` to fetch all 41 publications directly from Dr. Aiemjoy's NCBI My Bibliography profile:
   https://www.ncbi.nlm.nih.gov/myncbi/1xIGpkekG9FQP/bibliography/public/

2. **Lab's publications.yml** (Current) - Use `reformat_publications.R` to extract from the main lab file (currently contains only 17 of 41 publications).

**Note**: The NCBI fetch script is now available and can retrieve all 41 publications directly from NCBI when network access is available.

## CV Structure

The CV includes the following sections:
- Positions
- Education
- Research Interests
- Peer-Reviewed Publications (currently 17, should be 41 from NCBI)
- Presentations
- Honors and Awards
- Professional Service
- Teaching
- Grants and Funding

Sections can be updated by editing the `kaiemjoy-cv.qmd` file directly.
