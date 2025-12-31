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
      base_url = base_url %||% ollama_chat,
      model    = model %||% "gemma3:12b"
    )
  } else {
    list(
      base_url = base_url %||% lmstudio_chat,
      model    = model %||% "google/gemma-3-12b"
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

.make_rater <- function(sys_prompt, base_url, model, timeout_s, retries) {
  force(sys_prompt)

  function(text_report) {
    if (is.na(text_report) || stringr::str_trim(text_report) == "") {
      return(c(NA_integer_, NA_integer_))
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
            "\n\nRemember: respond ONLY as 'POS_INT,NEG_INT' (e.g., '3,1')."
          )
        )
      ),
      temperature = 0,
      max_tokens = 10
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
        raw <- parsed$choices[[1]]$message$content %||% ""
        return(.parse_two_ints(raw))
      }

      last_err <- resp
      Sys.sleep(min(2^i, 4))
    }

    warning("Request failed after retries: ", as.character(last_err))
    c(NA_integer_, NA_integer_)
  }
}

.parse_two_ints <- function(x) {
  parts <- strsplit(x, ",")[[1]] |> trimws()

  if (length(parts) != 2) {
    warning("Unexpected model output: '", x, "'. Returning NA, NA.")
    return(c(NA_integer_, NA_integer_))
  }

  pos <- suppressWarnings(as.integer(parts[1]))
  neg <- suppressWarnings(as.integer(parts[2]))

  if (is.na(pos) || is.na(neg)) {
    warning("Could not parse integers from model output: '", x, "'.")
  }

  c(pos, neg)
}
