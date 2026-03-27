
# gemmaR

<!-- badges: start -->
<!-- badges: end -->

gemmaR is an R package to score affect from text using Gemma 3 (12B) running locally in R. It supports three scoring approaches: Positive/Negative Affect, the Circumplex Model of Affect (Russell, 1980), and the full 20-item PANAS (Watson & Tellegen, 1988).

## Installation

``` r
devtools::install_github("garrettbaber91/gemmaR")
```

## Local Runtime

Gemma 3 runs locally via [Ollama](https://ollama.com). Pull the model once before use:

``` bash
ollama pull gemma3:12b
```

LM Studio is also supported — see the `provider` argument in each function.

## Example

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

# Positive / Negative Affect
pa_na_output <- gemma_pa_na(test_df, text)
print(pa_na_output)

# Circumplex Model (Valence / Arousal)
circumplex_output <- gemma_circumplex(test_df, text)
print(circumplex_output)

# Full 20-item PANAS
panas_output <- gemma_panas(test_df, text)
print(panas_output)
```

## Functions

### `gemma_pa_na()`

Scores **Positive Affect** and **Negative Affect** on a 1–5 scale.

- 1 = none or very little
- 5 = very intense

Returns two new columns: `gemma_PA` and `gemma_NA`.

``` r
# A tibble: 3 × 4
  SubjectID text                                                                                           gemma_PA gemma_NA
      <dbl> <chr>                                                                                             <int>    <int>
1         1 I felt calm and happy, floating on a cloud                                                            5        1
2         2 A man chased me with a knife and nearly cut me!                                                       1        5
3         3 I couldn't believe she could betray me like that. But I forgave her and eventually felt peace.        2        4
```

---

### `gemma_circumplex()`

Scores **Valence** and **Arousal** based on the Circumplex Model of Affect (Russell, 1980).

- Valence: −2 (strongly negative) … 0 (neutral) … 2 (strongly positive)
- Arousal: 1 (very low intensity) … 5 (very high intensity)

Returns two new columns: `gemma_valence` and `gemma_arousal`.

---

### `gemma_panas()`

Scores all **20 PANAS items** (Watson & Tellegen, 1988) on a 1–5 scale.

- 1 = very slightly or not at all
- 5 = extremely

Returns 20 new columns named `gemma_Interested`, `gemma_Distressed`, `gemma_Excited`, etc., in standard PANAS order.

---

## Customization

All three functions share the same optional arguments:

| Argument | Default | Description |
|---|---|---|
| `provider` | `"ollama"` | Local runtime: `"ollama"`, `"lmstudio"`, or `"auto"` |
| `model` | `"gemma3:12b"` | Model name passed to the server |
| `base_url` | `NULL` | Override the `/v1/chat/completions` endpoint |
| `out_cols` | varies | Custom names for the output columns |
| `.progress` | `TRUE` | Show a progress bar |
| `timeout_s` | `120` | Request timeout in seconds |
| `retries` | `2` | Retries on transient failures |

## Citation

If you use gemmaR in your research, please cite it as:

Baber, G. (2025). *gemmaR: Score affect from text using local Gemma 3* (R package version 0.1.0). https://github.com/garrettbaber91/gemmaR

## References

Russell, J. A. (1980). A circumplex model of affect. *Journal of Personality and Social Psychology, 39*(6), 1161–1178. https://doi.org/10.1037/h0077714

Watson, D., Clark, L. A., & Tellegen, A. (1988). Development and validation of brief measures of positive and negative affect: The PANAS scales. *Journal of Personality and Social Psychology, 54*(6), 1063–1070. https://doi.org/10.1037/0022-3514.54.6.1063
