test_that("parse_two_ints parses clean outputs", {
  expect_equal(gemmaR:::.parse_two_ints("3,1"), c(3L, 1L))
  expect_equal(gemmaR:::.parse_two_ints(" 5 , 2 "), c(5L, 2L))
})

test_that("parse_two_ints returns NA on bad output", {
  x <- gemmaR:::.parse_two_ints("hello")
  expect_true(all(is.na(x)))
})
