# Contributing to this project

This outlines how to propose a change to this project.

## Code Guidelines

*  New code should follow the tidyverse [style guide](https://style.tidyverse.org). 
    You can use the [styler](https://CRAN.R-project.org/package=styler) package to apply these styles, but please don't restyle code that has nothing to do with your PR.  

*  We use [roxygen2](https://cran.r-project.org/package=roxygen2), with [Markdown syntax](https://cran.r-project.org/web/packages/roxygen2/vignettes/rd-formatting.html), for function documentation.  

*  We use [testthat](https://cran.r-project.org/package=testthat) for unit tests on code in the `R` folder. We use `blueprintr` for data unit tests. For each code _and_ data change PR, it is **strongly** recommended to include unit tests for your work.

*  For security, **never** commit any environment files (e.g. .Renviron) or data files
   (with PII or not). Moreover, **never** make direct references to underlying data in your
   code; instead, refer to surrogate keys or patterns. If you need to identify a specific
   record to change something, use [anara](https://github.com/nyuglobalties/anara) instead.

## Fixing typos

You can fix typos, spelling mistakes, or grammatical errors in the documentation directly using the GitHub web interface, as long as the changes are made in the _source_ file.
This generally means you'll need to edit [roxygen2 comments](https://roxygen2.r-lib.org/articles/roxygen2.html) in an `.R`, not an `.Rd`, file.
You can find the `.R` file that generates the `.Rd` by reading the comment in the first line.

If you want to change metadata information, it is preferable that you construct a pull request and use a spreadsheet editor, like Excel or LibreOffice. 
Please ensure that quotes are not replaced (e.g. a single quote `'` remains a single quote) and that you use UTF-8 for your CSV export.

## Bigger changes

Code and metadata changes require having an affiliated issue filed to faciliate discussion about the proposed changes.
If you’ve found a bug, please file an issue that illustrates the bug. Provide steps that reproduce the bug. This will make writing unit tests quicker.

### Pull request process

- Follow the instructions in the README to set up the project, if you haven't done so yet.

- Create a Git branch for your pull request (PR). We use a "git flow" style of branch names. For new work (data changes, for example), use a `feature/` prefix. For a bugfix, use `fix/`. For data documentation changes _only_, use `docs/`. Then, use a hyphen-separated slug that identifies what your PR is about. For example, if your PR is about fixing labelling in a dataset, the branch should be called `fix/faulty-data-labelling`.

- Make your changes, commit to git, and then create a PR on Github. Normally, you will make a PR to `main`; however, if you are amending a former data release (e.g. a documentation update to bump `v1.0` to `v1.1`), make the PR to the corresponding release branch `v1.x`.

- If the PR addresses a task on Asana, add an "Asana header" to the PR body text. This looks like `/asana [url]` where `[url]` is the URL of the task on Asana. 

-  Follow the checklist in the PR template. When providing summary statistics, use something like: 

```r 
dataset |>
  haven::zap_labels() |>
  skimr::skim()
```
