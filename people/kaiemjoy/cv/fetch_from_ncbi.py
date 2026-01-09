#!/usr/bin/env python3
"""
Fetch and format publications from NCBI for Dr. Kristen Aiemjoy's CV
Fetches from her personal NCBI My Bibliography profile
Formats in LaTeX CV style: Last name, First Middle initial. with hyperlinks
"""

import json
import urllib.request
import urllib.error
import urllib.parse
import sys
import xml.etree.ElementTree as ET
from datetime import datetime
import yaml
import re

def fetch_pubmed_ids(author="Aiemjoy K[Author]", max_results=200):
    """
    Fetch PubMed IDs for Dr. Aiemjoy's publications using E-utilities
    """
    search_url = f"https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term={urllib.parse.quote(author)}&retmax={max_results}&retmode=json&sort=pub+date"
    
    try:
        with urllib.request.urlopen(search_url, timeout=30) as response:
            data = json.loads(response.read().decode())
            pmids = data.get('esearchresult', {}).get('idlist', [])
            print(f"Found {len(pmids)} publications from PubMed", file=sys.stderr)
            return pmids
    except Exception as e:
        print(f"Error fetching from PubMed: {e}", file=sys.stderr)
        return []

def fetch_pubmed_details_xml(pmids):
    """
    Fetch detailed publication information in XML format
    """
    if not pmids:
        return None
    
    # Batch process in chunks of 100
    all_xml = []
    for i in range(0, len(pmids), 100):
        batch = pmids[i:i+100]
        pmid_str = ",".join(batch)
        fetch_url = f"https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id={pmid_str}&retmode=xml"
        
        try:
            print(f"Fetching batch {i//100 + 1}...", file=sys.stderr)
            with urllib.request.urlopen(fetch_url, timeout=60) as response:
                xml_data = response.read().decode()
                all_xml.append(xml_data)
        except Exception as e:
            print(f"Error fetching publication details: {e}", file=sys.stderr)
    
    # Combine XML
    if all_xml:
        return '\n'.join(all_xml)
    return None

def format_author_name(last, first, initials=''):
    """
    Format author name as: Last F, or Last FM if middle initial exists
    Aiemjoy should be bolded
    """
    # Get first initial
    first_initial = first[0].upper() if first else ''
    
    # Get middle initial if present
    middle_initial = initials[0].upper() if initials and len(initials) > 0 else ''
    
    # Format: Last FI or Last F
    if middle_initial:
        formatted = f"{last} {first_initial}{middle_initial}"
    else:
        formatted = f"{last} {first_initial}"
    
    # Bold Aiemjoy
    if last == "Aiemjoy":
        formatted = f"**{formatted}**"
    
    return formatted

def parse_pubmed_xml(xml_data):
    """
    Parse PubMed XML and extract publication details
    """
    publications = []
    
    try:
        # Parse XML
        root = ET.fromstring(f'<root>{xml_data}</root>')
        
        for article in root.findall('.//PubmedArticle'):
            pub = {}
            
            # Get PMID
            pmid_elem = article.find('.//PMID')
            pub['pmid'] = pmid_elem.text if pmid_elem is not None else ''
            
            # Get title
            title_elem = article.find('.//ArticleTitle')
            if title_elem is not None:
                pub['title'] = ''.join(title_elem.itertext()).strip()
            else:
                pub['title'] = ''
            
            # Get authors
            authors = []
            author_list = article.find('.//AuthorList')
            if author_list is not None:
                for author in author_list.findall('Author'):
                    last_elem = author.find('LastName')
                    first_elem = author.find('ForeName')
                    initials_elem = author.find('Initials')
                    
                    if last_elem is not None:
                        last = last_elem.text
                        first = first_elem.text if first_elem is not None else ''
                        initials = initials_elem.text if initials_elem is not None else ''
                        
                        formatted_author = format_author_name(last, first, initials)
                        authors.append(formatted_author)
            
            pub['authors'] = authors
            
            # Get journal
            journal_elem = article.find('.//Journal/Title')
            if journal_elem is None:
                journal_elem = article.find('.//Journal/ISOAbbreviation')
            pub['journal'] = journal_elem.text if journal_elem is not None else ''
            
            # Get publication date
            pub_date = article.find('.//PubDate')
            year = ''
            month = ''
            day = ''
            if pub_date is not None:
                year_elem = pub_date.find('Year')
                month_elem = pub_date.find('Month')
                day_elem = pub_date.find('Day')
                year = year_elem.text if year_elem is not None else ''
                month = month_elem.text if month_elem is not None else ''
                day = day_elem.text if day_elem is not None else ''
            
            pub['year'] = year
            pub['month'] = month
            pub['day'] = day
            
            # Get volume, issue, pages
            volume_elem = article.find('.//Volume')
            issue_elem = article.find('.//Issue')
            pages_elem = article.find('.//MedlinePgn')
            
            pub['volume'] = volume_elem.text if volume_elem is not None else ''
            pub['issue'] = issue_elem.text if issue_elem is not None else ''
            pub['pages'] = pages_elem.text if pages_elem is not None else ''
            
            # Get DOI
            doi = ''
            for article_id in article.findall('.//ArticleId'):
                if article_id.get('IdType') == 'doi':
                    doi = article_id.text
                    break
            pub['doi'] = doi
            
            publications.append(pub)
            
    except Exception as e:
        print(f"Error parsing XML: {e}", file=sys.stderr)
    
    return publications

def format_publication_for_cv(pub):
    """
    Format publication in the requested LaTeX CV style:
    Authors. [hyperlinked title]. Journal. Date;volume(issue):pages. PMID: xxxxx.
    """
    # Format authors
    author_str = ', '.join(pub['authors']) if pub['authors'] else ''
    
    # Format date
    date_parts = []
    if pub['year']:
        date_parts.append(pub['year'])
    if pub['month']:
        # Convert month name to abbreviated form if needed
        month_abbrev = pub['month'][:3] if len(pub['month']) > 3 else pub['month']
        date_parts.append(month_abbrev)
    if pub['day']:
        date_parts.append(pub['day'])
    date_str = ' '.join(date_parts)
    
    # Format volume/issue/pages
    citation_parts = []
    if pub['volume']:
        vol_str = pub['volume']
        if pub['issue']:
            vol_str += f"({pub['issue']})"
        citation_parts.append(vol_str)
    if pub['pages']:
        citation_parts.append(pub['pages'])
    citation_str = ':'.join(citation_parts) if citation_parts else ''
    
    # Create the formatted publication
    formatted = f"{author_str}. "
    
    # Add hyperlinked title
    if pub['doi']:
        formatted += f"[{pub['title']}](https://doi.org/{pub['doi']}). "
    else:
        formatted += f"{pub['title']}. "
    
    # Add journal in italics
    if pub['journal']:
        formatted += f"*{pub['journal']}*. "
    
    # Add date and citation
    if date_str and citation_str:
        formatted += f"{date_str};{citation_str}. "
    elif date_str:
        formatted += f"{date_str}. "
    
    # Add PMID
    if pub['pmid']:
        formatted += f"PMID: {pub['pmid']}."
    
    return formatted.strip()

def create_publications_yaml(publications):
    """
    Create YAML format for publications with formatted strings
    """
    yaml_pubs = []
    
    for pub in publications:
        yaml_pub = {
            'formatted': format_publication_for_cv(pub),
            'year': pub['year'],
            'pmid': pub['pmid'],
            'doi': pub['doi'],
            'title': pub['title']
        }
        yaml_pubs.append(yaml_pub)
    
    return yaml_pubs

def main():
    print("Fetching publications from Dr. Aiemjoy's NCBI profile...", file=sys.stderr)
    
    # Fetch PubMed IDs
    pmids = fetch_pubmed_ids("Aiemjoy K[Author]")
    
    if not pmids:
        print("No publications found", file=sys.stderr)
        sys.exit(1)
    
    # Fetch details
    xml_data = fetch_pubmed_details_xml(pmids)
    
    if not xml_data:
        print("Failed to fetch publication details", file=sys.stderr)
        sys.exit(1)
    
    # Parse publications
    publications = parse_pubmed_xml(xml_data)
    
    print(f"Parsed {len(publications)} publications", file=sys.stderr)
    
    # Create YAML
    yaml_pubs = create_publications_yaml(publications)
    
    # Sort by year (descending)
    yaml_pubs.sort(key=lambda x: x['year'], reverse=True)
    
    # Write to file
    output_file = 'people/kaiemjoy/cv/publications.yml'
    with open(output_file, 'w') as f:
        yaml.dump(yaml_pubs, f, default_flow_style=False, sort_keys=False, allow_unicode=True)
    
    print(f"Saved {len(yaml_pubs)} publications to {output_file}", file=sys.stderr)
    
    # Also print first few for verification
    print("\nFirst 3 publications:", file=sys.stderr)
    for i, pub in enumerate(yaml_pubs[:3]):
        print(f"\n{i+1}. {pub['formatted']}", file=sys.stderr)

if __name__ == "__main__":
    main()
