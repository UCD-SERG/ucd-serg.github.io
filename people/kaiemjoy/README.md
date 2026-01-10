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
- `cv/reformat_publications.R` - R script to reformat publications in LaTeX CV style
- `cv/generate_html.R` - R script to generate HTML file from publications.yml
- `cv/generate_publications_html.R` - R script to generate HTML with proper hyperlinks
- `cv/extract_publications.R` - R script to extract Dr. Aiemjoy's publications from main publications.yml

## Updating Publications

Publications on the CV are sourced from the main lab `publications.yml` file, which should be synced with Dr. Aiemjoy's NCBI My Bibliography profile (https://www.ncbi.nlm.nih.gov/myncbi/1xIGpkekG9FQP/bibliography/public/).

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

The reformatting script:
1. Extracts publications where Dr. Aiemjoy is an author
2. Formats them in LaTeX CV style with HTML links: `Last FI, Last FI, **Aiemjoy K**, ... <a href="DOI">title</a>. Journal. Year. DOI: xxx.`
3. Saves to `cv/publications.yml`

The HTML generation script:
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

The R scripts require the `yaml` package. Install it with:

```r
install.packages("yaml")
```

## Publication Source

Publications are sourced from the main lab `publications.yml` file, which should be regularly synced with Dr. Aiemjoy's NCBI My Bibliography profile at:
https://www.ncbi.nlm.nih.gov/myncbi/1xIGpkekG9FQP/bibliography/public/

**Note**: Currently only 17 of 41 publications are in the lab file. Full sync with NCBI is needed.

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
