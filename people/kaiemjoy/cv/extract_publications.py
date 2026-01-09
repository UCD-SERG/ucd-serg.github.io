#!/usr/bin/env python3
"""
Extract publications for Dr. Kristen Aiemjoy from the main publications.yml file
"""

import yaml
import sys

def format_authors(authors):
    """Format author list with Aiemjoy in bold markers"""
    author_strs = []
    for author in authors:
        name = f"{author.get('given', '')} {author.get('family', '')}".strip()
        if author.get('family') == 'Aiemjoy':
            name = f"**{name}**"
        author_strs.append(name)
    return ', '.join(author_strs)

def extract_aiemjoy_publications(input_file='publications.yml', output_file='people/kaiemjoy/cv/publications.yml'):
    """
    Extract publications where Aiemjoy is an author
    """
    try:
        with open(input_file, 'r') as f:
            # Read the YAML file
            content = f.read()
            publications = yaml.safe_load(content)
        
        if not publications:
            print("No publications found in input file", file=sys.stderr)
            return
        
        # Filter publications where Aiemjoy is an author
        aiemjoy_pubs = []
        for pub in publications:
            if 'author' in pub:
                authors = pub['author']
                for author in authors:
                    if isinstance(author, dict) and author.get('family') == 'Aiemjoy':
                        # Add formatted author field
                        pub['authors_formatted'] = format_authors(pub['author'])
                        # Extract year from issued
                        if 'issued' in pub:
                            issued = pub['issued']
                            if isinstance(issued, str):
                                pub['year'] = issued[:4]
                            else:
                                pub['year'] = str(issued)[:4] if issued else ''
                        aiemjoy_pubs.append(pub)
                        break
        
        print(f"Found {len(aiemjoy_pubs)} publications for Dr. Aiemjoy", file=sys.stderr)
        
        # Write to output file
        with open(output_file, 'w') as f:
            yaml.dump(aiemjoy_pubs, f, default_flow_style=False, sort_keys=False, allow_unicode=True)
        
        print(f"Saved to {output_file}", file=sys.stderr)
        
    except FileNotFoundError:
        print(f"File {input_file} not found", file=sys.stderr)
        sys.exit(1)
    except yaml.YAMLError as e:
        print(f"Error parsing YAML: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    extract_aiemjoy_publications()
