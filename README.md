
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
library(tibble)

test_df <- tibble(
  SubjectID = c(1, 2, 3),
  text = c(
    "I felt calm and happy, floating on a cloud",
    "A man chased me with a knife and nearly cut me!",
    "I couldn't believe she could betray me like that. But I forgave her and eventually felt peace."
  )
)

out <- score_gemma(
  test_df,
  text,
  provider = "ollama",
  model = "gemma3:12b",
  base_url = "http://127.0.0.1:11434/v1/chat/completions"
)

print(out)
```

``` r
# A tibble: 3 × 4
  SubjectID text                                                                                           gemma_pos gemma_neg
      <dbl> <chr>                                                                                              <int>     <int>
1         1 I felt calm and happy, floating on a cloud                                                             5         1
2         2 A man chased me with a knife and nearly cut me!                                                        1         5
3         3 I couldn't believe she could betray me like that. But I forgave her and eventually felt peace.         2         4

