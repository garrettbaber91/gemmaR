#' Score text with local Gemma and return Positive/Negative ratings
#'
#' This function sends each text entry to a locally running OpenAI-compatible
#' server (recommended: Ollama; also supports LM Studio) and parses a strict
#' "POS_INT,NEG_INT" response into two integer columns.
#'
#' @param data A data frame or tibble.
#' @param text_col Unquoted name of the column containing text.
#' @param provider Which local runtime to use: "auto", "ollama", or "lmstudio".
#' @param model Model name. Defaults to "gemma3:12b" for Ollama, or
#'   "google/gemma-3-12b" for LM Studio.
#' @param base_url Optional. Override the full /v1/chat/completions URL.
#' @param out_cols Names of output columns (length 2).
#' @param .progress Show a progress bar.
#' @param timeout_s Request timeout in seconds.
#' @param retries Number of retries on transient failures.
#'
#' @return `data` with two new integer columns: Positive and Negative ratings.
#' @export
score_gemma <- function(
    data,
    text_col,
    provider = c("ollama", "auto", "lmstudio"),
    model = NULL,
    base_url = NULL,
    out_cols = c("gemma_pos", "gemma_neg"),
    .progress = TRUE,
    timeout_s = 120,
    retries = 2
) {
  provider <- match.arg(provider)
  text_col <- rlang::ensym(text_col)

  cfg <- .resolve_provider(provider = provider, model = model, base_url = base_url)

  rater <- .make_rater(
    sys_prompt = .gemma_sys_prompt,
    base_url   = cfg$base_url,
    model      = cfg$model,
    timeout_s  = timeout_s,
    retries    = retries
  )

  data |>
    dplyr::mutate(
      .gemma_ratings = purrr::map(dplyr::pull(data, !!text_col), rater, .progress = .progress)
    ) |>
    tidyr::unnest_wider(.gemma_ratings, names_sep = "_") |>
    dplyr::rename(
      !!out_cols[1] := .gemma_ratings_1,
      !!out_cols[2] := .gemma_ratings_2
    )
}
