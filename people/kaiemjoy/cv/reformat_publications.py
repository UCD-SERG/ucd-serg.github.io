#!/usr/bin/env python3
"""
Reformat publications for Dr. Aiemjoy's CV in LaTeX style
Reads from the original publications and reformats them
"""

import yaml
import re
import sys

def get_initials(given_name):
    """
    Extract initials from a given name
    Examples: 
      "Jessica C." -> "JC"
      "Kristen" -> "K"
      "Alice S." -> "AS"
    """
    if not given_name:
        return ''
    
    # Remove periods and split
    parts = given_name.replace('.', '').split()
    
    # Get first letter of each part
    initials = ''.join([p[0].upper() for p in parts if p])
    
    return initials

def format_author(last, given):
    """
    Format author as: Last FI (where F is first initial, I is middle initial)
    """
    initials = get_initials(given)
    
    if not initials:
        return last
    
    formatted = f"{last} {initials}"
    
    # Bold Aiemjoy using HTML tags (not markdown)
    if last == "Aiemjoy":
        formatted = f"<strong>{formatted}</strong>"
    
    return formatted

def format_publication(pub):
    """
    Format publication in LaTeX CV style:
    Last FI, Last FI, **Aiemjoy K**, ... [hyperlinked title]. Journal. Year;vol(issue):pages. PMID: xxx.
    """
    # Format authors
    authors_list = pub.get('author', [])
    formatted_authors = []
    
    for author in authors_list:
        last = author.get('family', '')
        given = author.get('given', '')
        formatted = format_author(last, given)
        formatted_authors.append(formatted)
    
    authors_str = ', '.join(formatted_authors)
    
    # Get title
    title = pub.get('title', '')
    
    # Get DOI
    doi = pub.get('doi', '')
    
    # Get journal
    journal = pub.get('journal-title', pub.get('container-title', ''))
    
    # Remove markdown asterisks from journal if present
    if journal:
        journal = journal.strip('*')
    
    # Get date/year
    issued = pub.get('issued', pub.get('date', ''))
    if isinstance(issued, str):
        # Extract just the year from full dates like "2025-06-23"
        year = issued[:4]
        date_str = issued
    else:
        year = str(issued) if issued else ''
        date_str = year
    
    # Get volume, issue, pages (if available in future)
    volume = ''
    issue = ''
    pages = ''
    
    # Build formatted string
    formatted = f"{authors_str}. "
    
    # Add hyperlinked title
    if doi:
        formatted += f"[{title}](https://doi.org/{doi}). "
    else:
        url = pub.get('url', pub.get('path', ''))
        if url:
            formatted += f"[{title}]({url}). "
        else:
            formatted += f"{title}. "
    
    # Add journal in italics (using HTML tags)
    if journal:
        formatted += f"<em>{journal}</em>. "
    
    # Add date/citation
    if year:
        citation_parts = [year]
        # If we had volume/issue/pages, would add here
        formatted += f"{year}. "
    
    # Add DOI
    if doi:
        formatted += f"DOI: {doi}."
    
    return formatted.strip()

def main():
    # Read original publications file
    # First try from temp location (if running after git show command)
    # Otherwise read from main publications.yml
    input_file = '/tmp/original_pubs.yml'
    
    try:
        with open(input_file, 'r') as f:
            publications = yaml.safe_load(f)
    except FileNotFoundError:
        print(f"File not found: {input_file}", file=sys.stderr)
        print("Using publications from current directory instead", file=sys.stderr)
        input_file = 'publications.yml'
        with open(input_file, 'r') as f:
            all_pubs = yaml.safe_load(f)
        
        # Filter for Aiemjoy publications
        publications = []
        for pub in all_pubs:
            if 'author' in pub:
                for author in pub['author']:
                    if isinstance(author, dict) and author.get('family') == 'Aiemjoy':
                        publications.append(pub)
                        break
    
    if not publications:
        print("No publications found", file=sys.stderr)
        sys.exit(1)
    
    print(f"Processing {len(publications)} publications...", file=sys.stderr)
    
    # Format all publications
    formatted_pubs = []
    
    for i, pub in enumerate(publications):
        formatted_str = format_publication(pub)
        
        # Extract year for sorting
        issued = pub.get('issued', pub.get('date', ''))
        if isinstance(issued, str):
            year = issued[:4]
        else:
            year = str(issued) if issued else '0'
        
        formatted_pub = {
            'formatted': formatted_str,
            'year': year,
            'title': pub.get('title', ''),
            'doi': pub.get('doi', '')
        }
        
        formatted_pubs.append(formatted_pub)
        
        # Print first few for verification
        if i < 3:
            print(f"\n{i+1}. {formatted_str}\n", file=sys.stderr)
    
    # Sort by year descending
    formatted_pubs.sort(key=lambda x: x['year'], reverse=True)
    
    # Write to output file
    output_file = 'people/kaiemjoy/cv/publications.yml'
    with open(output_file, 'w') as f:
        yaml.dump(formatted_pubs, f, default_flow_style=False, sort_keys=False, allow_unicode=True)
    
    print(f"\nSaved {len(formatted_pubs)} publications to {output_file}", file=sys.stderr)

if __name__ == "__main__":
    main()
