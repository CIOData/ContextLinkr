---
name: Bug report
about: Report a reproducible ContextLinkr problem
title: "[Bug]: "
labels: bug
assignees: ""
---

## Describe the bug

What happened?

## Expected behavior

What did you expect to happen?

## Reproducible example

Please include the smallest code example that reproduces the issue. Do not include real patient, 
participant, address-level, or identifiable data.

```r
# Minimal reproducible example
```

## Error message

Paste the full error message and traceback if available.

```r
# Error text
rlang::last_trace()
```

## Session information

```r
packageVersion("ContextLinkr")
R.version.string
Sys.info()[c("sysname", "release", "machine")]
```

## ContextLinkr diagnostics

If the issue involves Cancer InFocus context retrieval, cache behavior, or source metadata, please run:

```r
context_cache_info()
context_data_sources()
```

## Additional context

Add any other details that may help diagnose the issue.
