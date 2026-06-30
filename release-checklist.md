# ContextLinkr release checklist

## Collaborator beta release

Use this checklist before tagging a collaborator-beta version such as `v0.1.0-beta.3`.

### Code and tests

- [ ] `devtools::document()` runs successfully.
- [ ] `devtools::test()` passes with default settings.
- [ ] `devtools::check()` passes with default settings.
- [ ] Live Cancer InFocus integration tests pass locally with `CONTEXTLINKR_RUN_CIF_INTEGRATION=true`.
- [ ] GitHub Actions pass on the default branch.
- [ ] No live hosted-data tests run by default in CI unless explicitly enabled.

### Documentation

- [ ] README reflects the current primary workflow.
- [ ] README installation instructions use the current beta tag.
- [ ] Workflow vignette reflects Cancer InFocus context retrieval as the primary workflow.
- [ ] `collaborator-testing.md` uses the current beta tag.
- [ ] GitHub issue templates are current.
- [ ] `NEWS.md` summarizes changes since the previous beta tag.

### Beta testing

- [ ] Clean install-from-GitHub smoke test completed from a temporary directory.
- [ ] Collaborator test script completed successfully.
- [ ] Feedback tracking issue created or updated.
- [ ] Known failure paths reviewed or documented.

### Tagging

```r
gert::git_branch_checkout("master")

gert::git_pull()

gert::git_status()

gert::git_tag_create(
  name = "v0.1.0-beta.X",
  message = "ContextLinkr collaborator beta X"
)

gert::git_push()

gert::git_push(refspec = "refs/tags/v0.1.0-beta.X")
```

## Post-tag smoke test

After pushing the tag, install the tagged version in a clean temporary location.

```r
smoke_dir <- file.path(tempdir(), "contextlinkr-beta-smoke-test")

if (dir.exists(smoke_dir)) {
  unlink(smoke_dir, recursive = TRUE, force = TRUE)
}

dir.create(smoke_dir, recursive = TRUE)
setwd(smoke_dir)

remotes::install_github(
  "CIOData/ContextLinkr@v0.1.0-beta.X",
  upgrade = "never",
  dependencies = TRUE,
  build_vignettes = FALSE
)

library(ContextLinkr)

packageVersion("ContextLinkr")

test_records <- data.frame(
  person_id = c("test_001", "test_002"),
  tract_geoid = c("21067003600", "21067004205")
)

test_added <- add_context(
  .data = test_records,
  tract_col = "tract_geoid",
  measures = "Total Population",
  use_cache = TRUE,
  refresh_cache = FALSE
)

nrow(test_added)
anyDuplicated(test_added$tract_geoid)
"Total Population" %in% names(test_added)

context_provenance(test_added)
```

