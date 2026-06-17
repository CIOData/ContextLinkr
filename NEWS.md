# ContextLinkr 0.1.0.9000

### Current development

* Confirmed clean install-from-GitHub smoke test for `get_context()` and `add_context()` using hosted Cancer InFocus tract context data.

### Collaborator beta hardening

* Added hosted Cancer InFocus contextual data retrieval through `get_context()` and `add_context()`.
* Added local caching, cache inspection, and cache-clearing support for hosted context files.
* Added source metadata and provenance helpers through `context_data_sources()` and `context_provenance()`.
* Fixed wide-format context output so tract labels from different source files do not create duplicate rows per `GEOID`.
* Added opt-in live Cancer InFocus integration tests using `CONTEXTLINKR_RUN_CIF_INTEGRATION=true`.

### Core workflows

* Added end-to-end linkage workflows for linking individual-level records to Census tract identifiers and Cancer InFocus contextual measures.
* Added public geocoding helpers: `gc_address()`, `geocode_summary()`, `geocode_successes()`, and `geocode_failures()`.
* Added public tract-identification helpers: `id_tract()`, `tract_summary()`, `tract_successes()`, and `tract_failures()`.
* Added public end-to-end linkage helpers: `link_context()`, `link_summary()`, `link_successes()`, and `link_failures()`.

### Cancer InFocus context data

* Added Cancer InFocus context retrieval using hosted Parquet files from `https://cancerinfocus.org/public-data/ContextLinkr`.
* Added measure discovery helpers: `available_context_measures()` and `search_context_measures()`.
* Added context retrieval and enrichment helpers: `get_context()` and `add_context()`.
* Added support for tract-level hosted data partitioned by `state_fips`.
* Added support for hosted measure metadata from `context_measures.parquet`.

### Cache, source metadata, and provenance

* Added local caching for hosted Cancer InFocus context files.
* Added cache controls through `use_cache`, `refresh_cache`, `context_cache`, and `context_refresh_cache`.
* Added public cache helpers: `context_cache_info()` and `clear_context_cache(confirm = TRUE)`.
* Added hosted source metadata helper: `context_data_sources()`.
* Added output provenance helper: `context_provenance()`.
* Added context provenance metadata to outputs from `get_context()`, `add_context()`, and `link_context(include_context = TRUE)`.

### Documentation and testing

* Added README sections covering typical workflows, privacy and data flow, Cancer InFocus context retrieval, cache behavior, source metadata, and provenance.
* Added workflow vignette.
* Added collaborator testing guide.
* Added GitHub issue templates for collaborator feedback and bug reports.
* Added pull request template and release checklist.
* Added GitHub Actions package checks.
* Added opt-in live Cancer InFocus integration tests using `CONTEXTLINKR_RUN_CIF_INTEGRATION=true`.

### Error handling and reliability

* Added friendlier errors for remote Parquet read failures.
* Added cache refresh and cache-clearing workflows for troubleshooting hosted data reads.
