# ContextLinkr 0.1.0

## Internal alpha release

- Added end-to-end linkage from individual-level records to Census tract geography.
- Added Cancer InFocus contextual data retrieval from hosted ContextLinkr Parquet files.
- Added `available_context_measures()`, `search_context_measures()`, `get_context()`, and `add_context()`.
- Added optional Cancer InFocus context enrichment through `link_context(include_context = TRUE)`.
- Added context summary, success, failure, and missing-key helper workflows.
- Added README documentation for typical workflows, Cancer InFocus context retrieval, and privacy/data flow.
- Added opt-in live integration tests for hosted Cancer InFocus context data.
