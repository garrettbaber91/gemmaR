
# gemmaR

<!-- badges: start -->
<!-- badges: end -->

gemmaR is an R package to score positive and negative affect using Gemma 3 (12B) locally in R.

## Installation

``` r
devtools::install_github("garrettbaber91/gemmaR")

```

## Local Runtime

# one-time
ollama pull gemma3:12b



## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(gemmaR)
out <- score_gemma(dat, text)
```

