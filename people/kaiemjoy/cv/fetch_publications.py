#!/usr/bin/env python3
"""
Fetch publications from NCBI for Dr. Kristen Aiemjoy
This script fetches publications from the NCBI Bibliography API and formats them
"""

import json
import urllib.request
import urllib.error
import sys
from datetime import datetime

# NCBI My Bibliography collection ID for Dr. Aiemjoy
NCBI_COLLECTION_ID = "1xIGpkekG9FQP"
NCBI_API_BASE = f"https://www.ncbi.nlm.nih.gov/sites/myncbi/{NCBI_COLLECTION_ID}/bibliography/public/"

def fetch_ncbi_publications(format_type="json", limit=200):
    """
    Fetch publications from NCBI My Bibliography
    
    Args:
        format_type: Output format (json, csv, bibtex)
        limit: Maximum number of publications to fetch
    
    Returns:
        Publications data or None if request fails
    """
    url = f"{NCBI_API_BASE}?format={format_type}&limit={limit}"
    
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (compatible; CV-Generator/1.0)'
        }
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=30) as response:
            if format_type == "json":
                return json.loads(response.read().decode())
            else:
                return response.read().decode()
    except urllib.error.URLError as e:
        print(f"Error fetching from NCBI: {e}", file=sys.stderr)
        return None
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        return None

def fetch_pubmed_via_eutils(author="Aiemjoy K", max_results=200):
    """
    Alternative: Fetch publications using NCBI E-utilities (PubMed)
    
    Args:
        author: Author name to search
        max_results: Maximum results to return
    
    Returns:
        List of PubMed IDs
    """
    search_url = f"https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term={urllib.parse.quote(author)}[Author]&retmax={max_results}&retmode=json"
    
    try:
        with urllib.request.urlopen(search_url, timeout=30) as response:
            data = json.loads(response.read().decode())
            return data.get('esearchresult', {}).get('idlist', [])
    except Exception as e:
        print(f"Error fetching from PubMed: {e}", file=sys.stderr)
        return []

def fetch_pubmed_details(pmids):
    """
    Fetch detailed publication information for given PubMed IDs
    
    Args:
        pmids: List of PubMed IDs
    
    Returns:
        Publication details in JSON format
    """
    if not pmids:
        return []
    
    pmid_str = ",".join(pmids)
    fetch_url = f"https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id={pmid_str}&retmode=xml"
    
    try:
        with urllib.request.urlopen(fetch_url, timeout=60) as response:
            return response.read().decode()
    except Exception as e:
        print(f"Error fetching publication details: {e}", file=sys.stderr)
        return None

def format_for_yaml(publications_data):
    """
    Format publication data for YAML output compatible with Quarto
    This is a placeholder - actual implementation depends on the data structure
    """
    # This would need to be implemented based on the actual data structure
    # returned from NCBI
    pass

if __name__ == "__main__":
    print("Fetching publications from NCBI...", file=sys.stderr)
    
    # Try NCBI My Bibliography first
    pubs = fetch_ncbi_publications()
    
    if pubs:
        print(json.dumps(pubs, indent=2))
    else:
        # Fallback to PubMed E-utilities
        print("Trying PubMed E-utilities as fallback...", file=sys.stderr)
        pmids = fetch_pubmed_via_eutils("Aiemjoy K")
        
        if pmids:
            print(f"Found {len(pmids)} publications", file=sys.stderr)
            print(json.dumps(pmids, indent=2))
        else:
            print("No publications found", file=sys.stderr)
            sys.exit(1)
