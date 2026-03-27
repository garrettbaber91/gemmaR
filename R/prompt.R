#' @keywords internal
.gemma_sys_prompt <- paste0(
  "You will be provided with text reports, and your task is to rate the degree ",
  "to which the person experienced positive emotions on a scale from 1 to 5 ",
  "where 1 represents ‘none or very little positive emotion’ and 5 represents ",
  "‘very intense positive emotion’. The second rating you will provide is your ",
  "estimation of degree to which the person experienced negative emotions on ",
  "the same 5-point scale, with 1 representing 'none or very little negative ",
  "emotion' and 5 represents 'very intense negative emotion'. Ignore words that ",
  "do not appear to be related to the described experience. Always respond with ",
  "a single integer per column as your answer. Never add explanations or commentary ",
  "in parentheses. Provide your output in two columns where the first column always ",
  "corresponds with your rating of Positive Emotion and the second column always ",
  "corresponds with Negative Emotion, separated by commas, formatted like a CSV file."
)


#' @keywords internal
.gemma_panas_items <- c(
  "Interested", "Distressed", "Excited", "Upset", "Strong",
  "Guilty", "Scared", "Hostile", "Enthusiastic", "Proud",
  "Irritable", "Alert", "Ashamed", "Inspired", "Nervous",
  "Determined", "Attentive", "Jittery", "Active", "Afraid"
)

#' @keywords internal
.gemma_sys_prompt_panas <- paste0(
  "You will be provided with text reports, and your task is to rate the degree ",
  "to which the person experienced each of the following emotions or feelings. ",
  "Use a scale from 1 to 5 where 1 represents 'very slightly or not at all', ",
  "2 represents 'a little', 3 represents 'moderately', 4 represents 'quite a bit', ",
  "and 5 represents 'extremely'. Ignore words that do not appear to be related to ",
  "the described experience. Rate each emotion independently on its own merits ",
  "without letting your rating of one emotion influence your rating of any other ",
  "emotion. Always respond with a single integer per column as your answer. Never ",
  "add explanations or commentary in parentheses. Provide your output in 20 columns ",
  "corresponding to each PANAS item in order, separated by commas, formatted like a ",
  "CSV file with the following header: ",
  "Interested,Distressed,Excited,Upset,Strong,Guilty,Scared,Hostile,Enthusiastic,",
  "Proud,Irritable,Alert,Ashamed,Inspired,Nervous,Determined,Attentive,Jittery,",
  "Active,Afraid {/no_think}"
)

#' @keywords internal
.gemma_sys_prompt_valence_arousal <- paste0(
  "You will be provided with a text report describing a person's experience. ",
  "Your task is to rate TWO dimensions of affect from the described experience.\n\n",
  "1) VALENCE on an integer scale from -2 to 2:\n",
  "  -2 = strongly negative (e.g., fear, sadness, anger, disgust)\n",
  "  -1 = mildly negative\n",
  "   0 = neutral/mixed/unclear (no clear positive or negative emotion)\n",
  "   1 = mildly positive\n",
  "   2 = strongly positive (e.g., joy, relief, love, excitement)\n\n",
  "2) AROUSAL on an integer scale from 1 to 5:\n",
  "   1 = none/very low intensity (flat, calm, dull)\n",
  "   3 = moderate intensity\n",
  "   5 = very high intensity (high activation: very excited, panicked, enraged)\n\n",
  "Rate the person's emotions, not the topic quality. Use the overall experience. ",
  "If the report is mixed, choose the closest overall valence; if unclear, use 0.\n\n",
  "Output format rules (MANDATORY):\n",
  "- Respond with EXACTLY two integers separated by a comma, like: -1,4\n",
  "- No words, no labels, no spaces, no extra punctuation, no commentary."
)
