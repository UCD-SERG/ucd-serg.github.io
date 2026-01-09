# Dr. Kristen Aiemjoy - CV

This directory contains Dr. Aiemjoy's CV page and related files.

## Files

- `kaiemjoy-cv.qmd` - The main CV page in Quarto markdown format
- `cv/publications.yml` - Publications data extracted from the main publications.yml
- `cv/fetch_publications.py` - Python script to fetch publications from NCBI (for future use)
- `cv/extract_publications.py` - Python script to extract Dr. Aiemjoy's publications from the main publications.yml

## Updating Publications

Publications on the CV are automatically synchronized with the main lab publications list. When new publications are added to the lab's `publications.yml`, run the following command to update the CV:

```bash
cd /path/to/ucd-serg.github.io
python3 people/kaiemjoy/cv/extract_publications.py
quarto render people/kaiemjoy/kaiemjoy-cv.qmd
```

Alternatively, when the entire site is rendered with `quarto render`, the CV will be automatically updated.

## Future Enhancement: Direct NCBI Fetch

The `fetch_publications.py` script is provided for future use to fetch publications directly from NCBI's My Bibliography API. This requires network access to NCBI servers. When available, publications can be fetched using:

```bash
python3 people/kaiemjoy/cv/fetch_publications.py > people/kaiemjoy/cv/ncbi_publications.json
```

The script would need to be enhanced to convert NCBI JSON/XML format to the YAML format used by Quarto.

## CV Structure

The CV includes the following sections:
- Contact Information
- Education
- Professional Experience
- Research Interests
- Publications (auto-populated)
- Selected Honors and Awards
- Professional Service
- Teaching

Sections can be updated by editing the `kaiemjoy-cv.qmd` file directly.
