#' @keywords internal
.score_gemma <- function(
    data,
    text_col,
    prompt_type,
    provider    = c("ollama", "auto", "lmstudio"),
    model       = NULL,
    base_url    = NULL,
    out_cols    = NULL,
    .progress   = TRUE,
    timeout_s   = 120,
    retries     = 2
) {
  provider <- match.arg(provider)
  text_col <- rlang::ensym(text_col)

  if (is.null(out_cols)) {
    out_cols <- switch(prompt_type,
      pa_na           = c("gemma_PA", "gemma_NA"),
      valence_arousal = c("gemma_valence", "gemma_arousal"),
      panas           = paste0("gemma_", .gemma_panas_items)
    )
  }

  cfg <- .resolve_provider(provider = provider, model = model, base_url = base_url)
  ps  <- .prompt_spec(prompt_type)

  if (length(out_cols) != ps$n_scores) {
    cli::cli_abort(c(
      "{.arg out_cols} must have {ps$n_scores} element{?s} for {.val {prompt_type}}.",
      "i" = "You supplied {length(out_cols)} name{?s}."
    ))
  }

  rater <- .make_rater(
    sys_prompt  = ps$sys_prompt,
    reminder    = ps$reminder,
    prompt_type = prompt_type,
    n_scores    = ps$n_scores,
    max_tokens  = ps$max_tokens,
    base_url    = cfg$base_url,
    model       = cfg$model,
    timeout_s   = timeout_s,
    retries     = retries
  )

  tmp_names  <- paste0(".gemma_ratings_", seq_len(ps$n_scores))
  rename_map <- rlang::set_names(tmp_names, out_cols)

  data |>
    dplyr::mutate(
      .gemma_ratings = purrr::map(dplyr::pull(data, !!text_col), rater, .progress = .progress)
    ) |>
    tidyr::unnest_wider(.gemma_ratings, names_sep = "_") |>
    dplyr::rename(!!!rename_map)
}

#' Score Positive and Negative Affect
#'
#' Rates each text entry on two dimensions — Positive Affect and Negative
#' Affect — using a 1–5 scale, where 1 = "none or very little" and
#' 5 = "very intense".
#'
#' @param data A data frame or tibble.
#' @param text_col Unquoted name of the column containing text.
#' @param provider Which local runtime to use: `"ollama"` (default), `"auto"`,
#'   or `"lmstudio"`.
#' @param model Model name. Defaults to `"gemma3:12b"` for Ollama or
#'   `"google/gemma-3-12b"` for LM Studio.
#' @param base_url Optional. Override the full `/v1/chat/completions` URL.
#' @param out_cols Names for the two output columns.
#'   Defaults to `c("gemma_PA", "gemma_NA")`.
#' @param .progress Show a progress bar.
#' @param timeout_s Request timeout in seconds.
#' @param retries Number of retries on transient failures.
#'
#' @return `data` with two new integer columns: positive affect and negative affect.
#' @export
gemma_pa_na <- function(
    data,
    text_col,
    provider  = c("ollama", "auto", "lmstudio"),
    model     = NULL,
    base_url  = NULL,
    out_cols  = c("gemma_PA", "gemma_NA"),
    .progress = TRUE,
    timeout_s = 120,
    retries   = 2
) {
  .score_gemma(
    data        = data,
    text_col    = {{ text_col }},
    prompt_type = "pa_na",
    provider    = provider,
    model       = model,
    base_url    = base_url,
    out_cols    = out_cols,
    .progress   = .progress,
    timeout_s   = timeout_s,
    retries     = retries
  )
}

#' Score Valence and Arousal (Circumplex Model)
#'
#' Rates each text entry on two circumplex dimensions: Valence (−2 to 2) and
#' Arousal (1 to 5).
#'
#' @param data A data frame or tibble.
#' @param text_col Unquoted name of the column containing text.
#' @param provider Which local runtime to use: `"ollama"` (default), `"auto"`,
#'   or `"lmstudio"`.
#' @param model Model name. Defaults to `"gemma3:12b"` for Ollama or
#'   `"google/gemma-3-12b"` for LM Studio.
#' @param base_url Optional. Override the full `/v1/chat/completions` URL.
#' @param out_cols Names for the two output columns.
#'   Defaults to `c("gemma_valence", "gemma_arousal")`.
#' @param .progress Show a progress bar.
#' @param timeout_s Request timeout in seconds.
#' @param retries Number of retries on transient failures.
#'
#' @return `data` with two new integer columns: valence and arousal.
#' @export
gemma_circumplex <- function(
    data,
    text_col,
    provider  = c("ollama", "auto", "lmstudio"),
    model     = NULL,
    base_url  = NULL,
    out_cols  = c("gemma_valence", "gemma_arousal"),
    .progress = TRUE,
    timeout_s = 120,
    retries   = 2
) {
  .score_gemma(
    data        = data,
    text_col    = {{ text_col }},
    prompt_type = "valence_arousal",
    provider    = provider,
    model       = model,
    base_url    = base_url,
    out_cols    = out_cols,
    .progress   = .progress,
    timeout_s   = timeout_s,
    retries     = retries
  )
}

#' Score the 20-item PANAS
#'
#' Rates each text entry on all 20 PANAS items (Watson et al., 1988) using a
#' 1–5 scale, where 1 = "very slightly or not at all" and 5 = "extremely".
#' Returns one column per item in standard PANAS order.
#'
#' @param data A data frame or tibble.
#' @param text_col Unquoted name of the column containing text.
#' @param provider Which local runtime to use: `"ollama"` (default), `"auto"`,
#'   or `"lmstudio"`.
#' @param model Model name. Defaults to `"gemma3:12b"` for Ollama or
#'   `"google/gemma-3-12b"` for LM Studio.
#' @param base_url Optional. Override the full `/v1/chat/completions` URL.
#' @param out_cols Names for the 20 output columns. Defaults to
#'   `paste0("gemma_", c("Interested", "Distressed", ...))`.
#' @param .progress Show a progress bar.
#' @param timeout_s Request timeout in seconds.
#' @param retries Number of retries on transient failures.
#'
#' @return `data` with 20 new integer columns, one per PANAS item.
#' @export
gemma_panas <- function(
    data,
    text_col,
    provider  = c("ollama", "auto", "lmstudio"),
    model     = NULL,
    base_url  = NULL,
    out_cols  = paste0("gemma_", .gemma_panas_items),
    .progress = TRUE,
    timeout_s = 120,
    retries   = 2
) {
  .score_gemma(
    data        = data,
    text_col    = {{ text_col }},
    prompt_type = "panas",
    provider    = provider,
    model       = model,
    base_url    = base_url,
    out_cols    = out_cols,
    .progress   = .progress,
    timeout_s   = timeout_s,
    retries     = retries
  )
}
