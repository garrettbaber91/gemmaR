.resolve_provider <- function(provider, model, base_url) {
  # Defaults
  ollama_chat   <- "http://127.0.0.1:11434/v1/chat/completions"
  lmstudio_chat <- "http://127.0.0.1:1234/v1/chat/completions"

  if (provider == "auto") {
    if (.ping_ollama()) {
      provider <- "ollama"
    } else if (.ping_openai_models("http://127.0.0.1:1234")) {
      provider <- "lmstudio"
    } else {
      cli::cli_abort(c(
        "No local LLM server detected.",
        "i" = "Start Ollama (recommended) or LM Studio, then try again.",
        "i" = "Expected endpoints:",
        " " = "- Ollama: {ollama_chat}",
        " " = "- LM Studio: {lmstudio_chat}"
      ))
    }
  }

  if (provider == "ollama") {
    list(
      base_url = rlang::`%||%`(base_url, ollama_chat),
      model    = rlang::`%||%`(model, "gemma3:12b")
    )
  } else {
    list(
      base_url = rlang::`%||%`(base_url, lmstudio_chat),
      model    = rlang::`%||%`(model, "google/gemma-3-12b")
    )
  }
}

.prompt_spec <- function(prompt_type) {
  prompt_type <- match.arg(prompt_type, c("pa_na", "valence_arousal", "panas"))

  if (prompt_type == "pa_na") {
    list(
      sys_prompt  = .gemma_sys_prompt,
      reminder    = "Remember: respond ONLY as 'POS_INT,NEG_INT' (e.g., '3,1').",
      n_scores    = 2L,
      max_tokens  = 10L
    )
  } else if (prompt_type == "valence_arousal") {
    list(
      sys_prompt  = .gemma_sys_prompt_valence_arousal,
      reminder    = "Remember: respond ONLY as 'VALENCE_INT,AROUSAL_INT' (e.g., '-1,4').",
      n_scores    = 2L,
      max_tokens  = 10L
    )
  } else {
    list(
      sys_prompt  = .gemma_sys_prompt_panas,
      reminder    = paste0(
        "Remember: respond ONLY as 20 integers separated by commas in this exact order: ",
        "Interested,Distressed,Excited,Upset,Strong,Guilty,Scared,Hostile,Enthusiastic,",
        "Proud,Irritable,Alert,Ashamed,Inspired,Nervous,Determined,Attentive,Jittery,",
        "Active,Afraid (e.g., '3,1,4,2,3,1,1,1,4,2,1,3,1,3,2,4,3,1,3,1')."
      ),
      n_scores    = 20L,
      max_tokens  = 80L
    )
  }
}

.ping_ollama <- function() {
  ok <- FALSE
  try({
    httr2::request("http://127.0.0.1:11434/api/tags") |>
      httr2::req_timeout(2) |>
      httr2::req_perform()
    ok <- TRUE
  }, silent = TRUE)
  ok
}

.ping_openai_models <- function(base) {
  ok <- FALSE
  url <- paste0(base, "/v1/models")
  try({
    httr2::request(url) |>
      httr2::req_timeout(2) |>
      httr2::req_perform()
    ok <- TRUE
  }, silent = TRUE)
  ok
}

.make_rater <- function(sys_prompt, reminder, prompt_type, n_scores, max_tokens, base_url, model, timeout_s, retries) {
  force(sys_prompt)
  force(reminder)
  force(prompt_type)
  force(n_scores)
  force(max_tokens)

  na_vec <- rep(NA_integer_, n_scores)

  function(text_report) {
    if (is.na(text_report) || stringr::str_trim(text_report) == "") {
      return(as.list(na_vec))
    }

    body <- list(
      model = model,
      messages = list(
        list(role = "system", content = sys_prompt),
        list(
          role = "user",
          content = paste0(
            "Here is the text report:\n\n",
            text_report,
            "\n\n",
            reminder
          )
        )
      ),
      temperature = 0,
      max_tokens  = max_tokens
    )

    last_err <- NULL
    for (i in 0:retries) {
      resp <- try({
        httr2::request(base_url) |>
          httr2::req_body_json(body) |>
          httr2::req_timeout(timeout_s) |>
          httr2::req_perform()
      }, silent = TRUE)

      if (!inherits(resp, "try-error")) {
        parsed <- httr2::resp_body_json(resp)
        raw <- rlang::`%||%`(parsed$choices[[1]]$message$content, "")
        return(.parse_scores(raw, prompt_type = prompt_type, n_scores = n_scores))
      }

      last_err <- resp
      Sys.sleep(min(2^i, 4))
    }

    warning("Request failed after retries: ", as.character(last_err))
    as.list(na_vec)
  }
}

.parse_scores <- function(x, prompt_type = c("pa_na", "valence_arousal", "panas"), n_scores) {
  prompt_type <- match.arg(prompt_type)

  na_vec <- as.list(rep(NA_integer_, n_scores))

  # Extract all integers (optionally negative), handles extra labels like "Valence: -1, Arousal: 4"
  m <- stringr::str_extract_all(x, "-?\\d+")[[1]]

  if (length(m) < n_scores) {
    warning("Unexpected model output: '", x, "'. Returning NAs.")
    return(na_vec)
  }

  vals <- suppressWarnings(as.integer(m[seq_len(n_scores)]))

  # Range validation per prompt type
  if (prompt_type == "pa_na") {
    vals <- ifelse(!is.na(vals) & (vals < 1 | vals > 5), NA_integer_, vals)
  } else if (prompt_type == "valence_arousal") {
    vals[1] <- ifelse(!is.na(vals[1]) & (vals[1] < -2 | vals[1] > 2), NA_integer_, vals[1])
    vals[2] <- ifelse(!is.na(vals[2]) & (vals[2] < 1  | vals[2] > 5), NA_integer_, vals[2])
  } else {
    # panas: all 20 items on 1-5
    vals <- ifelse(!is.na(vals) & (vals < 1 | vals > 5), NA_integer_, vals)
  }

  if (anyNA(vals)) {
    warning("Could not parse valid ratings from model output: '", x, "'. Returning NA(s).")
  }

  as.list(vals)
}
