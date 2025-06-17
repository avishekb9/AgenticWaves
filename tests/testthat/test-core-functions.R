test_that("get_sample_data works correctly", {
  # Test basic functionality
  data <- get_sample_data("global_markets", n_assets = 5, n_periods = 100)
  
  expect_true(is.matrix(data))
  expect_equal(ncol(data), 5)
  expect_equal(nrow(data), 100)
  expect_true(all(!is.na(data)))
  
  # Test different data types
  crypto_data <- get_sample_data("crypto", n_assets = 3, n_periods = 50)
  expect_equal(ncol(crypto_data), 3)
  expect_equal(nrow(crypto_data), 50)
  
  # Test column names
  expect_true(all(colnames(data) != ""))
  expect_false(any(duplicated(colnames(data))))
})

test_that("process_financial_data handles different inputs", {
  # Create test data
  test_data <- matrix(rnorm(100), 20, 5)
  test_data[1, 1] <- NA  # Add missing value
  test_data[2, 2] <- 10  # Add outlier
  
  # Test basic processing
  processed <- process_financial_data(test_data, remove_outliers = FALSE, standardize = FALSE)
  expect_true(is.matrix(processed))
  expect_equal(ncol(processed), 5)
  
  # Test outlier removal
  processed_no_outliers <- process_financial_data(test_data, remove_outliers = TRUE)
  expect_true(nrow(processed_no_outliers) <= nrow(test_data))
  
  # Test standardization
  processed_std <- process_financial_data(test_data, standardize = TRUE, remove_outliers = FALSE)
  # Should have mean close to 0 and sd close to 1 (after removing NA)
  means <- apply(processed_std, 2, mean, na.rm = TRUE)
  expect_true(all(abs(means) < 0.1))
})

test_that("detect_asset_classes works", {
  # Create test data with known patterns
  test_data <- matrix(rnorm(500), 100, 5)
  colnames(test_data) <- c("BTC", "Gold", "SPX", "Crude", "Bond")
  
  classes <- detect_asset_classes(test_data)
  
  expect_equal(length(classes), 5)
  expect_true(all(names(classes) == colnames(test_data)))
  expect_true(all(classes %in% c("equity", "crypto", "commodity", "bond")))
  
  # BTC should be detected as crypto
  expect_equal(as.character(classes["BTC"]), "crypto")
})

test_that("validate_data_quality provides comprehensive assessment", {
  # Create test data
  test_data <- matrix(rnorm(1000), 100, 10)
  test_data[1:5, 1] <- NA  # Add missing data
  
  quality <- validate_data_quality(test_data)
  
  expect_true(is.list(quality))
  expect_true("quality_score" %in% names(quality))
  expect_true("quality_level" %in% names(quality))
  expect_true("missing_percentage" %in% names(quality))
  expect_true("recommendations" %in% names(quality))
  
  expect_true(quality$quality_score >= 0 && quality$quality_score <= 100)
  expect_true(quality$missing_percentage >= 0 && quality$missing_percentage <= 100)
  expect_equal(quality$n_assets, 10)
  expect_equal(quality$n_observations, 100)
})

test_that("calculate_gini_coefficient works correctly", {
  # Test perfect equality
  equal_wealth <- rep(100, 10)
  gini_equal <- calculate_gini_coefficient(equal_wealth)
  expect_true(abs(gini_equal) < 0.01)  # Should be close to 0
  
  # Test perfect inequality
  unequal_wealth <- c(1000, rep(0, 9))
  gini_unequal <- calculate_gini_coefficient(unequal_wealth)
  expect_true(gini_unequal > 0.8)  # Should be close to 1
  
  # Test with NA values
  wealth_with_na <- c(100, 200, 300, NA, 400)
  gini_na <- calculate_gini_coefficient(wealth_with_na)
  expect_false(is.na(gini_na))
  
  # Test empty vector
  gini_empty <- calculate_gini_coefficient(numeric(0))
  expect_true(is.na(gini_empty))
})