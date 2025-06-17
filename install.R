#!/usr/bin/env Rscript
# =============================================================================
# AGENTICWAVES PACKAGE INSTALLATION SCRIPT
# =============================================================================

cat("
╔══════════════════════════════════════════════════════════════════════════════╗
║                        📦 AGENTICWAVES INSTALLER                           ║
║                     Autonomous AI Financial Network Analysis                ║
╚══════════════════════════════════════════════════════════════════════════════╝

🚀 Starting AgenticWaves package installation...

")

# Function to install required packages
install_dependencies <- function() {
  cat("📦 Installing package dependencies...\n")
  
  # Essential packages for package development
  dev_packages <- c("devtools", "roxygen2", "testthat", "pkgdown")
  
  # Core dependencies
  core_packages <- c(
    "shiny", "shinydashboard", "shinyWidgets", "DT", "plotly",
    "ggplot2", "ggraph", "tidygraph", "igraph", "viridis", "RColorBrewer",
    "dplyr", "tidyr", "purrr", "stringr", "readr", "readxl",
    "gridExtra", "corrplot", "R6", "parallel", "scales", "zoo", "moments",
    "MASS"
  )
  
  # Optional packages
  optional_packages <- c(
    "quantreg", "waveslim", "quantmod", "xts", "tseries",
    "pryr", "knitr", "rmarkdown"
  )
  
  all_packages <- c(dev_packages, core_packages, optional_packages)
  
  # Check which packages need installation
  missing_packages <- character(0)
  for(pkg in all_packages) {
    if(!requireNamespace(pkg, quietly = TRUE)) {
      missing_packages <- c(missing_packages, pkg)
    }
  }
  
  if(length(missing_packages) > 0) {
    cat("   Installing", length(missing_packages), "missing packages...\n")
    
    # Install from CRAN
    install.packages(missing_packages, dependencies = TRUE, quiet = TRUE)
    
    cat("   ✅ Dependencies installed successfully\n")
  } else {
    cat("   ✅ All dependencies already available\n")
  }
}

# Function to build and install package
install_package <- function() {
  cat("\n🔨 Building and installing AgenticWaves package...\n")
  
  # Load devtools
  if(!requireNamespace("devtools", quietly = TRUE)) {
    stop("devtools package required for installation")
  }
  
  # Set working directory to package root
  pkg_dir <- getwd()
  if(!file.exists("DESCRIPTION")) {
    stop("DESCRIPTION file not found. Please run from package root directory.")
  }
  
  tryCatch({
    # Generate documentation
    cat("   📚 Generating documentation...\n")
    devtools::document()
    
    # Run package checks (basic)
    cat("   🔍 Running basic package checks...\n")
    check_result <- devtools::check(quiet = TRUE, error_on = "never")
    
    # Install package
    cat("   📦 Installing package...\n")
    devtools::install(upgrade = "never", quiet = TRUE)
    
    cat("   ✅ AgenticWaves package installed successfully!\n")
    
  }, error = function(e) {
    cat("   ❌ Installation failed:", e$message, "\n")
    stop("Package installation failed")
  })
}

# Function to run basic tests
run_basic_tests <- function() {
  cat("\n🧪 Running basic functionality tests...\n")
  
  tryCatch({
    # Load the package
    library(AgenticWaves)
    
    # Test 1: Data functions
    cat("   📊 Testing data functions...\n")
    data <- get_sample_data("global_markets", n_assets = 5, n_periods = 100)
    stopifnot(is.matrix(data), ncol(data) == 5, nrow(data) == 100)
    
    # Test 2: Agent creation
    cat("   🤖 Testing agent creation...\n")
    agent <- create_autonomous_agent("explorer")
    stopifnot(inherits(agent, "autonomous_agent"))
    
    # Test 3: Agent population
    cat("   👥 Testing agent population...\n")
    agents <- create_enhanced_agent_population(n_agents = 20)
    stopifnot(is.list(agents), length(agents) == 20)
    
    # Test 4: Basic visualization
    cat("   🎨 Testing visualization...\n")
    cor_matrix <- cor(data)
    adj_matrix <- abs(cor_matrix) > 0.3
    diag(adj_matrix) <- FALSE
    
    if(sum(adj_matrix) > 0) {
      plot_obj <- plot_enhanced_network(adj_matrix)
      stopifnot(inherits(plot_obj, "ggplot"))
    }
    
    cat("   ✅ All basic tests passed!\n")
    
  }, error = function(e) {
    cat("   ❌ Test failed:", e$message, "\n")
    warning("Some functionality may not work correctly")
  })
}

# Function to display post-installation info
show_completion_info <- function() {
  cat("\n")
  cat("🎉 INSTALLATION COMPLETED SUCCESSFULLY!\n")
  cat("═══════════════════════════════════════════════════════════════════════════════\n\n")
  
  cat("🚀 Quick Start:\n")
  cat("   library(AgenticWaves)\n")
  cat("   launch_agentic_waves()          # Interactive menu\n")
  cat("   run_agentic_waves_app()         # Shiny dashboard\n")
  cat("   ?AgenticWaves                   # Package help\n\n")
  
  cat("📚 Example Usage:\n")
  cat("   # Load sample data\n")
  cat("   data <- get_sample_data('global_markets')\n\n")
  
  cat("   # Create AI agent\n")
  cat("   agent <- create_autonomous_agent('explorer')\n")
  cat("   results <- agent$analyze_autonomously(data)\n\n")
  
  cat("   # Run full simulation\n")
  cat("   agents <- create_enhanced_agent_population(500)\n")
  cat("   sim <- simulate_enhanced_market_dynamics(agents, data)\n")
  cat("   spillovers <- calculate_dynamic_spillover_networks(sim)\n\n")
  
  cat("🔧 Advanced Features:\n")
  cat("   • Autonomous AI agents with self-optimization\n")
  cat("   • Multi-asset analysis (stocks, crypto, commodities)\n")
  cat("   • Dynamic spillover and contagion detection\n")
  cat("   • Publication-quality ggraph visualizations\n")
  cat("   • Interactive Shiny dashboard\n")
  cat("   • Comprehensive reporting system\n\n")
  
  cat("📧 Support:\n")
  cat("   • GitHub: https://github.com/avishekb9/AgenticWaves\n")
  cat("   • Issues: https://github.com/avishekb9/AgenticWaves/issues\n")
  cat("   • Email: bavisek@gmail.com\n\n")
  
  cat("✨ Ready to revolutionize financial network analysis!\n")
}

# Main installation process
main <- function() {
  tryCatch({
    # Step 1: Install dependencies
    install_dependencies()
    
    # Step 2: Build and install package
    install_package()
    
    # Step 3: Run basic tests
    run_basic_tests()
    
    # Step 4: Show completion info
    show_completion_info()
    
  }, error = function(e) {
    cat("\n❌ Installation failed:", e$message, "\n")
    cat("💡 Please check the error messages above and try again.\n")
    cat("💡 Make sure you're running from the AgenticWaves package directory.\n")
    quit(status = 1)
  })
}

# Run installation if script is executed directly
if(sys.nframe() == 0) {
  main()
}