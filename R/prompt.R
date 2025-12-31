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
