#' AgenticWaves: Agentic AI-Powered Wavelet Financial Network Analysis
#'
#' @description
#' A revolutionary framework combining Agent-Based Modeling (ABM) with 
#' Wavelet Quantile Transfer Entropy (WaveQTE) analysis for comprehensive financial 
#' network analysis. Features autonomous AI agents, dynamic spillover detection, 
#' multi-asset analysis, and publication-quality visualizations.
#'
#' @section Main Functions:
#' 
#' **Core Analysis Functions:**
#' \itemize{
#'   \item \code{\link{create_autonomous_agent}} - Create AI analysis agent
#'   \item \code{\link{create_enhanced_agent_population}} - Generate agent population
#'   \item \code{\link{simulate_enhanced_market_dynamics}} - Run market simulation
#'   \item \code{\link{calculate_dynamic_spillover_networks}} - Spillover analysis
#'   \item \code{\link{generate_publication_dashboard}} - Create visualizations
#' }
#' 
#' **Interactive Applications:**
#' \itemize{
#'   \item \code{\link{launch_agentic_waves}} - Launch main application
#'   \item \code{\link{run_agentic_waves_app}} - Run Shiny dashboard
#' }
#' 
#' **Network Visualization:**
#' \itemize{
#'   \item \code{\link{plot_enhanced_network}} - Advanced network plots
#'   \item \code{\link{plot_agent_type_network}} - Agent network visualization
#' }
#' 
#' @section Package Features:
#' 
#' **Multi-Asset Analysis:**
#' \itemize{
#'   \item Equities (Global indices, individual stocks)
#'   \item Commodities (Energy, metals, agriculture)
#'   \item Cryptocurrencies (Bitcoin, altcoins, DeFi)
#'   \item Fixed Income (Government and corporate bonds)
#'   \item Real Estate (REITs and property indices)
#' }
#' 
#' **Autonomous AI Capabilities:**
#' \itemize{
#'   \item Self-optimizing parameter selection
#'   \item Intelligent pattern recognition
#'   \item Adaptive model configuration
#'   \item Continuous learning and improvement
#' }
#' 
#' **Agent-Based Modeling:**
#' \itemize{
#'   \item 6 heterogeneous agent types
#'   \item Realistic behavioral patterns
#'   \item Multi-layer network interactions
#'   \item Crisis-dependent behavior adaptation
#' }
#' 
#' **Dynamic Network Analysis:**
#' \itemize{
#'   \item Real-time spillover detection
#'   \item Multi-scale temporal decomposition
#'   \item Contagion episode identification
#'   \item Regime-switching dynamics
#' }
#' 
#' @section Getting Started:
#' 
#' ```r
#' # Launch the main application
#' launch_agentic_waves()
#' 
#' # Or run a quick analysis
#' library(AgenticWaves)
#' data <- get_sample_data("global_markets")
#' agent <- create_autonomous_agent()
#' results <- agent$analyze_autonomously(data)
#' ```
#' 
#' @author Avishek Bhandari
#' 
#' @references 
#' Baruník, J., & Křehlík, T. (2018). Measuring the frequency dynamics of financial connectedness and systemic risk. Journal of Financial Econometrics, 16(2), 271-296.
#' 
#' Axtell, R. L., & Farmer, J. D. (2025). Agent-based modeling in economics and finance: Past, present, and future. Journal of Economic Literature.
#' 
#' @keywords package financial-analysis agent-based-modeling network-analysis spillover-effects
#' 
#' @name AgenticWaves-package
"_PACKAGE"

# Package startup message
.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    paste0(
      "\n",
      "╔══════════════════════════════════════════════════════════════╗\n",
      "║                    🚀 AgenticWaves                         ║\n", 
      "║        Agentic AI-Powered Financial Network Analysis        ║\n",
      "║                        Version 1.0.0                       ║\n",
      "╚══════════════════════════════════════════════════════════════╝\n",
      "\n",
      "🎯 Quick Start:\n",
      "  • launch_agentic_waves()     - Launch main application\n",
      "  • run_agentic_waves_app()    - Run Shiny dashboard\n", 
      "  • ?AgenticWaves              - View package help\n",
      "\n",
      "📚 Learn more: https://github.com/avishekb9/AgenticWaves\n"
    )
  )
}

# Package environment for global variables
pkg_env <- new.env()

# Global variables to avoid R CMD check notes
utils::globalVariables(c(
  "name", "weight", "market", "agent_type", "wealth", "time", "value",
  "spillover", "regime", "centrality", "density", "clustering", "x", "y",
  "from", "to", "asset", "return", "volatility", "correlation", "network",
  "agent_id", "position", "pnl", "risk_tolerance", "trading_frequency",
  "market_type", "node_size", "edge_strength", "layout_coords", "."
))