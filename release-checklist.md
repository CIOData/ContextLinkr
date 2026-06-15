# ContextLinkr release checklist

Use this checklist before tagging an internal alpha, beta, or collaborator-facing
release.

## 1. Confirm development status

- [ ] Confirm all intended changes for this release are committed or staged.
- [ ] Review open issues and pull requests.
- [ ] Confirm whether this is an internal alpha, beta, or stable release.
- [ ] Confirm whether the release should include live Cancer InFocus integration validation.

## 2. Review package metadata

- [ ] Confirm `DESCRIPTION` version is correct.
- [ ] Confirm `DESCRIPTION` description reflects current functionality.
- [ ] Confirm package dependencies are still needed.
- [ ] Confirm no unused vignette dependencies are present.
- [ ] Confirm `NEWS.md` has an entry for the release.

## 3. Review exported functions

Check exported functions:

```r
devtools::load_all()

getNamespaceExports("ContextLinkr")
```

Confirm only user-facing functions are exported.

Internal helpers should not be exported, including functions such as:

```r
c(
  "cif_context_url",
  "read_cif_context_data",
  "read_context_parquet",
  "context_cache_path",
  "is_remote_path",
  "validate_context_request",
  "validate_context_geography",
  "validate_context_format",
  "widen_context_data"
)
```

## 4. Run local package checks

```r
devtools::document()
devtools::test()
devtools::check()
```

Confirm:

- [ ] 0 errors
- [ ] 0 warnings
- [ ] only expected notes, if any

## 5. Run live Cancer InFocus integration tests

Run this when the release includes or depends on hosted Cancer InFocus context
data.

```r
Sys.setenv(CONTEXTLINKR_RUN_CIF_INTEGRATION = "true")

devtools::test()

Sys.unsetenv("CONTEXTLINKR_RUN_CIF_INTEGRATION")
```

Confirm:

- [ ] live `available_context_measures()` tests pass
- [ ] live `search_context_measures()` tests pass
- [ ] live `get_context()` tests pass
- [ ] live `add_context()` tests pass
- [ ] live `link_context(include_context = TRUE)` tests pass

## 6. Check documentation artifacts

- [ ] Rebuild README.

```r
devtools::build_readme()
```

- [ ] Confirm vignette builds through `devtools::check()`.
- [ ] Review README examples.
- [ ] Review vignette examples.
- [ ] Confirm privacy/data-flow language is still accurate.
- [ ] Confirm collaborator testing guide is current.

## 7. Review GitHub infrastructure

- [ ] Confirm GitHub Actions checks pass.
- [ ] Confirm issue templates are current.
- [ ] Confirm pull request template is current.
- [ ] Confirm collaborator testing guide links/instructions are correct.

## 8. Commit release preparation changes

```r
gert::git_status()

gert::git_add(".")

gert::git_commit("Prepare release")
```

## 9. Tag the release

Use a tag name appropriate to the release stage.

Examples:

```r
gert::git_tag_create(
  name = "v0.1.0-alpha",
  message = "Internal alpha release"
)
```

```r
gert::git_tag_create(
  name = "v0.2.0-beta",
  message = "Collaborator beta release"
)
```

Confirm the tag exists:

```r
gert::git_tag_list()
```

## 10. Push commit and tag

```r
gert::git_push()

gert::git_push(tags = TRUE)
```

## 11. Start the next development version

Update `DESCRIPTION` to the next development version, such as:

```text
Version: 0.1.0.9000
```

Then commit and push:

```r
gert::git_add("DESCRIPTION")

gert::git_commit("Bump development version")

gert::git_push()
```

## 12. Optional collaborator notification

When sending the release to collaborators, include:

- GitHub repository link;
- release tag or commit SHA;
- installation command;
- collaborator testing guide link;
- request to submit feedback using the GitHub issue templates.
