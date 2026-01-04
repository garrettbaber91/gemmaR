
# gemmaR

<!-- badges: start -->
<!-- badges: end -->

gemmaR is an R package to score positive and negative affect from text using Gemma 3 (12B) locally in R. 

Affect scores ('gemma_pos' and 'gemma_neg') are rated on 5-pt Likert scales (1–5), where 1 represents none or very little  emotion and 5 represents very intense positive emotion

## Installation

``` r
devtools::install_github("garrettbaber91/gemmaR")

```

## Local Runtime (Required)

gemmaR runs fully locally using a lightweight local inference runtime called Ollama.
Your data never leaves your machine.

Ollama runs in the background and automatically starts when needed — you do not need to manually start a server each time you use gemmaR.


## One-Time Setup: Install Ollama

macOS / Windows / Linux

1.	Download and install Ollama from: https://ollama.com
2.	Open the Ollama application once after installation
(this starts the background service).

You only need to do this one time.

## One-Time Setup: Download the Gemma Model

After installing Ollama, download the Gemma 3 (12B) model once.

Open Terminal (not R) and run:

``` bash
ollama pull gemma3:12b
```


## Troubleshooting

If you see an error like:

> No local LLM server detected

Make sure that:

•	Ollama is installed

•	You have opened Ollama at least once

•	The model was downloaded with ollama pull gemma3:12b


Then restart R and try again.

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(gemmaR)
library(tibble)

data <- tibble(
  SubjectID = c(1, 2, 3),
  text = c(
    "I felt calm and happy, floating on a cloud",
    "A man chased me with a knife and nearly cut me!",
    "I couldn't believe she could betray me like that. But I forgave her and eventually felt peace."
  )
)

out <- score_gemma(data, text) # text is the name of the column containing text to be analyzed

print(out)
```

``` r
# A tibble: 3 × 4
  SubjectID text                                                                                           gemma_pos gemma_neg
      <dbl> <chr>                                                                                              <int>     <int>
1         1 I felt calm and happy, floating on a cloud                                                             5         1
2         2 A man chased me with a knife and nearly cut me!                                                        1         5
3         3 I couldn't believe she could betray me like that. But I forgave her and eventually felt peace.         2         4

