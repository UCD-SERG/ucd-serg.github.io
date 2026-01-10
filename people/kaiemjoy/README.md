# Dr. Kristen Aiemjoy - CV

This directory contains Dr. Aiemjoy's CV page and related files.

## Files

- `kaiemjoy-cv.qmd` - The main CV page in Quarto markdown format
- `cv/publications.yml` - Formatted publications data
- `cv/publications_include.html` - HTML file for publications (generated from YAML)
- `cv/reformat_publications.R` - R script to reformat publications in LaTeX CV style
- `cv/generate_html.R` - R script to generate HTML file from publications.yml
- `cv/extract_publications.R` - R script to extract Dr. Aiemjoy's publications from main publications.yml

## Updating Publications

Publications on the CV are sourced from the main lab `publications.yml` file, which is synced with Dr. Aiemjoy's NCBI My Bibliography profile (https://www.ncbi.nlm.nih.gov/myncbi/1xIGpkekG9FQP/bibliography/public/).

When new publications are added to the lab's `publications.yml`, run the following commands to update the CV:

```bash
cd /path/to/ucd-serg.github.io

# Step 1: Reformat publications from main lab file
Rscript people/kaiemjoy/cv/reformat_publications.R

# Step 2: Generate HTML file (ensures proper bold rendering)
Rscript people/kaiemjoy/cv/generate_html.R

# Step 3: Render the CV
quarto render people/kaiemjoy/kaiemjoy-cv.qmd
```

The reformatting script:
1. Extracts publications where Dr. Aiemjoy is an author
2. Formats them in LaTeX CV style: `Last FI, Last FI, **Aiemjoy K**, ... [hyperlinked title]. Journal. Year. DOI: xxx.`
3. Saves to `cv/publications.yml`

The HTML generation script:
1. Reads the formatted publications from YAML
2. Generates proper HTML with bolding and italics
3. Saves to `cv/publications_include.html` which is included in the CV page

## Publication Format

Publications are displayed with:
- Full author lists with initials (e.g., "Seidman JC, **Aiemjoy K**, Adnan M, ...")
- **Aiemjoy K** bolded using HTML `<strong>` tags
- Hyperlinked titles (linked to DOI when available)
- Journal names in italics using HTML `<em>` tags
- Year and DOI information

## R Package Requirements

The R scripts require the `yaml` package. Install it with:

```r
install.packages("yaml")
```

## Publication Source

Publications are sourced from the main lab `publications.yml` file, which is regularly synced with Dr. Aiemjoy's NCBI My Bibliography profile at:
https://www.ncbi.nlm.nih.gov/myncbi/1xIGpkekG9FQP/bibliography/public/

This ensures all publications from her NCBI profile are automatically included in the CV.

## CV Structure

The CV includes the following sections:
- Positions
- Education
- Research Interests
- Peer-Reviewed Publications (auto-populated from NCBI via main lab file)
- Presentations
- Honors and Awards
- Professional Service
- Teaching
- Grants and Funding

Sections can be updated by editing the `kaiemjoy-cv.qmd` file directly.
