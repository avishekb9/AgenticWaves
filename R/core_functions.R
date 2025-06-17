#' Get Sample Data
#'
#' @description Retrieve sample financial data for analysis
#'
#' @param data_type Character string specifying data type: "global_markets", "crypto", "commodities"
#' @param n_assets Integer number of assets to include (default: 10)
#' @param n_periods Integer number of time periods (default: 1000)
#'
#' @return Matrix of financial returns data
#' @export
#'
#' @examples
#' # Generate sample global markets data
#' data <- get_sample_data("global_markets", n_assets = 5, n_periods = 100)
#' head(data)
#' 
#' # Generate crypto data
#' crypto_data <- get_sample_data("crypto", n_assets = 3, n_periods = 50)
#' 
#' # Generate commodities data
#' commodity_data <- get_sample_data("commodities", n_assets = 4)
get_sample_data <- function(data_type = "global_markets", n_assets = 10, n_periods = 1000) {
  
  # Asset names by type
  asset_names <- switch(data_type,
    "global_markets" = c("SPX", "EuroStoxx", "Nikkei", "FTSE", "DAX", "CAC", "IBEX", "SMI", "TSX", "ASX"),
    "crypto" = c("BTC", "ETH", "ADA", "DOT", "LINK", "UNI", "AAVE", "COMP", "YFI", "SUSHI"),
    "commodities" = c("Gold", "Silver", "Crude", "Copper", "Wheat", "Corn", "Soybeans", "Cotton", "Sugar", "Coffee"),
    c("Asset1", "Asset2", "Asset3", "Asset4", "Asset5", "Asset6", "Asset7", "Asset8", "Asset9", "Asset10")
  )
  
  # Generate correlated returns
  set.seed(42)  # For reproducibility
  
  # Create correlation structure
  rho_base <- switch(data_type,
    "global_markets" = 0.3,
    "crypto" = 0.4,
    "commodities" = 0.2,
    0.25
  )
  
  # Generate correlation matrix
  correlation_matrix <- matrix(rho_base, n_assets, n_assets)
  diag(correlation_matrix) <- 1
  
  # Add some random variation
  for(i in 1:n_assets) {
    for(j in 1:n_assets) {
      if(i != j) {
        correlation_matrix[i,j] <- correlation_matrix[i,j] + runif(1, -0.15, 0.15)
      }
    }
  }
  
  # Ensure positive definite
  eigenvals <- eigen(correlation_matrix, symmetric = TRUE)$values
  if(any(Re(eigenvals) <= 0)) {
    min_eigenval <- min(Re(eigenvals))
    correlation_matrix <- correlation_matrix + diag(abs(min_eigenval) + 0.01, n_assets)
    correlation_matrix <- cov2cor(correlation_matrix)
  }
  
  # Generate multivariate normal returns
  if(requireNamespace("MASS", quietly = TRUE)) {
    returns <- MASS::mvrnorm(n_periods, mu = rep(0, n_assets), Sigma = correlation_matrix)
  } else {
    # Fallback method using cholesky decomposition
    L <- chol(correlation_matrix)
    Z <- matrix(rnorm(n_periods * n_assets), n_periods, n_assets)
    returns <- Z %*% L
  }
  
  # Add some volatility clustering and regime changes
  for(i in 1:n_assets) {
    # Add GARCH-like volatility
    vol_process <- rep(1, n_periods)
    for(t in 2:n_periods) {
      vol_process[t] <- 0.9 * vol_process[t-1] + 0.1 * returns[t-1, i]^2 + 0.01
    }
    returns[, i] <- returns[, i] * sqrt(vol_process)
    
    # Add occasional jumps (crisis periods)
    jump_prob <- 0.02
    jumps <- rbinom(n_periods, 1, jump_prob)
    jump_sizes <- rnorm(n_periods, 0, 3) * jumps
    returns[, i] <- returns[, i] + jump_sizes
  }
  
  # Scale returns to realistic levels
  scale_factor <- switch(data_type,
    "global_markets" = 0.01,
    "crypto" = 0.03,
    "commodities" = 0.015,
    0.012
  )
  
  returns <- returns * scale_factor
  colnames(returns) <- asset_names[1:n_assets]
  
  return(returns)
}

#' Process Financial Data
#'
#' @description Clean and preprocess financial data for analysis
#'
#' @param data Numeric matrix or data frame of returns
#' @param remove_outliers Logical, whether to remove outliers
#' @param standardize Logical, whether to standardize returns
#'
#' @return Processed data matrix
#' @examples
#' # Generate sample data and process it
#' raw_data <- get_sample_data("global_markets", n_assets = 3, n_periods = 100)
#' 
#' # Process with outlier removal
#' clean_data <- process_financial_data(raw_data, remove_outliers = TRUE)
#' 
#' # Process with standardization
#' std_data <- process_financial_data(raw_data, standardize = TRUE)
#' 
#' # Compare dimensions
#' cat("Original:", dim(raw_data), "\n")
#' cat("Cleaned:", dim(clean_data), "\n")
#' 
#' @export
process_financial_data <- function(data, remove_outliers = TRUE, standardize = FALSE) {
  
  # Convert to matrix if needed
  if(is.data.frame(data)) {
    data <- as.matrix(data)
  }
  
  # Remove rows with all NA
  data <- data[complete.cases(data), , drop = FALSE]
  
  # Remove outliers if requested
  if(remove_outliers) {
    for(i in 1:ncol(data)) {
      Q1 <- quantile(data[, i], 0.25, na.rm = TRUE)
      Q3 <- quantile(data[, i], 0.75, na.rm = TRUE)
      IQR <- Q3 - Q1
      lower <- Q1 - 3 * IQR
      upper <- Q3 + 3 * IQR
      
      data[data[, i] < lower | data[, i] > upper, i] <- NA
    }
    
    # Remove rows with any NA after outlier removal
    data <- data[complete.cases(data), , drop = FALSE]
  }
  
  # Standardize if requested
  if(standardize) {
    data <- scale(data)
  }
  
  return(data)
}

#' Detect Asset Classes
#'
#' @description Automatically detect asset classes from data characteristics
#'
#' @param data Numeric matrix of returns
#' @param asset_names Character vector of asset names
#'
#' @return Character vector of detected asset classes
#' @examples
#' # Generate sample data with different characteristics
#' market_data <- get_sample_data("global_markets", n_assets = 3, n_periods = 100)
#' crypto_data <- get_sample_data("crypto", n_assets = 2, n_periods = 100)
#' 
#' # Combine datasets
#' combined_data <- cbind(market_data, crypto_data)
#' colnames(combined_data) <- c("SPX", "FTSE", "DAX", "BTC", "ETH")
#' 
#' # Detect asset classes
#' classes <- detect_asset_classes(combined_data)
#' print(classes)
#' 
#' @export
detect_asset_classes <- function(data, asset_names = NULL) {
  
  if(is.null(asset_names)) {
    asset_names <- colnames(data)
  }
  
  if(is.null(asset_names)) {
    asset_names <- paste0("Asset_", 1:ncol(data))
  }
  
  # Calculate statistics for classification
  volatilities <- apply(data, 2, sd, na.rm = TRUE)
  mean_returns <- apply(data, 2, mean, na.rm = TRUE)
  
  # Simple heuristic classification
  asset_classes <- rep("equity", length(asset_names))
  
  # High volatility suggests crypto
  high_vol_threshold <- quantile(volatilities, 0.8)
  asset_classes[volatilities > high_vol_threshold] <- "crypto"
  
  # Pattern matching for common names
  crypto_patterns <- c("BTC", "ETH", "crypto", "coin")
  commodity_patterns <- c("Gold", "Oil", "Crude", "Silver", "Copper", "Wheat")
  bond_patterns <- c("Bond", "Treasury", "Yield", "Rate")
  
  for(i in 1:length(asset_names)) {
    name_upper <- toupper(asset_names[i])
    
    if(any(sapply(crypto_patterns, function(x) grepl(x, name_upper, ignore.case = TRUE)))) {
      asset_classes[i] <- "crypto"
    } else if(any(sapply(commodity_patterns, function(x) grepl(x, name_upper, ignore.case = TRUE)))) {
      asset_classes[i] <- "commodity"
    } else if(any(sapply(bond_patterns, function(x) grepl(x, name_upper, ignore.case = TRUE)))) {
      asset_classes[i] <- "bond"
    }
  }
  
  names(asset_classes) <- asset_names
  return(asset_classes)
}

#' Validate Data Quality
#'
#' @description Check data quality and provide diagnostic information
#'
#' @param data Numeric matrix of returns data
#'
#' @return List with data quality metrics and recommendations
#' @examples
#' # Generate sample data for quality validation
#' data <- get_sample_data("global_markets", n_assets = 5, n_periods = 200)
#' 
#' # Validate data quality
#' quality_report <- validate_data_quality(data)
#' 
#' # View quality summary
#' cat("Quality Score:", quality_report$quality_score, "\n")
#' cat("Quality Level:", quality_report$quality_level, "\n")
#' cat("Issues:", paste(quality_report$issues, collapse = ", "), "\n")
#' 
#' @export
validate_data_quality <- function(data) {
  
  # Basic statistics
  n_obs <- nrow(data)
  n_assets <- ncol(data)
  
  # Missing data analysis
  missing_count <- sum(is.na(data))
  missing_pct <- missing_count / (n_obs * n_assets) * 100
  
  # Outlier detection
  outlier_counts <- numeric(n_assets)
  for(i in 1:n_assets) {
    Q1 <- quantile(data[, i], 0.25, na.rm = TRUE)
    Q3 <- quantile(data[, i], 0.75, na.rm = TRUE)
    IQR <- Q3 - Q1
    outlier_counts[i] <- sum(data[, i] < (Q1 - 3*IQR) | data[, i] > (Q3 + 3*IQR), na.rm = TRUE)
  }
  
  # Statistical properties
  mean_returns <- apply(data, 2, mean, na.rm = TRUE)
  volatilities <- apply(data, 2, sd, na.rm = TRUE)
  skewness <- apply(data, 2, function(x) moments::skewness(x, na.rm = TRUE))
  kurtosis <- apply(data, 2, function(x) moments::kurtosis(x, na.rm = TRUE))
  
  # Correlation analysis
  cor_matrix <- cor(data, use = "complete.obs")
  avg_correlation <- mean(cor_matrix[upper.tri(cor_matrix)])
  max_correlation <- max(cor_matrix[upper.tri(cor_matrix)])
  
  # Quality assessment
  quality_score <- 100
  issues <- character(0)
  recommendations <- character(0)
  
  if(missing_pct > 5) {
    quality_score <- quality_score - 20
    issues <- c(issues, paste("High missing data:", round(missing_pct, 1), "%"))
    recommendations <- c(recommendations, "Consider data imputation or removal of problematic assets")
  }
  
  if(any(outlier_counts > n_obs * 0.05)) {
    quality_score <- quality_score - 15
    issues <- c(issues, "Excessive outliers detected")
    recommendations <- c(recommendations, "Consider outlier treatment or robust estimation methods")
  }
  
  if(max_correlation > 0.95) {
    quality_score <- quality_score - 10
    issues <- c(issues, "Very high correlation between some assets")
    recommendations <- c(recommendations, "Check for duplicate or highly similar assets")
  }
  
  if(n_obs < 100) {
    quality_score <- quality_score - 25
    issues <- c(issues, "Limited sample size")
    recommendations <- c(recommendations, "Increase sample size for more reliable results")
  }
  
  # Overall assessment
  quality_level <- ifelse(quality_score >= 80, "Excellent",
                         ifelse(quality_score >= 60, "Good",
                               ifelse(quality_score >= 40, "Fair", "Poor")))
  
  return(list(
    quality_score = quality_score,
    quality_level = quality_level,
    n_observations = n_obs,
    n_assets = n_assets,
    missing_percentage = missing_pct,
    outlier_counts = outlier_counts,
    mean_returns = mean_returns,
    volatilities = volatilities,
    skewness = skewness,
    kurtosis = kurtosis,
    average_correlation = avg_correlation,
    max_correlation = max_correlation,
    issues = issues,
    recommendations = recommendations
  ))
}

#' Calculate Gini Coefficient
#'
#' @description Calculate Gini coefficient for wealth inequality measurement
#'
#' @param wealth Numeric vector of wealth values
#'
#' @return Numeric Gini coefficient (0 = perfect equality, 1 = perfect inequality)
#' @examples
#' # Example with equal wealth distribution
#' equal_wealth <- rep(100, 10)
#' gini_equal <- calculate_gini_coefficient(equal_wealth)
#' cat("Equal distribution Gini:", gini_equal, "\n")
#' 
#' # Example with unequal wealth distribution
#' unequal_wealth <- c(10, 20, 30, 40, 100, 200, 300, 400, 500, 1000)
#' gini_unequal <- calculate_gini_coefficient(unequal_wealth)
#' cat("Unequal distribution Gini:", gini_unequal, "\n")
#' 
#' @export
calculate_gini_coefficient <- function(wealth) {
  
  # Remove NA values
  wealth <- wealth[!is.na(wealth)]
  
  if(length(wealth) == 0) {
    return(NA)
  }
  
  # Sort wealth in ascending order
  wealth <- sort(wealth)
  n <- length(wealth)
  
  # Calculate Gini coefficient
  numerator <- sum((2 * 1:n - n - 1) * wealth)
  denominator <- n * sum(wealth)
  
  gini <- numerator / denominator
  
  return(gini)
}

#' Save Analysis Results
#'
#' @description Save analysis results to file
#'
#' @param results List of analysis results
#' @param filename Character string for output filename
#' @param format Character string: "rds", "csv", or "excel"
#'
#' @return Logical indicating success
#' @examples
#' \dontrun{
#' # Generate sample results
#' data <- get_sample_data("global_markets", n_assets = 3, n_periods = 100)
#' quality_results <- validate_data_quality(data)
#' 
#' # Save as RDS (default)
#' save_analysis_results(quality_results, "quality_report", "rds")
#' 
#' # Save as CSV (for data frames/matrices only)
#' summary_stats <- data.frame(
#'   Asset = colnames(data),
#'   Mean = apply(data, 2, mean),
#'   SD = apply(data, 2, sd)
#' )
#' save_analysis_results(summary_stats, "summary_stats", "csv")
#' }
#' 
#' @export
save_analysis_results <- function(results, filename, format = "rds") {
  
  tryCatch({
    switch(format,
      "rds" = {
        if(!endsWith(filename, ".rds")) filename <- paste0(filename, ".rds")
        saveRDS(results, filename)
      },
      "csv" = {
        if(!endsWith(filename, ".csv")) filename <- paste0(filename, ".csv")
        if(is.data.frame(results) || is.matrix(results)) {
          write.csv(results, filename, row.names = FALSE)
        } else {
          warning("CSV format only supports data frames and matrices")
          return(FALSE)
        }
      },
      "excel" = {
        if(!endsWith(filename, ".xlsx")) filename <- paste0(filename, ".xlsx")
        if(requireNamespace("writexl", quietly = TRUE)) {
          writexl::write_xlsx(results, filename)
        } else {
          warning("writexl package required for Excel export")
          return(FALSE)
        }
      },
      {
        warning("Unsupported format. Use 'rds', 'csv', or 'excel'")
        return(FALSE)
      }
    )
    
    cat("✅ Results saved to:", filename, "\n")
    return(TRUE)
    
  }, error = function(e) {
    warning("Failed to save results:", e$message)
    return(FALSE)
  })
}

#' Load Analysis Results
#'
#' @description Load previously saved analysis results
#'
#' @param filename Character string of file to load
#'
#' @return Loaded analysis results
#' @examples
#' \dontrun{
#' # Save sample results first
#' data <- get_sample_data("global_markets", n_assets = 3, n_periods = 100)
#' quality_results <- validate_data_quality(data)
#' save_analysis_results(quality_results, "test_results.rds")
#' 
#' # Load the results back
#' loaded_results <- load_analysis_results("test_results.rds")
#' 
#' # Clean up
#' file.remove("test_results.rds")
#' }
#' 
#' @export
load_analysis_results <- function(filename) {
  
  if(!file.exists(filename)) {
    stop("File not found:", filename)
  }
  
  tryCatch({
    if(endsWith(filename, ".rds")) {
      results <- readRDS(filename)
    } else if(endsWith(filename, ".csv")) {
      results <- read.csv(filename)
    } else if(endsWith(filename, ".xlsx")) {
      if(requireNamespace("readxl", quietly = TRUE)) {
        results <- readxl::read_excel(filename)
      } else {
        stop("readxl package required for Excel import")
      }
    } else {
      stop("Unsupported file format")
    }
    
    cat("✅ Results loaded from:", filename, "\n")
    return(results)
    
  }, error = function(e) {
    stop("Failed to load results:", e$message)
  })
}