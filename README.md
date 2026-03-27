
# gemmaR

<!-- badges: start -->
<!-- badges: end -->

gemmaR is an R package to score affect from text using Gemma 3 (12B) running locally in R. It supports three scoring approaches: Positive/Negative Affect, the Circumplex Model (Valence/Arousal), and the full 20-item PANAS.

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

Scores **Valence** and **Arousal** based on the circumplex model of affect.

- Valence: −2 (strongly negative) … 0 (neutral) … 2 (strongly positive)
- Arousal: 1 (very low intensity) … 5 (very high intensity)

Returns two new columns: `gemma_valence` and `gemma_arousal`.

---

### `gemma_panas()`

Scores all **20 PANAS items** (Watson et al., 1988) on a 1–5 scale.

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
