## Summary

Briefly describe what this pull request changes.

## Type of change

- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Test update
- [ ] Refactor
- [ ] Release/versioning change
- [ ] Other:

## ContextLinkr workflow area

Which package area does this affect?

- [ ] Geocoding
- [ ] Census tract identification
- [ ] End-to-end linkage with `link_context()`
- [ ] Cancer InFocus context retrieval
- [ ] Context joining / summaries
- [ ] Documentation / README / vignette
- [ ] GitHub Actions / repository infrastructure
- [ ] Other:

## Testing completed

Please check all that apply.

- [ ] `devtools::document()`
- [ ] `devtools::test()`
- [ ] `devtools::check()`
- [ ] Live Cancer InFocus integration tests, if relevant

If live integration tests were run, note the command and result:

```r
Sys.setenv(CONTEXTLINKR_RUN_CIF_INTEGRATION = "true")

devtools::test()

Sys.unsetenv("CONTEXTLINKR_RUN_CIF_INTEGRATION")
```

## Privacy / data-flow review

- [ ] This change does not alter data flow.
- [ ] This change affects address geocoding or external-service behavior.
- [ ] This change affects Cancer InFocus context retrieval.
- [ ] This change affects caching or local file storage.

Briefly describe any data-flow implications:

## Documentation updated

- [ ] Function documentation updated
- [ ] README updated
- [ ] Vignette updated
- [ ] NEWS updated
- [ ] Not applicable

## Notes for reviewer

Add anything the reviewer should pay special attention to.
