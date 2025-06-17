# AgenticWaves

[![R Package](https://img.shields.io/badge/R-Package-blue.svg)](https://github.com/avishekb9/AgenticWaves)
[![Version](https://img.shields.io/badge/version-1.0.0-brightgreen.svg)](https://github.com/avishekb9/AgenticWaves)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

> **Agentic AI-Powered Wavelet Financial Network Analysis**

A revolutionary framework combining Agent-Based Modeling (ABM) with Wavelet Quantile Transfer Entropy (WaveQTE) analysis for comprehensive financial network analysis. Features autonomous AI agents, dynamic spillover detection, multi-asset analysis, and publication-quality visualizations.

## 🚀 Features

### 🤖 Autonomous AI Capabilities
- **Self-optimizing AI agents** with adaptive parameter selection
- **Intelligent pattern recognition** and insight generation
- **Continuous learning** and performance improvement
- **Multi-objective analysis** (exploration, optimization, prediction)

### 👥 Agent-Based Modeling
- **6 heterogeneous agent types** with realistic behavioral patterns
- **Multi-layer network interactions** and social influence
- **Crisis-dependent behavior adaptation**
- **Wealth distribution dynamics** with inequality analysis

### 🌊 Dynamic Network Analysis
- **Real-time spillover detection** across multiple time scales
- **Contagion episode identification** with consensus algorithms
- **Regime-switching dynamics** and structural break detection
- **Multi-scale temporal decomposition**

### 📊 Multi-Asset Support
- **Equities**: Global indices, individual stocks
- **Commodities**: Energy, metals, agriculture
- **Cryptocurrencies**: Bitcoin, altcoins, DeFi tokens
- **Fixed Income**: Government and corporate bonds
- **Real Estate**: REITs and property indices

### 🎨 Publication-Quality Visualizations
- **ggraph-based network plots** with professional styling
- **Interactive dashboards** with real-time updates
- **Comprehensive reporting** with automated insights
- **Customizable themes** and export options

## 📦 Installation

### Quick Install

```r
# Install from source
source("install.R")

# Or using devtools
devtools::install()
```

### Manual Installation

```r
# Install dependencies
install.packages(c(
  "shiny", "shinydashboard", "ggplot2", "ggraph", "igraph", 
  "dplyr", "R6", "viridis", "DT", "plotly"
))

# Install package
devtools::install_local("AgenticWaves")
```

## 🎯 Quick Start

### Interactive Launcher
```r
library(AgenticWaves)

# Launch interactive menu
launch_agentic_waves()

# Or launch Shiny dashboard directly
run_agentic_waves_app()
```

### Basic Analysis
```r
# Load sample data
data <- get_sample_data("global_markets")

# Create autonomous AI agent
agent <- create_autonomous_agent("explorer")

# Run autonomous analysis
results <- agent$analyze_autonomously(data)

# View insights
results$insights
```

### Full Simulation
```r
# Create agent population
agents <- create_enhanced_agent_population(
  n_agents = 500,
  behavioral_heterogeneity = 0.7
)

# Run market simulation
sim_results <- simulate_enhanced_market_dynamics(
  agents = agents,
  asset_data = data,
  n_periods = 1000
)

# Analyze spillovers
spillover_results <- calculate_dynamic_spillover_networks(
  sim_results,
  window_size = 100
)

# Generate publication dashboard
plots <- generate_publication_dashboard(
  sim_results, 
  spillover_results,
  save_plots = TRUE
)
```

## 🔬 Core Components

### Agent Types
- **Momentum Traders**: Follow price trends and market momentum
- **Contrarian Traders**: Trade against prevailing market trends  
- **Fundamentalist Traders**: Base decisions on fundamental analysis
- **Noise Traders**: Make random or irrational trading decisions
- **Herding Traders**: Follow crowd behavior and social signals
- **Sophisticated Traders**: Use complex multi-factor strategies

### Analysis Methods
- **Wavelet Decomposition**: Multi-scale temporal analysis
- **Quantile Transfer Entropy**: Tail-dependent spillover detection
- **Network Metrics**: Centrality, clustering, modularity analysis
- **Contagion Detection**: Multiple consensus methodologies
- **Regime Identification**: Structural break and changepoint detection

### Visualization Suite
- **Network Diagrams**: Professional ggraph-based layouts
- **Spillover Heatmaps**: Time-varying connectivity matrices
- **Agent Performance**: Risk-return scatter plots by type
- **Market Dynamics**: Multi-asset price and volatility evolution
- **Wealth Distribution**: Inequality evolution over time

## 📱 Interactive Dashboard

The Shiny dashboard provides a comprehensive interface for:

- **Data Upload**: CSV/Excel files or built-in datasets
- **AI Analysis**: Autonomous agent configuration and execution
- **Network Analysis**: Interactive network visualization and metrics
- **Agent Simulation**: Population setup and market dynamics
- **Spillover Analysis**: Real-time spillover and contagion detection
- **Visualization Gallery**: Publication-quality plot generation
- **Report Generation**: Automated comprehensive reports

## 🧪 Testing

```r
# Run comprehensive tests
test_all_functions()

# Or use testthat
devtools::test()
```

## 📚 Documentation

### Function Help
```r
?AgenticWaves              # Package overview
?create_autonomous_agent   # AI agent creation
?simulate_enhanced_market_dynamics  # Market simulation
?calculate_dynamic_spillover_networks  # Spillover analysis
```

### Vignettes
- **Getting Started**: Basic usage and examples
- **Agent-Based Modeling**: Detailed ABM methodology
- **Network Analysis**: Spillover and contagion detection
- **Visualization Guide**: Creating publication-quality plots

## 🔧 Advanced Usage

### Custom Data Analysis
```r
# Load your own data
data <- read.csv("your_data.csv")
processed_data <- process_financial_data(data)

# Validate data quality
quality <- validate_data_quality(processed_data)
print(quality)

# Run analysis
agent <- create_autonomous_agent("optimizer")
results <- agent$analyze_autonomously(processed_data)
```

### Network Customization
```r
# Create custom network
network <- create_dynamic_multilayer_network(
  agents,
  network_types = c("trading", "information", "social"),
  density = 0.1
)

# Analyze network properties
metrics <- calculate_network_metrics(network$networks$trading$graph)
```

### Visualization Customization
```r
# Custom network plot
plot <- plot_enhanced_network(
  network_obj,
  layout = "stress",
  node_size_var = "betweenness",
  color_scheme = "viridis"
)

# Save high-resolution plot
ggsave("network.png", plot, width = 12, height = 8, dpi = 300)
```

## 🎨 Example Gallery

The package includes comprehensive examples:

```r
# Generate visualization gallery
generate_visualization_gallery()

# Create sample report
create_sample_report()

# Run complete demo
run_complete_demo()
```

## 📊 Research Applications

AgenticWaves is designed for:

- **Systemic Risk Analysis**: Financial contagion and spillover effects
- **Market Microstructure**: Agent behavior and market dynamics
- **Portfolio Management**: Dynamic risk assessment and optimization
- **Regulatory Analysis**: Market stability and intervention effects
- **Academic Research**: Publication-ready analysis and visualizations

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup
```r
# Clone repository
git clone https://github.com/avishekb9/AgenticWaves.git

# Install development dependencies
devtools::install_dev_deps()

# Run tests
devtools::test()

# Build documentation
devtools::document()
```

## 📄 Citation

If you use AgenticWaves in your research, please cite:

```bibtex
@software{agenticwaves2025,
  title = {AgenticWaves: Agentic AI-Powered Wavelet Financial Network Analysis},
  author = {Bhandari, Avishek},
  year = {2025},
  url = {https://github.com/avishekb9/AgenticWaves},
  version = {1.0.0}
}
```

## 📧 Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/avishekb9/AgenticWaves/issues)
- **Email**: bavisek@gmail.com
- **Documentation**: [Package documentation](https://avishekb9.github.io/AgenticWaves/)

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Agent-Based Modeling**: Inspired by research in computational economics
- **Network Analysis**: Built on advances in financial network theory
- **Visualization**: Leverages the powerful ggraph/igraph ecosystem
- **AI Agents**: Incorporates modern autonomous system design principles

---

**AgenticWaves**: *Revolutionizing financial network analysis through autonomous AI*

[![GitHub](https://img.shields.io/github/stars/avishekb9/AgenticWaves?style=social)](https://github.com/avishekb9/AgenticWaves)