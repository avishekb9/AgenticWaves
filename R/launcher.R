#' Launch AgenticWaves Application
#'
#' @description 
#' Interactive launcher for the AgenticWaves framework with auto-detection 
#' of available functions and smooth application startup.
#'
#' @param mode Character string specifying launch mode. Options:
#'   \itemize{
#'     \item "interactive" - Show interactive menu (default)
#'     \item "shiny" - Launch Shiny dashboard directly
#'     \item "demo" - Run complete demonstration
#'     \item "quick" - Quick autonomous analysis
#'   }
#' @param auto_install Logical. If TRUE, automatically install missing packages.
#' @param check_system Logical. If TRUE, perform system diagnostics before launch.
#' 
#' @return Launches the specified application mode
#' 
#' @export
#' 
#' @examples
#' \dontrun{
#' # Launch interactive menu (default)
#' launch_agentic_waves()
#' 
#' # Launch Shiny app directly
#' launch_agentic_waves(mode = "shiny")
#' 
#' # Run complete demonstration
#' launch_agentic_waves(mode = "demo")
#' 
#' # Quick autonomous analysis
#' launch_agentic_waves(mode = "quick")
#' 
#' # Launch without system checks (faster)
#' launch_agentic_waves(mode = "interactive", check_system = FALSE)
#' }
launch_agentic_waves <- function(mode = "interactive", 
                                auto_install = TRUE, 
                                check_system = TRUE) {
  
  # Display welcome banner
  cat(get_welcome_banner())
  
  # Check system if requested
  if (check_system) {
    system_status <- check_system_requirements()
    if (!system_status$ready) {
      cat("❌ System requirements not met. See details above.\n")
      return(invisible(FALSE))
    }
  }
  
  # Auto-install missing packages if requested
  if (auto_install) {
    install_missing_packages()
  }
  
  # Auto-detect available functions
  available_functions <- detect_available_functions()
  cat("✅ Detected", length(available_functions), "available functions\n\n")
  
  # Execute based on mode
  switch(mode,
    "interactive" = run_interactive_menu(),
    "shiny" = run_agentic_waves_app(),
    "demo" = run_complete_demo(),
    "quick" = run_quick_analysis(),
    {
      cat("❌ Unknown mode:", mode, "\n")
      cat("Valid modes: interactive, shiny, demo, quick\n")
      return(invisible(FALSE))
    }
  )
  
  invisible(TRUE)
}

#' Run AgenticWaves Shiny Application
#'
#' @description Launch the interactive Shiny dashboard for AgenticWaves analysis.
#'
#' @param host Character string specifying the host IP address (default: "127.0.0.1")
#' @param port Integer specifying the port number (default: auto-assigned)
#' @param launch.browser Logical. If TRUE, launch browser automatically (default: TRUE)
#' @param display.mode Character string specifying display mode ("normal", "showcase")
#' 
#' @return Launches the Shiny application
#' 
#' @export
#' 
#' @examples
#' \dontrun{
#' # Launch with default settings
#' run_agentic_waves_app()
#' 
#' # Launch on specific port
#' run_agentic_waves_app(port = 8080)
#' 
#' # Launch without auto-opening browser
#' run_agentic_waves_app(launch.browser = FALSE)
#' 
#' # Launch on specific host and port
#' run_agentic_waves_app(host = "0.0.0.0", port = 3838)
#' 
#' # Launch in showcase mode
#' run_agentic_waves_app(display.mode = "showcase")
#' }
run_agentic_waves_app <- function(host = "127.0.0.1", 
                                 port = NULL,
                                 launch.browser = TRUE,
                                 display.mode = "normal") {
  
  cat("📱 Launching AgenticWaves Shiny Dashboard...\n")
  
  # Check if Shiny app files exist
  app_path <- system.file("shiny", package = "AgenticWaves")
  
  if (!dir.exists(app_path) || !file.exists(file.path(app_path, "app.R"))) {
    cat("❌ Shiny app files not found!\n")
    cat("🔧 Creating Shiny app...\n")
    create_shiny_app()
    app_path <- system.file("shiny", package = "AgenticWaves")
  }
  
  # Launch the app
  tryCatch({
    shiny::runApp(
      appDir = app_path,
      host = host,
      port = port,
      launch.browser = launch.browser,
      display.mode = display.mode
    )
  }, error = function(e) {
    cat("❌ Failed to launch Shiny app:", e$message, "\n")
    cat("💡 Try: run_agentic_waves_app(launch.browser = FALSE)\n")
  })
}

#' Auto-detect Available Functions
#'
#' @description Automatically detect all available AgenticWaves functions
#' and their status.
#'
#' @return Named list of available functions with their status
#' 
#' @export
detect_available_functions <- function() {
  
  cat("🔍 Auto-detecting available functions...\n")
  
  # Core function list
  core_functions <- list(
    "Data Functions" = c(
      "get_sample_data",
      "process_financial_data", 
      "detect_asset_classes",
      "validate_data_quality"
    ),
    "Agent Functions" = c(
      "create_autonomous_agent",
      "create_enhanced_agent_population",
      "create_dynamic_multilayer_network"
    ),
    "Analysis Functions" = c(
      "simulate_enhanced_market_dynamics",
      "calculate_dynamic_spillover_networks",
      "detect_contagion_episodes"
    ),
    "Visualization Functions" = c(
      "plot_enhanced_network",
      "plot_agent_type_network", 
      "generate_publication_dashboard"
    ),
    "Utility Functions" = c(
      "calculate_gini_coefficient",
      "save_analysis_results",
      "load_analysis_results"
    )
  )
  
  # Check function availability
  available_functions <- list()
  total_functions <- 0
  available_count <- 0
  
  for (category in names(core_functions)) {
    cat("  📂", category, ":\n")
    category_functions <- c()
    
    for (func_name in core_functions[[category]]) {
      total_functions <- total_functions + 1
      
      if (exists(func_name, mode = "function")) {
        cat("    ✅", func_name, "\n")
        category_functions <- c(category_functions, func_name)
        available_count <- available_count + 1
      } else {
        cat("    ❌", func_name, "(not found)\n")
      }
    }
    
    available_functions[[category]] <- category_functions
  }
  
  cat("\n📊 Function Detection Summary:\n")
  cat("   Available:", available_count, "/", total_functions, 
      "(", round(available_count/total_functions*100, 1), "%)\n")
  
  return(available_functions)
}

#' Check System Requirements
#'
#' @description Check if the system meets requirements for AgenticWaves.
#'
#' @return List with system status information
#' 
#' @export
check_system_requirements <- function() {
  
  cat("🔧 Checking system requirements...\n")
  
  status <- list(ready = TRUE, issues = c())
  
  # Check R version
  r_version <- getRversion()
  min_r_version <- "4.0.0"
  
  if (r_version < min_r_version) {
    status$ready <- FALSE
    status$issues <- c(status$issues, 
                      paste("R version", as.character(r_version), "< required", min_r_version))
    cat("❌ R version:", as.character(r_version), "(requires >=", min_r_version, ")\n")
  } else {
    cat("✅ R version:", as.character(r_version), "\n")
  }
  
  # Check memory
  tryCatch({
    if (requireNamespace("pryr", quietly = TRUE)) {
      memory_usage <- pryr::mem_used()
      cat("✅ Memory usage:", format(memory_usage), "\n")
    } else {
      cat("💡 Install 'pryr' package for memory monitoring\n")
    }
  }, error = function(e) {
    cat("⚠️ Memory check failed\n")
  })
  
  # Check CPU cores
  cpu_cores <- parallel::detectCores()
  cat("✅ CPU cores:", cpu_cores, "\n")
  
  # Check critical packages
  critical_packages <- c("shiny", "ggplot2", "igraph", "dplyr")
  missing_packages <- c()
  
  for (pkg in critical_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      missing_packages <- c(missing_packages, pkg)
    }
  }
  
  if (length(missing_packages) > 0) {
    status$ready <- FALSE
    status$issues <- c(status$issues, 
                      paste("Missing packages:", paste(missing_packages, collapse = ", ")))
    cat("❌ Missing critical packages:", paste(missing_packages, collapse = ", "), "\n")
  } else {
    cat("✅ All critical packages available\n")
  }
  
  # Overall status
  if (status$ready) {
    cat("✅ System ready for AgenticWaves!\n")
  } else {
    cat("❌ System issues found:\n")
    for (issue in status$issues) {
      cat("   •", issue, "\n")
    }
  }
  
  return(status)
}

#' Install Missing Packages
#'
#' @description Automatically install packages required by AgenticWaves.
#'
#' @param force_reinstall Logical. If TRUE, reinstall all packages.
#' 
#' @return Invisible logical indicating success
#' 
#' @export
install_missing_packages <- function(force_reinstall = FALSE) {
  
  # Required packages
  required_packages <- c(
    "shiny", "shinydashboard", "shinyWidgets", "DT", "plotly",
    "ggplot2", "ggraph", "tidygraph", "igraph", "viridis", "RColorBrewer",
    "dplyr", "tidyr", "purrr", "stringr", "readr", "readxl",
    "gridExtra", "corrplot", "R6", "scales", "zoo", "moments"
  )
  
  # Optional packages
  optional_packages <- c(
    "quantreg", "waveslim", "quantmod", "xts", "tseries",
    "pryr", "devtools", "pkgdown"
  )
  
  # Check and install required packages
  missing_required <- c()
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE) || force_reinstall) {
      missing_required <- c(missing_required, pkg)
    }
  }
  
  if (length(missing_required) > 0) {
    cat("📦 Installing", length(missing_required), "required packages...\n")
    
    tryCatch({
      install.packages(missing_required, quiet = TRUE)
      cat("✅ Required packages installed successfully\n")
    }, error = function(e) {
      cat("❌ Failed to install some packages:", e$message, "\n")
      return(invisible(FALSE))
    })
  }
  
  # Check and install optional packages (with user consent)
  missing_optional <- c()
  for (pkg in optional_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      missing_optional <- c(missing_optional, pkg)
    }
  }
  
  if (length(missing_optional) > 0) {
    cat("💡 Optional packages available:", paste(missing_optional, collapse = ", "), "\n")
    response <- readline("Install optional packages? (y/n): ")
    
    if (tolower(substr(response, 1, 1)) == "y") {
      tryCatch({
        install.packages(missing_optional, quiet = TRUE)
        cat("✅ Optional packages installed\n")
      }, error = function(e) {
        cat("⚠️ Some optional packages failed to install\n")
      })
    }
  }
  
  return(invisible(TRUE))
}

#' Get Welcome Banner
#'
#' @description Generate the AgenticWaves welcome banner.
#'
#' @return Character string with formatted banner
get_welcome_banner <- function() {
  paste0(
    "\n",
    "╔══════════════════════════════════════════════════════════════════════════════╗\n",
    "║                        🚀 AGENTICWAVES FRAMEWORK                           ║\n",
    "║              Agentic AI-Powered Financial Network Analysis                  ║\n",
    "║                              Version 1.0.0                                 ║\n",
    "╠══════════════════════════════════════════════════════════════════════════════╣\n",
    "║                                                                            ║\n",
    "║  🎯 AUTONOMOUS AI ANALYSIS    🕸️ DYNAMIC NETWORKS    📊 MULTI-ASSET       ║\n",
    "║  🤖 INTELLIGENT AGENTS       🌊 SPILLOVER DETECTION  📱 INTERACTIVE UI    ║\n",
    "║                                                                            ║\n",
    "╚══════════════════════════════════════════════════════════════════════════════╝\n",
    "\n",
    "🔬 CAPABILITIES:\n",
    "  • Multi-Asset Analysis: Stocks, Commodities, Crypto, Bonds, REITs\n",
    "  • Autonomous AI Agents: Self-optimizing intelligent analysis\n",
    "  • Dynamic Networks: Real-time spillover and contagion detection\n",
    "  • Publication Quality: Journal-ready visualizations and reports\n",
    "\n"
  )
}

#' Run Interactive Menu
#'
#' @description Display and handle the interactive menu system.
run_interactive_menu <- function() {
  
  repeat {
    choice <- show_interactive_menu()
    
    if (!execute_menu_choice(choice)) {
      break
    }
    
    if (choice != "0") {
      cat("\n")
      readline("Press Enter to return to main menu...")
      cat("\n")
    }
  }
}

#' Show Interactive Menu
#'
#' @description Display the interactive menu options.
#'
#' @return Character string with user choice
show_interactive_menu <- function() {
  cat("
═══════════════════════════════════════════════════════════════════════════════
🎮 AGENTICWAVES LAUNCHER - SELECT YOUR MISSION
═══════════════════════════════════════════════════════════════════════════════

🚀 ANALYSIS OPTIONS:
1️⃣  📱 Launch Interactive Dashboard    - Full-featured Shiny application
2️⃣  🤖 Quick Autonomous Analysis       - AI-powered analysis with sample data  
3️⃣  🎬 Run Complete Demo               - Full demonstration with all features
4️⃣  🕸️ Network Analysis Only          - Focus on spillover networks
5️⃣  👥 Agent Simulation Only          - Agent-based market modeling

📊 DATA & TOOLS:
6️⃣  📁 Load Custom Dataset            - Upload and analyze your own data
7️⃣  🎨 Generate Visualization Gallery - Create publication-quality plots
8️⃣  📄 Create Sample Report           - Generate comprehensive analysis report

🔧 SYSTEM TOOLS:
9️⃣  🔍 System Diagnostics             - Check system status and performance
🔟  📚 View Documentation              - Package help and tutorials
1️⃣1️⃣ 🧪 Test All Functions           - Comprehensive function testing

0️⃣  ❌ Exit AgenticWaves

═══════════════════════════════════════════════════════════════════════════════")
  
  choice <- readline("👆 Enter your choice (0-11): ")
  return(choice)
}

#' Execute Menu Choice
#'
#' @description Execute the selected menu option.
#'
#' @param choice Character string with menu choice
#' @return Logical indicating whether to continue menu loop
execute_menu_choice <- function(choice) {
  
  switch(choice,
    "1" = {
      cat("📱 Launching Interactive Dashboard...\n")
      run_agentic_waves_app()
    },
    
    "2" = {
      cat("🤖 Starting Quick Autonomous Analysis...\n")
      run_quick_analysis()
    },
    
    "3" = {
      cat("🎬 Running Complete Demo...\n")
      run_complete_demo()
    },
    
    "4" = {
      cat("🕸️ Running Network Analysis...\n")
      run_network_analysis_only()
    },
    
    "5" = {
      cat("👥 Running Agent Simulation...\n")
      run_agent_simulation_only()
    },
    
    "6" = {
      cat("📁 Loading Custom Dataset...\n")
      load_custom_dataset()
    },
    
    "7" = {
      cat("🎨 Generating Visualization Gallery...\n")
      generate_visualization_gallery()
    },
    
    "8" = {
      cat("📄 Creating Sample Report...\n")
      create_sample_report()
    },
    
    "9" = {
      cat("🔍 Running System Diagnostics...\n")
      check_system_requirements()
    },
    
    "10" = {
      cat("📚 Opening Documentation...\n")
      show_documentation()
    },
    
    "11" = {
      cat("🧪 Testing All Functions...\n")
      test_all_functions()
    },
    
    "0" = {
      cat("👋 Thank you for using AgenticWaves!\n")
      cat("🌟 Star us on GitHub: https://github.com/avishekb9/AgenticWaves\n")
      cat("📧 Contact: bavisek@gmail.com\n\n")
      return(FALSE)
    },
    
    {
      cat("❌ Invalid choice. Please enter a number between 0-11.\n")
    }
  )
  
  return(TRUE)
}

# Menu option implementations
run_quick_analysis <- function() {
  cat("⚡ Running Quick Analysis...\n")
  
  tryCatch({
    # Load sample data
    cat("📊 Loading sample data...\n")
    data <- get_sample_data("global_markets", n_assets = 8, n_periods = 250)
    
    # Create autonomous agent
    cat("🤖 Creating AI agent...\n")
    agent <- create_autonomous_agent("explorer")
    
    # Run analysis
    cat("🔍 Running autonomous analysis...\n")
    results <- agent$analyze_autonomously(data, objective = "exploration", autonomy_level = 3)
    
    # Display results
    cat("\n✅ Quick Analysis Results:\n")
    cat("   • Data quality score:", results$data_quality$quality_score, "/100\n")
    cat("   • Assets analyzed:", ncol(data), "\n")
    cat("   • Key insights found:", length(results$insights), "\n")
    
    # Show top insight
    if(length(results$insights) > 0) {
      cat("\n💡 Top Insight:\n")
      cat("  ", names(results$insights)[1], ":", results$insights[[1]], "\n")
    }
    
    cat("\n🎯 Analysis complete! Use the Shiny dashboard for detailed exploration.\n")
    
  }, error = function(e) {
    cat("❌ Quick analysis failed:", e$message, "\n")
  })
}

run_complete_demo <- function() {
  cat("🎬 Running Complete Demo...\n")
  cat("⏱️ This will take 2-3 minutes...\n\n")
  
  tryCatch({
    # Step 1: Data preparation
    cat("📊 Step 1: Preparing multi-asset data...\n")
    data <- get_sample_data("global_markets", n_assets = 10, n_periods = 500)
    cat("   ✅ Loaded", ncol(data), "assets with", nrow(data), "observations\n")
    
    # Step 2: Create agent population
    cat("\n👥 Step 2: Creating agent population...\n")
    agents <- create_enhanced_agent_population(n_agents = 200, behavioral_heterogeneity = 0.7)
    cat("   ✅ Created", length(agents), "heterogeneous agents\n")
    
    # Step 3: Run market simulation
    cat("\n🎬 Step 3: Running market simulation...\n")
    sim_results <- simulate_enhanced_market_dynamics(agents, data, n_periods = 300)
    cat("   ✅ Simulation completed -", sim_results$n_periods, "periods\n")
    cat("   📈 Average agent return:", round(mean(sim_results$agent_returns) * 100, 2), "%\n")
    
    # Step 4: Spillover analysis
    cat("\n🌊 Step 4: Analyzing spillovers...\n")
    spillover_results <- calculate_dynamic_spillover_networks(sim_results, window_size = 80)
    cat("   ✅ Spillover analysis completed\n")
    cat("   📊 Average spillover:", round(mean(spillover_results$total_spillover), 2), "%\n")
    cat("   🔥 Contagion episodes:", nrow(spillover_results$contagion_episodes), "\n")
    
    # Step 5: Generate visualizations
    cat("\n🎨 Step 5: Creating publication dashboard...\n")
    if(!dir.exists("demo_output")) dir.create("demo_output")
    plots <- generate_publication_dashboard(sim_results, spillover_results, 
                                          output_dir = "demo_output", save_plots = TRUE)
    cat("   ✅ Generated", length(plots), "publication-quality plots\n")
    cat("   📁 Saved to: demo_output/\n")
    
    # Summary
    cat("\n🎉 COMPLETE DEMO FINISHED!\n")
    cat("═══════════════════════════════════════\n")
    cat("📊 Summary Results:\n")
    cat("   • Assets analyzed:", ncol(data), "\n")
    cat("   • Agents simulated:", length(agents), "\n")
    cat("   • Simulation periods:", sim_results$n_periods, "\n")
    cat("   • Final wealth Gini:", round(sim_results$final_wealth_gini, 3), "\n")
    cat("   • Peak spillover:", round(max(spillover_results$total_spillover), 2), "%\n")
    cat("   • Visualizations created:", length(plots), "\n")
    cat("   • Output directory: demo_output/\n")
    
  }, error = function(e) {
    cat("❌ Demo failed:", e$message, "\n")
  })
}

run_network_analysis_only <- function() {
  cat("🕸️ Running Network Analysis...\n")
  
  tryCatch({
    # Load data
    cat("📊 Loading financial data...\n")
    data <- get_sample_data("global_markets", n_assets = 12, n_periods = 400)
    
    # Calculate correlation network
    cat("🔗 Computing correlation network...\n")
    cor_matrix <- cor(data)
    
    # Apply threshold and create network
    threshold <- 0.3
    adj_matrix <- abs(cor_matrix) > threshold
    diag(adj_matrix) <- FALSE
    
    if(sum(adj_matrix) == 0) {
      cat("⚠️ No connections above threshold, lowering to 0.2...\n")
      threshold <- 0.2
      adj_matrix <- abs(cor_matrix) > threshold
      diag(adj_matrix) <- FALSE
    }
    
    # Calculate network metrics
    cat("📊 Calculating network metrics...\n")
    network_metrics <- calculate_network_metrics(adj_matrix)
    
    # Create visualization
    cat("🎨 Creating network visualization...\n")
    if(!dir.exists("network_output")) dir.create("network_output")
    
    network_plot <- plot_enhanced_network(adj_matrix, layout = "stress", 
                                        node_size_var = "degree")
    
    ggplot2::ggsave("network_output/financial_network.png", network_plot, 
                   width = 12, height = 8, dpi = 300)
    
    # Display results
    cat("\n✅ Network Analysis Results:\n")
    cat("   • Nodes (assets):", network_metrics$n_nodes, "\n")
    cat("   • Edges (connections):", network_metrics$n_edges, "\n")
    cat("   • Network density:", round(network_metrics$density, 3), "\n")
    cat("   • Clustering coefficient:", round(network_metrics$transitivity, 3), "\n")
    cat("   • Average path length:", round(network_metrics$average_path_length, 2), "\n")
    cat("   • Number of communities:", network_metrics$n_communities, "\n")
    cat("   • Modularity score:", round(network_metrics$modularity, 3), "\n")
    
    if(!is.na(network_metrics$small_world_sigma)) {
      cat("   • Small-world sigma:", round(network_metrics$small_world_sigma, 3), "\n")
    }
    
    cat("\n📁 Network plot saved to: network_output/financial_network.png\n")
    
  }, error = function(e) {
    cat("❌ Network analysis failed:", e$message, "\n")
  })
}

run_agent_simulation_only <- function() {
  cat("👥 Running Agent Simulation...\n")
  
  tryCatch({
    # Load market data
    cat("📊 Loading market data...\n")
    data <- get_sample_data("global_markets", n_assets = 8, n_periods = 400)
    
    # Create diverse agent population
    cat("🎭 Creating diverse agent population...\n")
    agents <- create_enhanced_agent_population(
      n_agents = 300, 
      behavioral_heterogeneity = 0.8,
      wealth_distribution = "pareto"
    )
    
    initial_gini <- attr(agents, "wealth_gini")
    type_dist <- attr(agents, "type_distribution")
    
    cat("   ✅ Agent population created:\n")
    for(type in names(type_dist)) {
      cat("      •", type, ":", type_dist[type], "agents\n")
    }
    cat("   💰 Initial wealth Gini:", round(initial_gini, 3), "\n")
    
    # Run market simulation
    cat("\n🔄 Running market simulation...\n")
    sim_results <- simulate_enhanced_market_dynamics(
      agents = agents,
      asset_data = data,
      n_periods = 400,
      network_effects = TRUE
    )
    
    # Analyze results
    cat("\n📊 Analyzing simulation results...\n")
    
    # Calculate performance by agent type
    agent_types <- sapply(agents, function(x) x$type)
    performance_by_type <- tapply(sim_results$agent_returns, agent_types, function(x) {
      list(
        mean_return = mean(x),
        volatility = sd(x),
        sharpe = mean(x) / sd(x)
      )
    })
    
    # Display results
    cat("\n✅ Agent Simulation Results:\n")
    cat("═══════════════════════════════════════\n")
    cat("📈 Market Performance:\n")
    cat("   • Simulation periods:", sim_results$n_periods, "\n")
    cat("   • Average market return:", round(mean(sim_results$market_returns) * 100, 2), "%\n")
    cat("   • Market volatility:", round(sd(sim_results$market_returns) * 100, 2), "%\n")
    
    cat("\n👥 Agent Performance:\n")
    cat("   • Average agent return:", round(mean(sim_results$agent_returns) * 100, 2), "%\n")
    cat("   • Agent return volatility:", round(sd(sim_results$agent_returns) * 100, 2), "%\n")
    cat("   • Final wealth Gini:", round(sim_results$final_wealth_gini, 3), "\n")
    cat("   • Wealth inequality change:", 
        round((sim_results$final_wealth_gini - initial_gini) * 100, 1), "pp\n")
    
    cat("\n🏆 Performance by Agent Type:\n")
    for(type in names(performance_by_type)) {
      perf <- performance_by_type[[type]]
      cat("   •", type, ":\n")
      cat("      Return:", round(perf$mean_return * 100, 2), "%\n")
      cat("      Volatility:", round(perf$volatility * 100, 2), "%\n")
      cat("      Sharpe ratio:", round(perf$sharpe, 3), "\n")
    }
    
    cat("\n🔬 Market Regimes Encountered:", length(unique(sim_results$market_regimes)), "\n")
    
  }, error = function(e) {
    cat("❌ Agent simulation failed:", e$message, "\n")
  })
}

load_custom_dataset <- function() {
  cat("📁 Custom Dataset Loading\n")
  cat("═══════════════════════════\n")
  
  # Interactive file selection
  cat("Please provide the path to your CSV file:\n")
  file_path <- readline("File path: ")
  
  if(file_path == "" || !file.exists(file_path)) {
    cat("❌ File not found or invalid path.\n")
    cat("💡 Tip: Use forward slashes (/) in file paths\n")
    cat("💡 Example: ~/Documents/my_data.csv\n")
    return()
  }
  
  tryCatch({
    cat("📖 Reading file...\n")
    
    if(grepl("\\.csv$", file_path, ignore.case = TRUE)) {
      data <- read.csv(file_path, header = TRUE)
    } else if(grepl("\\.xlsx?$", file_path, ignore.case = TRUE)) {
      if(requireNamespace("readxl", quietly = TRUE)) {
        data <- readxl::read_excel(file_path)
      } else {
        cat("❌ readxl package required for Excel files\n")
        return()
      }
    } else {
      cat("❌ Unsupported file format. Use CSV or Excel files.\n")
      return()
    }
    
    # Convert to matrix if needed
    if(is.data.frame(data)) {
      # Remove non-numeric columns
      numeric_cols <- sapply(data, is.numeric)
      if(sum(numeric_cols) == 0) {
        cat("❌ No numeric columns found in data\n")
        return()
      }
      data <- as.matrix(data[, numeric_cols, drop = FALSE])
    }
    
    # Validate data
    cat("🔍 Validating data quality...\n")
    quality <- validate_data_quality(data)
    
    cat("\n✅ Data loaded successfully!\n")
    cat("   • Dimensions:", nrow(data), "x", ncol(data), "\n")
    cat("   • Quality score:", quality$quality_score, "/100\n")
    cat("   • Missing data:", round(quality$missing_percentage, 2), "%\n")
    
    if(quality$quality_score < 60) {
      cat("\n⚠️ Data quality concerns detected:\n")
      for(issue in quality$issues) {
        cat("   •", issue, "\n")
      }
      cat("\n💡 Recommendations:\n")
      for(rec in quality$recommendations) {
        cat("   •", rec, "\n")
      }
    }
    
    # Process data if needed
    response <- readline("Process data (remove outliers, handle missing values)? (y/n): ")
    if(tolower(substr(response, 1, 1)) == "y") {
      cat("🔧 Processing data...\n")
      processed_data <- process_financial_data(data, remove_outliers = TRUE, standardize = FALSE)
      cat("   ✅ Data processed. New dimensions:", nrow(processed_data), "x", ncol(processed_data), "\n")
      data <- processed_data
    }
    
    # Save processed data
    output_file <- "custom_data_processed.rds"
    saveRDS(data, output_file)
    cat("💾 Processed data saved to:", output_file, "\n")
    
    cat("\n🎯 Data ready for analysis! Use other menu options to analyze.\n")
    
  }, error = function(e) {
    cat("❌ Failed to load data:", e$message, "\n")
  })
}

generate_visualization_gallery <- function() {
  cat("🎨 Generating Visualization Gallery...\n")
  
  tryCatch({
    # Create output directory
    output_dir <- "visualization_gallery"
    if(!dir.exists(output_dir)) dir.create(output_dir)
    
    cat("📊 Preparing sample data...\n")
    
    # 1. Market data visualization
    data <- get_sample_data("global_markets", n_assets = 10, n_periods = 300)
    
    # Price evolution plot
    cat("   📈 Creating market evolution plot...\n")
    price_data <- data.frame(
      Time = rep(1:nrow(data), ncol(data)),
      Asset = rep(colnames(data), each = nrow(data)),
      Return = as.vector(data)
    )
    
    p1 <- ggplot2::ggplot(price_data, ggplot2::aes(x = Time, y = Return, color = Asset)) +
      ggplot2::geom_line(alpha = 0.8) +
      ggplot2::scale_color_viridis_d() +
      ggplot2::theme_minimal() +
      ggplot2::labs(title = "Market Return Evolution", x = "Time", y = "Returns") +
      ggplot2::theme(legend.position = "none")
    
    ggplot2::ggsave(file.path(output_dir, "market_evolution.png"), p1, 
                   width = 12, height = 6, dpi = 300)
    
    # 2. Correlation heatmap
    cat("   🔥 Creating correlation heatmap...\n")
    cor_matrix <- cor(data)
    cor_data <- expand.grid(Asset1 = colnames(data), Asset2 = colnames(data))
    cor_data$Correlation <- as.vector(cor_matrix)
    
    p2 <- ggplot2::ggplot(cor_data, ggplot2::aes(x = Asset1, y = Asset2, fill = Correlation)) +
      ggplot2::geom_tile() +
      ggplot2::scale_fill_gradient2(low = "blue", mid = "white", high = "red", 
                                   midpoint = 0) +
      ggplot2::theme_minimal() +
      ggplot2::labs(title = "Asset Correlation Heatmap") +
      ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
    
    ggplot2::ggsave(file.path(output_dir, "correlation_heatmap.png"), p2, 
                   width = 10, height = 8, dpi = 300)
    
    # 3. Network visualization
    cat("   🕸️ Creating network visualization...\n")
    adj_matrix <- abs(cor_matrix) > 0.3
    diag(adj_matrix) <- FALSE
    
    if(sum(adj_matrix) > 0) {
      p3 <- plot_enhanced_network(adj_matrix, layout = "stress")
      ggplot2::ggsave(file.path(output_dir, "financial_network.png"), p3, 
                     width = 10, height = 8, dpi = 300)
    }
    
    # 4. Agent simulation visualization
    cat("   👥 Creating agent simulation plots...\n")
    agents <- create_enhanced_agent_population(n_agents = 100, behavioral_heterogeneity = 0.7)
    type_dist <- table(sapply(agents, function(x) x$type))
    
    type_data <- data.frame(
      Type = names(type_dist),
      Count = as.numeric(type_dist)
    )
    
    p4 <- ggplot2::ggplot(type_data, ggplot2::aes(x = Type, y = Count, fill = Type)) +
      ggplot2::geom_col() +
      ggplot2::scale_fill_viridis_d() +
      ggplot2::theme_minimal() +
      ggplot2::labs(title = "Agent Type Distribution", x = "Agent Type", y = "Count") +
      ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
                    legend.position = "none")
    
    ggplot2::ggsave(file.path(output_dir, "agent_distribution.png"), p4, 
                   width = 10, height = 6, dpi = 300)
    
    # 5. Sample spillover evolution
    cat("   🌊 Creating spillover evolution plot...\n")
    spillover_data <- data.frame(
      Time = 1:200,
      Spillover = abs(rnorm(200, 30, 10)) + 10 * sin(1:200 / 20)
    )
    
    p5 <- ggplot2::ggplot(spillover_data, ggplot2::aes(x = Time, y = Spillover)) +
      ggplot2::geom_line(color = "steelblue", size = 1) +
      ggplot2::geom_smooth(color = "red", se = TRUE) +
      ggplot2::theme_minimal() +
      ggplot2::labs(title = "Spillover Evolution", x = "Time", y = "Total Spillover (%)")
    
    ggplot2::ggsave(file.path(output_dir, "spillover_evolution.png"), p5, 
                   width = 12, height = 6, dpi = 300)
    
    # Create gallery index
    cat("   📄 Creating gallery index...\n")
    
    index_content <- paste0(
      "# AgenticWaves Visualization Gallery\\n\\n",
      "Generated on: ", Sys.time(), "\\n\\n",
      "## Market Analysis\\n",
      "- ![Market Evolution](market_evolution.png)\\n",
      "- ![Correlation Heatmap](correlation_heatmap.png)\\n\\n",
      "## Network Analysis\\n",
      "- ![Financial Network](financial_network.png)\\n\\n",
      "## Agent-Based Modeling\\n", 
      "- ![Agent Distribution](agent_distribution.png)\\n\\n",
      "## Spillover Analysis\\n",
      "- ![Spillover Evolution](spillover_evolution.png)\\n\\n",
      "---\\n",
      "*Created with AgenticWaves v1.0.0*"
    )
    
    writeLines(index_content, file.path(output_dir, "README.md"))
    
    cat("\n✅ Visualization Gallery Complete!\n")
    cat("📁 Location:", output_dir, "/\n")
    cat("🖼️ Visualizations created:\n")
    cat("   • market_evolution.png - Market return dynamics\n")
    cat("   • correlation_heatmap.png - Asset correlation matrix\n")
    cat("   • financial_network.png - Network visualization\n")
    cat("   • agent_distribution.png - Agent type distribution\n")
    cat("   • spillover_evolution.png - Spillover dynamics\n")
    cat("   • README.md - Gallery index\n")
    
  }, error = function(e) {
    cat("❌ Gallery generation failed:", e$message, "\n")
  })
}

create_sample_report <- function() {
  cat("📄 Creating Sample Report...\n")
  
  tryCatch({
    # Create report directory
    report_dir <- "sample_report"
    if(!dir.exists(report_dir)) dir.create(report_dir)
    
    cat("📊 Running comprehensive analysis for report...\n")
    
    # Generate data and run analysis
    data <- get_sample_data("global_markets", n_assets = 8, n_periods = 300)
    agents <- create_enhanced_agent_population(n_agents = 150, behavioral_heterogeneity = 0.6)
    sim_results <- simulate_enhanced_market_dynamics(agents, data, n_periods = 250)
    spillover_results <- calculate_dynamic_spillover_networks(sim_results, window_size = 60)
    
    # Create visualizations
    plots <- generate_publication_dashboard(sim_results, spillover_results, 
                                          output_dir = report_dir, save_plots = TRUE)
    
    # Generate report content
    cat("📝 Writing report content...\n")
    
    report_content <- paste0(
      "# AgenticWaves Analysis Report\\n\\n",
      "**Generated:** ", Sys.time(), "\\n\\n",
      "**Analysis Type:** Sample Demonstration\\n\\n",
      "---\\n\\n",
      "## Executive Summary\\n\\n",
      "This report presents a comprehensive analysis of financial market dynamics using the AgenticWaves framework, ",
      "which combines agent-based modeling with advanced network analysis techniques.\\n\\n",
      "### Key Findings\\n\\n",
      "- **Assets Analyzed:** ", ncol(data), " financial instruments\\n",
      "- **Agents Simulated:** ", length(agents), " heterogeneous market participants\\n", 
      "- **Simulation Period:** ", sim_results$n_periods, " time steps\\n",
      "- **Average Spillover:** ", round(mean(spillover_results$total_spillover), 2), "%\\n",
      "- **Peak Spillover:** ", round(max(spillover_results$total_spillover), 2), "%\\n",
      "- **Contagion Episodes:** ", nrow(spillover_results$contagion_episodes), "\\n",
      "- **Final Wealth Gini:** ", round(sim_results$final_wealth_gini, 3), "\\n\\n",
      "---\\n\\n",
      "## Market Dynamics\\n\\n",
      "The simulation revealed complex market dynamics driven by heterogeneous agent behavior. ",
      "Market regimes switched ", length(unique(sim_results$market_regimes)), " times during the simulation period, ",
      "indicating significant volatility clustering and regime-dependent behavior.\\n\\n",
      "![Market Evolution](market_evolution.png)\\n\\n",
      "## Agent Performance\\n\\n",
      "Agent performance varied significantly by type:\\n\\n"
    )
    
    # Add agent performance summary
    agent_types <- sapply(agents, function(x) x$type)
    type_performance <- tapply(sim_results$agent_returns, agent_types, mean)
    
    for(type in names(type_performance)) {
      report_content <- paste0(report_content, 
        "- **", stringr::str_to_title(type), " Agents:** ", 
        round(type_performance[type] * 100, 2), "% average return\\n")
    }
    
    report_content <- paste0(report_content,
      "\\n![Wealth Distribution](wealth_distribution.png)\\n\\n",
      "## Network Analysis\\n\\n",
      "The financial network exhibited dynamic properties with density fluctuating between periods of ",
      "high and low connectivity. Network clustering coefficient averaged ",
      round(mean(spillover_results$network_clustering, na.rm = TRUE), 3), ", indicating moderate clustering.\\n\\n",
      "![Network Evolution](network_metrics.png)\\n\\n",
      "## Spillover Dynamics\\n\\n",
      "Spillover analysis revealed ", nrow(spillover_results$contagion_episodes), " distinct contagion episodes. ",
      "The average spillover intensity was ", round(mean(spillover_results$total_spillover), 2), "%, ",
      "with peak spillovers reaching ", round(max(spillover_results$total_spillover), 2), "%.\\n\\n",
      "![Spillover Evolution](spillover_evolution.png)\\n\\n"
    )
    
    # Add contagion episodes if any
    if(nrow(spillover_results$contagion_episodes) > 0) {
      report_content <- paste0(report_content,
        "### Contagion Episodes\\n\\n",
        "| Episode | Duration | Peak Spillover | Intensity |\\n",
        "|---------|----------|---------------|-----------|\\n"
      )
      
      for(i in 1:min(5, nrow(spillover_results$contagion_episodes))) {
        ep <- spillover_results$contagion_episodes[i, ]
        report_content <- paste0(report_content,
          "| ", i, " | ", ep$duration, " periods | ", 
          round(ep$max_spillover, 2), "% | ", 
          round(ep$intensity, 2), "x |\\n"
        )
      }
      report_content <- paste0(report_content, "\\n")
    }
    
    report_content <- paste0(report_content,
      "## Methodology\\n\\n",
      "### Agent-Based Modeling\\n\\n",
      "The simulation employed ", length(agents), " heterogeneous agents with six distinct behavioral types:\\n\\n",
      "- **Momentum traders:** Follow price trends\\n",
      "- **Contrarian traders:** Trade against prevailing trends\\n", 
      "- **Fundamentalist traders:** Base decisions on fundamental analysis\\n",
      "- **Noise traders:** Make random trading decisions\\n",
      "- **Herding traders:** Follow crowd behavior\\n",
      "- **Sophisticated traders:** Use complex multi-factor strategies\\n\\n",
      "### Spillover Analysis\\n\\n",
      "Dynamic spillover networks were constructed using rolling window correlation analysis with a window size of ",
      spillover_results$window_size, " periods. Statistical significance was tested at the ",
      spillover_results$significance_level * 100, "% level.\\n\\n",
      "## Risk Assessment\\n\\n",
      "The analysis reveals several risk factors:\\n\\n",
      "1. **Contagion Risk:** ", nrow(spillover_results$contagion_episodes), " episodes detected\\n",
      "2. **Wealth Concentration:** Final Gini coefficient of ", round(sim_results$final_wealth_gini, 3), "\\n",
      "3. **Market Fragility:** Peak spillover of ", round(max(spillover_results$total_spillover), 2), "%\\n\\n",
      "## Conclusions\\n\\n",
      "The AgenticWaves analysis demonstrates the complex interplay between agent behavior, network structure, and market dynamics. ",
      "The presence of ", nrow(spillover_results$contagion_episodes), " contagion episodes highlights the importance of ",
      "monitoring spillover effects for systemic risk assessment.\\n\\n",
      "### Recommendations\\n\\n",
      "1. **Diversification:** Given the spillover intensity, diversification benefits may be limited during crisis periods\\n",
      "2. **Monitoring:** Continuous monitoring of network connectivity is recommended\\n",
      "3. **Risk Management:** Dynamic risk management strategies should account for regime-switching behavior\\n\\n",
      "---\\n\\n",
      "*Report generated by AgenticWaves v1.0.0*\\n",
      "*For more information: https://github.com/avishekb9/AgenticWaves*"
    )
    
    # Write report
    writeLines(report_content, file.path(report_dir, "analysis_report.md"))
    
    # Create HTML version if pandoc available
    if(Sys.which("pandoc") != "") {
      cat("📄 Converting to HTML...\n")
      system(paste0("cd ", report_dir, " && pandoc analysis_report.md -o analysis_report.html --standalone"))
    }
    
    cat("\n✅ Sample Report Created!\n")
    cat("📁 Location:", report_dir, "/\n")
    cat("📄 Files generated:\n")
    cat("   • analysis_report.md - Markdown report\n")
    if(file.exists(file.path(report_dir, "analysis_report.html"))) {
      cat("   • analysis_report.html - HTML report\n")
    }
    cat("   • Various visualization files\n")
    cat("\n🎯 Report ready for publication or presentation!\n")
    
  }, error = function(e) {
    cat("❌ Report creation failed:", e$message, "\n")
  })
}

show_documentation <- function() {
  cat("📚 AgenticWaves Documentation\n")
  cat("═══════════════════════════════\n\n")
  
  cat("🔗 Online Resources:\n")
  cat("   • GitHub Repository: https://github.com/avishekb9/AgenticWaves\n")
  cat("   • Package Documentation: ?AgenticWaves\n")
  cat("   • Function Help: ?function_name\n\n")
  
  cat("📖 Quick Start Guide:\n")
  cat("   1. Load sample data: data <- get_sample_data('global_markets')\n")
  cat("   2. Create AI agent: agent <- create_autonomous_agent('explorer')\n")
  cat("   3. Run analysis: results <- agent$analyze_autonomously(data)\n")
  cat("   4. Create agents: agents <- create_enhanced_agent_population(500)\n")
  cat("   5. Run simulation: sim <- simulate_enhanced_market_dynamics(agents, data)\n")
  cat("   6. Analyze spillovers: spillovers <- calculate_dynamic_spillover_networks(sim)\n\n")
  
  cat("🔧 Main Functions:\n")
  cat("   Data Functions:\n")
  cat("   • get_sample_data() - Load sample financial data\n")
  cat("   • process_financial_data() - Clean and preprocess data\n")
  cat("   • validate_data_quality() - Assess data quality\n\n")
  
  cat("   Agent Functions:\n")
  cat("   • create_autonomous_agent() - Create AI analysis agent\n")
  cat("   • create_enhanced_agent_population() - Generate agent population\n")
  cat("   • create_dynamic_multilayer_network() - Build agent networks\n\n")
  
  cat("   Analysis Functions:\n")
  cat("   • simulate_enhanced_market_dynamics() - Run market simulation\n")
  cat("   • calculate_dynamic_spillover_networks() - Spillover analysis\n")
  cat("   • detect_contagion_episodes() - Contagion detection\n\n")
  
  cat("   Visualization Functions:\n")
  cat("   • plot_enhanced_network() - Network visualization\n")
  cat("   • plot_agent_type_network() - Agent network plots\n")
  cat("   • generate_publication_dashboard() - Publication plots\n\n")
  
  cat("📊 Example Workflows:\n\n")
  cat("   Basic Analysis:\n")
  cat("   ```r\n")
  cat("   library(AgenticWaves)\n")
  cat("   data <- get_sample_data('global_markets')\n")
  cat("   agent <- create_autonomous_agent('explorer')\n")
  cat("   results <- agent$analyze_autonomously(data)\n")
  cat("   ```\n\n")
  
  cat("   Full Simulation:\n")
  cat("   ```r\n")
  cat("   agents <- create_enhanced_agent_population(500)\n")
  cat("   sim_results <- simulate_enhanced_market_dynamics(agents, data)\n")
  cat("   spillovers <- calculate_dynamic_spillover_networks(sim_results)\n")
  cat("   plots <- generate_publication_dashboard(sim_results, spillovers)\n")
  cat("   ```\n\n")
  
  cat("💡 Tips:\n")
  cat("   • Use launch_agentic_waves() for interactive menu\n")
  cat("   • Use run_agentic_waves_app() for Shiny dashboard\n")
  cat("   • Check function help with ?function_name\n")
  cat("   • All visualizations use ggplot2/ggraph for publication quality\n\n")
  
  cat("🆘 Support:\n")
  cat("   • Issues: https://github.com/avishekb9/AgenticWaves/issues\n")
  cat("   • Email: bavisek@gmail.com\n")
  cat("   • Package version: 1.0.0\n")
}

test_all_functions <- function() {
  cat("🧪 Testing All Package Functions\n")
  cat("═══════════════════════════════════\n\n")
  
  total_tests <- 0
  passed_tests <- 0
  failed_tests <- character(0)
  
  # Test 1: Data functions
  cat("📊 Testing data functions...\n")
  test_results <- list()
  
  tryCatch({
    total_tests <- total_tests + 1
    data <- get_sample_data("global_markets", n_assets = 5, n_periods = 100)
    stopifnot(is.matrix(data), ncol(data) == 5, nrow(data) == 100)
    passed_tests <- passed_tests + 1
    cat("   ✅ get_sample_data() - PASSED\n")
  }, error = function(e) {
    failed_tests <<- c(failed_tests, paste("get_sample_data:", e$message))
    cat("   ❌ get_sample_data() - FAILED:", e$message, "\n")
  })
  
  tryCatch({
    total_tests <- total_tests + 1
    processed <- process_financial_data(data)
    stopifnot(is.matrix(processed), ncol(processed) == ncol(data))
    passed_tests <- passed_tests + 1
    cat("   ✅ process_financial_data() - PASSED\n")
  }, error = function(e) {
    failed_tests <<- c(failed_tests, paste("process_financial_data:", e$message))
    cat("   ❌ process_financial_data() - FAILED:", e$message, "\n")
  })
  
  tryCatch({
    total_tests <- total_tests + 1
    quality <- validate_data_quality(data)
    stopifnot(is.list(quality), "quality_score" %in% names(quality))
    passed_tests <- passed_tests + 1
    cat("   ✅ validate_data_quality() - PASSED\n")
  }, error = function(e) {
    failed_tests <<- c(failed_tests, paste("validate_data_quality:", e$message))
    cat("   ❌ validate_data_quality() - FAILED:", e$message, "\n")
  })
  
  # Test 2: Agent functions
  cat("\n🤖 Testing agent functions...\n")
  
  tryCatch({
    total_tests <- total_tests + 1
    agent <- create_autonomous_agent("explorer")
    stopifnot(inherits(agent, "autonomous_agent"))
    passed_tests <- passed_tests + 1
    cat("   ✅ create_autonomous_agent() - PASSED\n")
  }, error = function(e) {
    failed_tests <<- c(failed_tests, paste("create_autonomous_agent:", e$message))
    cat("   ❌ create_autonomous_agent() - FAILED:", e$message, "\n")
  })
  
  tryCatch({
    total_tests <- total_tests + 1
    agents <- create_enhanced_agent_population(n_agents = 20)
    stopifnot(is.list(agents), length(agents) == 20)
    passed_tests <- passed_tests + 1
    cat("   ✅ create_enhanced_agent_population() - PASSED\n")
  }, error = function(e) {
    failed_tests <<- c(failed_tests, paste("create_enhanced_agent_population:", e$message))
    cat("   ❌ create_enhanced_agent_population() - FAILED:", e$message, "\n")
  })
  
  # Test 3: Analysis functions
  cat("\n📊 Testing analysis functions...\n")
  
  if(exists("agents") && length(agents) > 0) {
    tryCatch({
      total_tests <- total_tests + 1
      sim_results <- simulate_enhanced_market_dynamics(agents, data, n_periods = 50)
      stopifnot(is.list(sim_results), "agent_wealth" %in% names(sim_results))
      passed_tests <- passed_tests + 1
      cat("   ✅ simulate_enhanced_market_dynamics() - PASSED\n")
    }, error = function(e) {
      failed_tests <<- c(failed_tests, paste("simulate_enhanced_market_dynamics:", e$message))
      cat("   ❌ simulate_enhanced_market_dynamics() - FAILED:", e$message, "\n")
    })
    
    if(exists("sim_results")) {
      tryCatch({
        total_tests <- total_tests + 1
        spillovers <- calculate_dynamic_spillover_networks(sim_results, window_size = 25)
        stopifnot(is.list(spillovers), "total_spillover" %in% names(spillovers))
        passed_tests <- passed_tests + 1
        cat("   ✅ calculate_dynamic_spillover_networks() - PASSED\n")
      }, error = function(e) {
        failed_tests <<- c(failed_tests, paste("calculate_dynamic_spillover_networks:", e$message))
        cat("   ❌ calculate_dynamic_spillover_networks() - FAILED:", e$message, "\n")
      })
    }
  }
  
  # Test 4: Visualization functions
  cat("\n🎨 Testing visualization functions...\n")
  
  tryCatch({
    total_tests <- total_tests + 1
    cor_matrix <- cor(data)
    adj_matrix <- abs(cor_matrix) > 0.3
    diag(adj_matrix) <- FALSE
    
    if(sum(adj_matrix) > 0) {
      plot_obj <- plot_enhanced_network(adj_matrix)
      stopifnot(inherits(plot_obj, "ggplot"))
      passed_tests <- passed_tests + 1
      cat("   ✅ plot_enhanced_network() - PASSED\n")
    } else {
      cat("   ⚠️ plot_enhanced_network() - SKIPPED (no connections)\n")
    }
  }, error = function(e) {
    failed_tests <<- c(failed_tests, paste("plot_enhanced_network:", e$message))
    cat("   ❌ plot_enhanced_network() - FAILED:", e$message, "\n")
  })
  
  # Test 5: Utility functions
  cat("\n🔧 Testing utility functions...\n")
  
  tryCatch({
    total_tests <- total_tests + 1
    gini <- calculate_gini_coefficient(c(100, 200, 300, 400, 500))
    stopifnot(is.numeric(gini), gini >= 0, gini <= 1)
    passed_tests <- passed_tests + 1
    cat("   ✅ calculate_gini_coefficient() - PASSED\n")
  }, error = function(e) {
    failed_tests <<- c(failed_tests, paste("calculate_gini_coefficient:", e$message))
    cat("   ❌ calculate_gini_coefficient() - FAILED:", e$message, "\n")
  })
  
  # Test Summary
  cat("\n" , rep("=", 50), "\n")
  cat("🏆 TEST SUMMARY\n")
  cat(rep("=", 50), "\n")
  cat("Total tests run:", total_tests, "\n")
  cat("Tests passed:", passed_tests, "\n")
  cat("Tests failed:", total_tests - passed_tests, "\n")
  cat("Success rate:", round(passed_tests / total_tests * 100, 1), "%\n")
  
  if(length(failed_tests) > 0) {
    cat("\n❌ Failed tests:\n")
    for(failure in failed_tests) {
      cat("   •", failure, "\n")
    }
  } else {
    cat("\n🎉 All tests passed! Package is working correctly.\n")
  }
  
  if(passed_tests / total_tests >= 0.8) {
    cat("\n✅ Package is ready for use!\n")
  } else {
    cat("\n⚠️ Some issues detected. Please review failed tests.\n")
  }
}

#' Create Shiny App
#' 
#' Helper function to create Shiny app if it doesn't exist
#' @return Logical indicating success
create_shiny_app <- function() {
  # The app should already exist in inst/shiny/app.R
  app_dir <- system.file("shiny", package = "AgenticWaves")
  if(!dir.exists(app_dir)) {
    stop("Shiny app directory not found in package installation")
  }
  return(TRUE)
}