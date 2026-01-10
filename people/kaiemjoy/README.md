# Dr. Kristen Aiemjoy - CV

This directory contains Dr. Aiemjoy's CV page and related files.

## Files

- `kaiemjoy-cv.qmd` - The main CV page in Quarto markdown format
- `cv/publications.yml` - Formatted publications data
- `cv/publication-simple-template.ejs` - EJS template for rendering publications
- `cv/reformat_publications.R` - R script to reformat publications in LaTeX CV style
- `cv/extract_publications.R` - R script to extract Dr. Aiemjoy's publications from main publications.yml

## Updating Publications

Publications on the CV are sourced from the main lab publications list. When new publications are added to the lab's `publications.yml`, run the following command to update the CV:

```bash
cd /path/to/ucd-serg.github.io
Rscript people/kaiemjoy/cv/reformat_publications.R
quarto render people/kaiemjoy/kaiemjoy-cv.qmd
```

The reformatting script:
1. Extracts publications where Dr. Aiemjoy is an author
2. Formats them in LaTeX CV style: `Last FI, Last FI, **Aiemjoy K**, ... [hyperlinked title]. Journal. Year. DOI: xxx.`
3. Saves to `cv/publications.yml`

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

## CV Structure

The CV includes the following sections:
- Positions
- Education
- Research Interests
- Peer-Reviewed Publications (auto-populated)
- Presentations
- Honors and Awards
- Professional Service
- Teaching
- Grants and Funding

Sections can be updated by editing the `kaiemjoy-cv.qmd` file directly.
