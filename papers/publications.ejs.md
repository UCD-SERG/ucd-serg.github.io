```{=html}
<%
const publicationYear = (item) => {
  const match = String(item.date || item.issued || "").match(/\d{4}/);
  return match ? match[0] : "Date unavailable";
};
const yearGroups = new Map();
for (const item of items) {
  const year = publicationYear(item);
  if (!yearGroups.has(year)) yearGroups.set(year, []);
  yearGroups.get(year).push(item);
}
%>
<section class="publication-index" aria-labelledby="all-publications-heading">
  <div class="publication-index-heading">
    <div>
      <h2 id="all-publications-heading">All publications</h2>
      <p class="publication-list-note"><%= items.length %> publications, listed by year with the newest work first.</p>
    </div>
    <p class="publication-notation"><span class="publication-badge publication-badge--preprint">Preprint</span> identifies work that has not yet been peer reviewed.</p>
  </div>

  <div class="publication-list">
    <% for (const [year, yearItems] of yearGroups) { %>
      <section class="publication-year-section" aria-labelledby="publication-year-<%= year %>">
        <h3 id="publication-year-<%= year %>" class="publication-year-heading">
          <span><%= year %></span>
          <small><%= yearItems.length %> publication<%= yearItems.length === 1 ? "" : "s" %></small>
        </h3>
        <div class="publication-year-list">
          <% for (const item of yearItems) { %>
            <article class="publication-entry">
              <div class="publication-title-row">
                <h4 class="publication-title">
                  <a href="<%= item.path || item.url || "#" %>"><%= item.title %></a>
                </h4>
                <% if (item.categories && item.categories.includes("preprint")) { %>
                  <span class="publication-badge publication-badge--preprint">Preprint</span>
                <% } %>
              </div>
              <div class="publication-meta">
                <% if (item["container-title"] || item["journal-title"] || item.publisher) { %>
                  <span class="publication-journal"><%= item["container-title"] || item["journal-title"] || item.publisher %></span>
                <% } %>
                <% if (item.date || item.issued) { %>
                  <span><%= item.date || item.issued %></span>
                <% } %>
              </div>
              <div class="publication-links" aria-label="Links for <%= item.title %>">
                <% if (item.url || item.path) { %>
                  <a href="<%= item.url || item.path %>">Article</a>
                <% } %>
                <% if (item.doi) { %>
                  <a href="https://doi.org/<%= item.doi %>">DOI</a>
                <% } %>
                <% if (item.PMID) { %>
                  <a href="https://pubmed.ncbi.nlm.nih.gov/<%= item.PMID %>/">PubMed</a>
                <% } %>
                <% if (item.pdf) { %>
                  <a href="<%= item.pdf %>">PDF</a>
                <% } %>
              </div>
              <details class="publication-abstract">
                <summary>Abstract</summary>
                <% if (item.abstract) { %>
                  <p><%= item.abstract %></p>
                <% } else { %>
                  <p>The abstract is available from the <a href="<%= item.url || item.path || "#" %>">publisher</a>.</p>
                <% } %>
              </details>
            </article>
          <% } %>
        </div>
      </section>
    <% } %>
  </div>
</section>
```
