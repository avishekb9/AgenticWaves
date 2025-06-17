# AgenticWaves Shiny Dashboard Application
# ==============================================================================

library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(DT)
library(plotly)
library(ggplot2)
library(ggraph)
library(igraph)
library(dplyr)
library(AgenticWaves)

# Define UI
ui <- dashboardPage(
  
  # Dashboard Header
  dashboardHeader(
    title = tags$div(
      tags$img(src = "https://via.placeholder.com/40x40/4CAF50/ffffff?text=AW", height = "40px"),
      "AgenticWaves",
      style = "display: flex; align-items: center; gap: 10px; font-weight: bold;"
    ),
    titleWidth = 250
  ),
  
  # Dashboard Sidebar
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      id = "sidebar",
      
      menuItem("🏠 Dashboard", tabName = "dashboard", icon = icon("tachometer-alt")),
      menuItem("📊 Data Upload", tabName = "data", icon = icon("upload")),
      menuItem("🤖 AI Analysis", tabName = "ai_analysis", icon = icon("robot")),
      menuItem("🕸️ Network Analysis", tabName = "network", icon = icon("project-diagram")),
      menuItem("👥 Agent Simulation", tabName = "agents", icon = icon("users")),
      menuItem("🌊 Spillover Analysis", tabName = "spillover", icon = icon("water")),
      menuItem("📈 Visualizations", tabName = "visuals", icon = icon("chart-line")),
      menuItem("📄 Reports", tabName = "reports", icon = icon("file-alt")),
      menuItem("⚙️ Settings", tabName = "settings", icon = icon("cog"))
    ),
    
    # Global controls
    hr(),
    h5("Global Controls", style = "padding-left: 15px; font-weight: bold;"),
    
    div(style = "padding: 0 15px;",
      selectInput("demo_data", "Sample Data:",
                 choices = list(
                   "Global Markets" = "global_markets",
                   "Cryptocurrencies" = "crypto", 
                   "Commodities" = "commodities"
                 ),
                 selected = "global_markets"),
      
      numericInput("n_assets", "Number of Assets:", 
                  value = 10, min = 3, max = 20, step = 1),
      
      numericInput("n_periods", "Time Periods:",
                  value = 500, min = 100, max = 2000, step = 100),
      
      actionButton("refresh_data", "🔄 Refresh Data", 
                  class = "btn-primary btn-sm", width = "100%")
    )
  ),
  
  # Dashboard Body
  dashboardBody(
    
    # Custom CSS
    tags$head(
      tags$style(HTML("
        .main-header .logo { font-weight: bold; }
        .content-wrapper { background-color: #f8f9fa; }
        .box { box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .nav-tabs-custom .nav-tabs li.active a { font-weight: bold; }
        .progress { margin-bottom: 10px; }
        .metric-box { 
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white; 
          padding: 20px; 
          border-radius: 10px; 
          text-align: center;
          margin-bottom: 15px;
        }
        .metric-value { font-size: 2em; font-weight: bold; }
        .metric-label { font-size: 0.9em; opacity: 0.9; }
      "))
    ),
    
    tabItems(
      
      # Dashboard Tab ====================================================
      tabItem(tabName = "dashboard",
        fluidRow(
          # Welcome Message
          box(
            title = "🚀 Welcome to AgenticWaves", 
            status = "primary", 
            solidHeader = TRUE,
            width = 12,
            height = 120,
            div(
              style = "font-size: 16px; line-height: 1.6;",
              "Autonomous AI-powered financial network analysis framework. Upload your data or use sample datasets to explore market dynamics, agent behavior, and spillover effects."
            )
          )
        ),
        
        fluidRow(
          # Key Metrics
          column(3,
            div(class = "metric-box",
              div(class = "metric-value", textOutput("total_assets")),
              div(class = "metric-label", "Total Assets")
            )
          ),
          column(3,
            div(class = "metric-box",
              div(class = "metric-value", textOutput("analysis_status")),
              div(class = "metric-label", "Analysis Status")
            )
          ),
          column(3,
            div(class = "metric-box",
              div(class = "metric-value", textOutput("network_density")),
              div(class = "metric-label", "Network Density")
            )
          ),
          column(3,
            div(class = "metric-box",
              div(class = "metric-value", textOutput("spillover_level")),
              div(class = "metric-label", "Spillover Level")
            )
          )
        ),
        
        fluidRow(
          # Quick Actions
          box(
            title = "🎯 Quick Actions", 
            status = "info", 
            solidHeader = TRUE,
            width = 4,
            actionButton("quick_analysis", "⚡ Quick Analysis", 
                        class = "btn-success btn-lg", width = "100%", 
                        style = "margin-bottom: 10px;"),
            actionButton("run_simulation", "🎬 Run Simulation", 
                        class = "btn-warning btn-lg", width = "100%",
                        style = "margin-bottom: 10px;"),
            actionButton("generate_report", "📊 Generate Report", 
                        class = "btn-info btn-lg", width = "100%")
          ),
          
          # Recent Activity
          box(
            title = "📝 Recent Activity", 
            status = "success", 
            solidHeader = TRUE,
            width = 8,
            height = 200,
            div(id = "activity_log",
              p("🔄 Application started"),
              p("📊 Sample data loaded"),
              p("⏳ Ready for analysis...")
            )
          )
        ),
        
        fluidRow(
          # Data Preview
          box(
            title = "📈 Data Preview", 
            status = "primary", 
            solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("data_preview")
          )
        )
      ),
      
      # Data Upload Tab ==============================================
      tabItem(tabName = "data",
        fluidRow(
          box(
            title = "📁 Data Source Selection", 
            status = "primary", 
            solidHeader = TRUE,
            width = 12,
            
            tabsetPanel(
              tabPanel("📄 Upload File",
                br(),
                fileInput("file_upload", "Choose CSV/Excel File:",
                         accept = c(".csv", ".xlsx", ".xls")),
                helpText("Upload financial time series data with assets as columns and time as rows."),
                
                conditionalPanel(
                  condition = "output.file_uploaded",
                  h4("File Preview:"),
                  DT::dataTableOutput("uploaded_data_preview")
                )
              ),
              
              tabPanel("🌐 Built-in Datasets",
                br(),
                h4("Sample Financial Datasets"),
                
                radioButtons("builtin_dataset", "Select Dataset:",
                           choices = list(
                             "Global Stock Markets (10 indices)" = "global_markets",
                             "Major Cryptocurrencies (10 assets)" = "crypto",
                             "Commodity Markets (10 commodities)" = "commodities",
                             "Mixed Assets (stocks, bonds, crypto)" = "mixed"
                           ),
                           selected = "global_markets"),
                
                numericInput("data_periods", "Number of Periods:", 
                           value = 1000, min = 250, max = 5000, step = 250),
                
                actionButton("load_builtin", "📊 Load Dataset", 
                           class = "btn-primary"),
                
                br(), br(),
                conditionalPanel(
                  condition = "output.builtin_loaded",
                  h4("Dataset Preview:"),
                  DT::dataTableOutput("builtin_data_preview")
                )
              ),
              
              tabPanel("🔗 API Connection",
                br(),
                h4("Connect to Financial Data APIs"),
                p("Feature coming soon: Yahoo Finance, Alpha Vantage, Quandl integration"),
                
                selectInput("api_source", "API Source:",
                          choices = list(
                            "Yahoo Finance (Coming Soon)" = "yahoo",
                            "Alpha Vantage (Coming Soon)" = "alpha",
                            "Quandl (Coming Soon)" = "quandl"
                          ),
                          selected = "yahoo"),
                
                textInput("api_symbols", "Asset Symbols (comma-separated):",
                         value = "AAPL,GOOGL,MSFT,TSLA", 
                         placeholder = "Coming soon..."),
                
                actionButton("fetch_api_data", "📡 Fetch Data (Coming Soon)", 
                           class = "btn-warning disabled", 
                           disabled = "disabled")
              )
            )
          )
        ),
        
        fluidRow(
          box(
            title = "🔍 Data Quality Assessment", 
            status = "info", 
            solidHeader = TRUE,
            width = 6,
            
            conditionalPanel(
              condition = "output.data_loaded",
              h5("Quality Metrics:"),
              verbatimTextOutput("data_quality"),
              
              h5("Summary Statistics:"),
              DT::dataTableOutput("data_summary")
            )
          ),
          
          box(
            title = "⚙️ Data Processing Options", 
            status = "warning", 
            solidHeader = TRUE,
            width = 6,
            
            checkboxInput("remove_outliers", "Remove Outliers", value = TRUE),
            checkboxInput("standardize_data", "Standardize Data", value = FALSE),
            
            numericInput("outlier_threshold", "Outlier Threshold (IQR multiplier):",
                        value = 3, min = 1, max = 5, step = 0.5),
            
            actionButton("process_data", "🔧 Process Data", 
                       class = "btn-success"),
            
            br(), br(),
            conditionalPanel(
              condition = "output.data_processed",
              h5("Processing Results:"),
              verbatimTextOutput("processing_results")
            )
          )
        )
      ),
      
      # AI Analysis Tab =============================================
      tabItem(tabName = "ai_analysis",
        fluidRow(
          box(
            title = "🤖 Autonomous AI Agent Configuration", 
            status = "primary", 
            solidHeader = TRUE,
            width = 4,
            
            selectInput("agent_type", "Agent Type:",
                       choices = list(
                         "Explorer" = "explorer",
                         "Optimizer" = "optimizer", 
                         "Predictor" = "predictor"
                       ),
                       selected = "explorer"),
            
            sliderInput("autonomy_level", "Autonomy Level:",
                       min = 1, max = 5, value = 3, step = 1),
            
            selectInput("analysis_objective", "Analysis Objective:",
                       choices = list(
                         "Exploration" = "exploration",
                         "Risk Assessment" = "risk",
                         "Pattern Detection" = "patterns",
                         "Optimization" = "optimization"
                       ),
                       selected = "exploration"),
            
            sliderInput("learning_rate", "Learning Rate:",
                       min = 0.01, max = 0.5, value = 0.1, step = 0.01),
            
            numericInput("memory_size", "Memory Size:",
                        value = 1000, min = 100, max = 5000, step = 100),
            
            actionButton("create_agent", "🧠 Create Agent", 
                       class = "btn-success btn-lg", width = "100%"),
            
            br(), br(),
            actionButton("run_autonomous_analysis", "🚀 Run Analysis", 
                       class = "btn-primary btn-lg", width = "100%")
          ),
          
          box(
            title = "📊 AI Analysis Progress", 
            status = "info", 
            solidHeader = TRUE,
            width = 8,
            
            conditionalPanel(
              condition = "output.agent_created",
              h4("Agent Status:"),
              verbatimTextOutput("agent_status"),
              
              div(id = "analysis_progress",
                h4("Analysis Progress:"),
                progressBar(id = "progress_bar", value = 0, status = "primary"),
                
                br(),
                div(id = "progress_steps",
                  p("⏳ Waiting for analysis to start...")
                )
              )
            )
          )
        ),
        
        fluidRow(
          box(
            title = "🧠 AI Insights & Recommendations", 
            status = "success", 
            solidHeader = TRUE,
            width = 12,
            
            conditionalPanel(
              condition = "output.analysis_complete",
              
              tabsetPanel(
                tabPanel("💡 Key Insights",
                  br(),
                  h4("AI-Generated Insights:"),
                  verbatimTextOutput("ai_insights"),
                  
                  h4("Pattern Recognition:"),
                  verbatimTextOutput("detected_patterns")
                ),
                
                tabPanel("📈 Performance Metrics",
                  br(),
                  h4("Analysis Performance:"),
                  DT::dataTableOutput("performance_metrics"),
                  
                  h4("Agent Learning History:"),
                  plotOutput("learning_history")
                ),
                
                tabPanel("🎯 Recommendations",
                  br(),
                  h4("AI Recommendations:"),
                  verbatimTextOutput("ai_recommendations"),
                  
                  actionButton("export_insights", "📁 Export Insights", 
                             class = "btn-info")
                )
              )
            )
          )
        )
      ),
      
      # Network Analysis Tab ========================================
      tabItem(tabName = "network",
        fluidRow(
          box(
            title = "🕸️ Network Configuration", 
            status = "primary", 
            solidHeader = TRUE,
            width = 3,
            
            selectInput("network_method", "Network Method:",
                       choices = list(
                         "Correlation" = "correlation",
                         "Partial Correlation" = "partial_correlation",
                         "Transfer Entropy" = "transfer_entropy",
                         "Granger Causality" = "granger"
                       ),
                       selected = "correlation"),
            
            sliderInput("network_threshold", "Connection Threshold:",
                       min = 0.1, max = 0.9, value = 0.3, step = 0.05),
            
            selectInput("layout_algorithm", "Layout Algorithm:",
                       choices = list(
                         "Stress" = "stress",
                         "Fruchterman-Reingold" = "fr",
                         "Kamada-Kawai" = "kk",
                         "Circle" = "circle"
                       ),
                       selected = "stress"),
            
            checkboxInput("directed_network", "Directed Network", value = FALSE),
            checkboxInput("weighted_edges", "Weighted Edges", value = TRUE),
            
            actionButton("compute_network", "🔗 Compute Network", 
                       class = "btn-primary", width = "100%"),
            
            br(), br(),
            actionButton("analyze_network", "📊 Analyze Structure", 
                       class = "btn-success", width = "100%")
          ),
          
          box(
            title = "🌐 Network Visualization", 
            status = "info", 
            solidHeader = TRUE,
            width = 9,
            height = 600,
            
            conditionalPanel(
              condition = "output.network_computed",
              plotOutput("network_plot", height = "500px")
            )
          )
        ),
        
        fluidRow(
          box(
            title = "📊 Network Metrics", 
            status = "success", 
            solidHeader = TRUE,
            width = 6,
            
            conditionalPanel(
              condition = "output.network_analyzed",
              h5("Global Metrics:"),
              DT::dataTableOutput("global_network_metrics"),
              
              h5("Node Centralities:"),
              DT::dataTableOutput("node_centralities")
            )
          ),
          
          box(
            title = "🎯 Community Detection", 
            status = "warning", 
            solidHeader = TRUE,
            width = 6,
            
            conditionalPanel(
              condition = "output.network_analyzed",
              h5("Community Structure:"),
              verbatimTextOutput("community_info"),
              
              h5("Modularity Score:"),
              verbatimTextOutput("modularity_score"),
              
              plotOutput("community_plot", height = "200px")
            )
          )
        )
      ),
      
      # Agent Simulation Tab =======================================
      tabItem(tabName = "agents",
        fluidRow(
          box(
            title = "👥 Agent Population Setup", 
            status = "primary", 
            solidHeader = TRUE,
            width = 4,
            
            numericInput("n_agents", "Number of Agents:",
                        value = 500, min = 50, max = 2000, step = 50),
            
            sliderInput("behavioral_heterogeneity", "Behavioral Heterogeneity:",
                       min = 0.1, max = 1.0, value = 0.7, step = 0.1),
            
            selectInput("wealth_distribution", "Initial Wealth Distribution:",
                       choices = list(
                         "Equal" = "equal",
                         "Normal" = "normal",
                         "Pareto (Realistic)" = "pareto"
                       ),
                       selected = "pareto"),
            
            checkboxInput("network_effects", "Include Network Effects", value = TRUE),
            
            sliderInput("network_density", "Network Density:",
                       min = 0.01, max = 0.2, value = 0.05, step = 0.01),
            
            actionButton("create_agents", "👨‍👩‍👧‍👦 Create Agents", 
                       class = "btn-success", width = "100%"),
            
            br(), br(),
            
            conditionalPanel(
              condition = "output.agents_created",
              numericInput("simulation_periods", "Simulation Periods:",
                          value = 500, min = 100, max = 2000, step = 100),
              
              actionButton("run_simulation_full", "🎬 Run Simulation", 
                         class = "btn-primary", width = "100%")
            )
          ),
          
          box(
            title = "📊 Agent Population Overview", 
            status = "info", 
            solidHeader = TRUE,
            width = 8,
            
            conditionalPanel(
              condition = "output.agents_created",
              
              tabsetPanel(
                tabPanel("📈 Population Statistics",
                  br(),
                  h5("Agent Type Distribution:"),
                  plotOutput("agent_type_distribution"),
                  
                  h5("Wealth Distribution:"),
                  plotOutput("wealth_distribution_plot")
                ),
                
                tabPanel("🕸️ Agent Network",
                  br(),
                  h5("Agent Interaction Network:"),
                  plotOutput("agent_network_plot", height = "400px")
                ),
                
                tabPanel("⚙️ Agent Properties",
                  br(),
                  h5("Agent Characteristics:"),
                  DT::dataTableOutput("agent_properties_table")
                )
              )
            )
          )
        ),
        
        fluidRow(
          box(
            title = "🎬 Simulation Results", 
            status = "success", 
            solidHeader = TRUE,
            width = 12,
            
            conditionalPanel(
              condition = "output.simulation_complete",
              
              tabsetPanel(
                tabPanel("💰 Wealth Evolution",
                  br(),
                  plotOutput("wealth_evolution_plot"),
                  
                  h5("Final Statistics:"),
                  verbatimTextOutput("simulation_summary")
                ),
                
                tabPanel("📊 Market Dynamics",
                  br(),
                  plotOutput("market_dynamics_plot"),
                  
                  h5("Regime Analysis:"),
                  verbatimTextOutput("regime_analysis")
                ),
                
                tabPanel("🏆 Agent Performance",
                  br(),
                  plotOutput("agent_performance_plot"),
                  
                  h5("Performance Rankings:"),
                  DT::dataTableOutput("performance_rankings")
                )
              )
            )
          )
        )
      ),
      
      # Spillover Analysis Tab ====================================
      tabItem(tabName = "spillover",
        fluidRow(
          box(
            title = "🌊 Spillover Analysis Configuration", 
            status = "primary", 
            solidHeader = TRUE,
            width = 4,
            
            numericInput("spillover_window", "Rolling Window Size:",
                        value = 100, min = 50, max = 300, step = 25),
            
            sliderInput("significance_level", "Significance Level:",
                       min = 0.01, max = 0.1, value = 0.05, step = 0.01),
            
            selectInput("spillover_method", "Detection Method:",
                       choices = list(
                         "Multiple Methods" = "multiple",
                         "Threshold-based" = "threshold",
                         "Regime Switching" = "regime",
                         "Correlation-based" = "correlation"
                       ),
                       selected = "multiple"),
            
            checkboxInput("include_volatility", "Include Volatility Analysis", value = TRUE),
            
            actionButton("compute_spillovers", "🌊 Compute Spillovers", 
                       class = "btn-primary", width = "100%"),
            
            br(), br(),
            actionButton("detect_contagion", "🔥 Detect Contagion", 
                       class = "btn-warning", width = "100%")
          ),
          
          box(
            title = "📈 Spillover Evolution", 
            status = "info", 
            solidHeader = TRUE,
            width = 8,
            
            conditionalPanel(
              condition = "output.spillovers_computed",
              plotOutput("spillover_evolution_plot", height = "400px"),
              
              h5("Average Total Spillover:"),
              verbatimTextOutput("avg_spillover")
            )
          )
        ),
        
        fluidRow(
          box(
            title = "🔥 Contagion Episodes", 
            status = "warning", 
            solidHeader = TRUE,
            width = 6,
            
            conditionalPanel(
              condition = "output.contagion_detected",
              h5("Detected Episodes:"),
              DT::dataTableOutput("contagion_episodes_table"),
              
              h5("Episode Characteristics:"),
              verbatimTextOutput("episode_characteristics")
            )
          ),
          
          box(
            title = "🎯 Asset Spillover Analysis", 
            status = "success", 
            solidHeader = TRUE,
            width = 6,
            
            conditionalPanel(
              condition = "output.spillovers_computed",
              h5("Directional Spillovers:"),
              DT::dataTableOutput("asset_spillover_table"),
              
              h5("Net Spillover Contributors:"),
              plotOutput("net_spillover_plot", height = "200px")
            )
          )
        ),
        
        fluidRow(
          box(
            title = "🌐 Network Evolution", 
            status = "info", 
            solidHeader = TRUE,
            width = 12,
            
            conditionalPanel(
              condition = "output.spillovers_computed",
              
              tabsetPanel(
                tabPanel("📊 Network Metrics Evolution",
                  br(),
                  plotOutput("network_evolution_plot")
                ),
                
                tabPanel("🔗 Dynamic Network",
                  br(),
                  sliderInput("network_time_slider", "Time Period:",
                             min = 1, max = 100, value = 50, step = 1,
                             animate = animationOptions(interval = 500)),
                  
                  plotOutput("dynamic_network_plot", height = "400px")
                ),
                
                tabPanel("📈 Spillover Heatmap",
                  br(),
                  plotOutput("spillover_heatmap", height = "400px")
                )
              )
            )
          )
        )
      ),
      
      # Visualizations Tab =======================================
      tabItem(tabName = "visuals",
        fluidRow(
          box(
            title = "🎨 Visualization Gallery", 
            status = "primary", 
            solidHeader = TRUE,
            width = 12,
            
            p("Create publication-quality visualizations for your analysis results."),
            
            fluidRow(
              column(6,
                h4("Available Visualizations:"),
                checkboxGroupInput("vis_selection", "",
                                 choices = list(
                                   "Network Diagram" = "network",
                                   "Spillover Evolution" = "spillover",
                                   "Agent Performance" = "agents",
                                   "Market Dynamics" = "market",
                                   "Wealth Distribution" = "wealth",
                                   "Correlation Heatmap" = "correlation"
                                 ),
                                 selected = c("network", "spillover"))
              ),
              
              column(6,
                h4("Export Options:"),
                selectInput("export_format", "Format:",
                           choices = list(
                             "PNG (High Quality)" = "png",
                             "PDF (Vector)" = "pdf",
                             "SVG (Scalable)" = "svg"
                           ),
                           selected = "png"),
                
                numericInput("export_width", "Width (inches):", 
                            value = 12, min = 6, max = 20, step = 1),
                
                numericInput("export_height", "Height (inches):", 
                            value = 8, min = 4, max = 16, step = 1),
                
                numericInput("export_dpi", "DPI (PNG only):", 
                            value = 300, min = 150, max = 600, step = 50)
              )
            ),
            
            br(),
            actionButton("generate_visuals", "🎨 Generate Visualizations", 
                       class = "btn-success btn-lg"),
            
            actionButton("export_visuals", "📁 Export All", 
                       class = "btn-info btn-lg")
          )
        ),
        
        fluidRow(
          box(
            title = "🖼️ Generated Visualizations", 
            status = "info", 
            solidHeader = TRUE,
            width = 12,
            
            conditionalPanel(
              condition = "output.visuals_generated",
              
              tabsetPanel(id = "vis_tabs",
                tabPanel("🕸️ Networks",
                  br(),
                  plotOutput("vis_network", height = "500px")
                ),
                
                tabPanel("🌊 Spillovers", 
                  br(),
                  plotOutput("vis_spillover", height = "500px")
                ),
                
                tabPanel("👥 Agents",
                  br(), 
                  plotOutput("vis_agents", height = "500px")
                ),
                
                tabPanel("📊 Markets",
                  br(),
                  plotOutput("vis_market", height = "500px")
                ),
                
                tabPanel("💰 Wealth",
                  br(),
                  plotOutput("vis_wealth", height = "500px")
                ),
                
                tabPanel("🔥 Correlations",
                  br(),
                  plotOutput("vis_correlation", height = "500px")
                )
              )
            )
          )
        )
      ),
      
      # Reports Tab ===============================================
      tabItem(tabName = "reports",
        fluidRow(
          box(
            title = "📄 Report Generation", 
            status = "primary", 
            solidHeader = TRUE,
            width = 12,
            
            h4("Generate Comprehensive Analysis Reports"),
            p("Create detailed reports combining all analysis results with executive summaries and technical details."),
            
            fluidRow(
              column(6,
                h5("Report Sections:"),
                checkboxGroupInput("report_sections", "",
                                 choices = list(
                                   "Executive Summary" = "summary",
                                   "Data Description" = "data",
                                   "Network Analysis" = "network",
                                   "Agent Simulation" = "agents", 
                                   "Spillover Analysis" = "spillover",
                                   "Visualizations" = "visuals",
                                   "Technical Appendix" = "technical"
                                 ),
                                 selected = c("summary", "data", "network", "spillover", "visuals"))
              ),
              
              column(6,
                h5("Report Options:"),
                selectInput("report_format", "Output Format:",
                           choices = list(
                             "HTML Report" = "html",
                             "PDF Report" = "pdf",
                             "Word Document" = "docx"
                           ),
                           selected = "html"),
                
                textInput("report_title", "Report Title:", 
                         value = "AgenticWaves Analysis Report"),
                
                textInput("report_author", "Author:", 
                         value = "AgenticWaves User"),
                
                checkboxInput("include_code", "Include R Code", value = FALSE),
                checkboxInput("include_raw_data", "Include Raw Data", value = FALSE)
              )
            ),
            
            br(),
            actionButton("generate_report", "📊 Generate Report", 
                       class = "btn-success btn-lg"),
            
            br(), br(),
            conditionalPanel(
              condition = "output.report_generated",
              h4("📁 Generated Reports:"),
              DT::dataTableOutput("generated_reports"),
              
              br(),
              downloadButton("download_report", "⬇️ Download Latest Report",
                           class = "btn-info btn-lg")
            )
          )
        )
      ),
      
      # Settings Tab ==============================================
      tabItem(tabName = "settings",
        fluidRow(
          box(
            title = "⚙️ Application Settings", 
            status = "primary", 
            solidHeader = TRUE,
            width = 6,
            
            h4("General Settings"),
            
            selectInput("theme", "Dashboard Theme:",
                       choices = list(
                         "Default Blue" = "blue",
                         "Green" = "green", 
                         "Purple" = "purple",
                         "Red" = "red",
                         "Yellow" = "yellow"
                       ),
                       selected = "blue"),
            
            checkboxInput("auto_refresh", "Auto-refresh Data", value = FALSE),
            
            numericInput("refresh_interval", "Refresh Interval (seconds):",
                        value = 30, min = 10, max = 300, step = 10),
            
            sliderInput("max_assets_display", "Max Assets in Visualizations:",
                       min = 5, max = 50, value = 20, step = 5),
            
            h4("Performance Settings"),
            
            numericInput("max_agents_sim", "Max Agents for Simulation:",
                        value = 1000, min = 100, max = 5000, step = 100),
            
            checkboxInput("parallel_processing", "Use Parallel Processing", value = TRUE),
            
            sliderInput("cpu_cores", "CPU Cores to Use:",
                       min = 1, max = 8, value = 2, step = 1)
          ),
          
          box(
            title = "🔧 Advanced Configuration", 
            status = "warning", 
            solidHeader = TRUE,
            width = 6,
            
            h4("Algorithm Parameters"),
            
            numericInput("default_window_size", "Default Window Size:",
                        value = 100, min = 50, max = 500, step = 25),
            
            sliderInput("default_threshold", "Default Threshold:",
                       min = 0.1, max = 0.9, value = 0.3, step = 0.05),
            
            selectInput("default_layout", "Default Network Layout:",
                       choices = list(
                         "Stress" = "stress",
                         "Fruchterman-Reingold" = "fr",
                         "Kamada-Kawai" = "kk"
                       ),
                       selected = "stress"),
            
            h4("Export Settings"),
            
            selectInput("default_export_format", "Default Export Format:",
                       choices = list("PNG" = "png", "PDF" = "pdf", "SVG" = "svg"),
                       selected = "png"),
            
            numericInput("default_dpi", "Default DPI:",
                        value = 300, min = 150, max = 600, step = 50),
            
            textInput("export_directory", "Export Directory:",
                     value = "~/AgenticWaves_exports/")
          )
        ),
        
        fluidRow(
          box(
            title = "📊 System Information", 
            status = "info", 
            solidHeader = TRUE,
            width = 6,
            
            h4("System Status:"),
            verbatimTextOutput("system_info"),
            
            h4("Package Versions:"),
            verbatimTextOutput("package_versions")
          ),
          
          box(
            title = "💾 Data Management", 
            status = "success", 
            solidHeader = TRUE,
            width = 6,
            
            h4("Session Data:"),
            actionButton("save_session", "💾 Save Session", 
                       class = "btn-success"),
            
            br(), br(),
            fileInput("load_session", "📁 Load Session:",
                     accept = ".rds"),
            
            br(),
            actionButton("clear_session", "🗑️ Clear All Data", 
                       class = "btn-danger"),
            
            br(), br(),
            h5("Cache Management:"),
            actionButton("clear_cache", "🧹 Clear Cache", 
                       class = "btn-warning")
          )
        )
      )
    )
  )
)

# Define Server Logic
server <- function(input, output, session) {
  
  # Reactive Values =============================================
  values <- reactiveValues(
    current_data = NULL,
    agent_population = NULL,
    simulation_results = NULL,
    spillover_results = NULL,
    network_results = NULL,
    ai_agent = NULL,
    analysis_results = NULL,
    generated_plots = list()
  )
  
  # Dashboard Tab Logic =====================================
  output$total_assets <- renderText({
    if(is.null(values$current_data)) "0" else ncol(values$current_data)
  })
  
  output$analysis_status <- renderText({
    if(is.null(values$analysis_results)) "Ready" else "Complete"
  })
  
  output$network_density <- renderText({
    if(is.null(values$network_results)) "N/A" else round(values$network_results$density, 3)
  })
  
  output$spillover_level <- renderText({
    if(is.null(values$spillover_results)) "N/A" 
    else paste0(round(mean(values$spillover_results$total_spillover), 1), "%")
  })
  
  # Data Preview
  output$data_preview <- DT::renderDataTable({
    if(is.null(values$current_data)) {
      data.frame(Message = "No data loaded. Please load data from the Data Upload tab.")
    } else {
      head(values$current_data, 100)
    }
  }, options = list(scrollX = TRUE, pageLength = 5))
  
  # Data Upload Tab Logic ===================================
  
  # Load built-in data
  observeEvent(input$load_builtin, {
    tryCatch({
      values$current_data <- get_sample_data(
        data_type = input$builtin_dataset,
        n_assets = input$n_assets,
        n_periods = input$data_periods
      )
      
      showNotification("✅ Built-in dataset loaded successfully!", type = "success")
    }, error = function(e) {
      showNotification(paste("❌ Error loading data:", e$message), type = "error")
    })
  })
  
  output$builtin_loaded <- reactive({
    !is.null(values$current_data)
  })
  outputOptions(output, "builtin_loaded", suspendWhenHidden = FALSE)
  
  output$builtin_data_preview <- DT::renderDataTable({
    if(!is.null(values$current_data)) {
      head(values$current_data, 50)
    }
  }, options = list(scrollX = TRUE, pageLength = 5))
  
  # Data quality assessment
  output$data_quality <- renderText({
    if(is.null(values$current_data)) {
      "No data loaded"
    } else {
      quality <- validate_data_quality(values$current_data)
      paste0(
        "Quality Score: ", quality$quality_score, "/100 (", quality$quality_level, ")\\n",
        "Observations: ", quality$n_observations, "\\n",
        "Assets: ", quality$n_assets, "\\n",
        "Missing Data: ", round(quality$missing_percentage, 2), "%\\n",
        "Avg Correlation: ", round(quality$average_correlation, 3)
      )
    }
  })
  
  # AI Analysis Tab Logic ===================================
  
  # Create AI agent
  observeEvent(input$create_agent, {
    tryCatch({
      values$ai_agent <- create_autonomous_agent(
        agent_type = input$agent_type,
        learning_rate = input$learning_rate,
        memory_size = input$memory_size
      )
      
      showNotification("🤖 AI Agent created successfully!", type = "success")
    }, error = function(e) {
      showNotification(paste("❌ Error creating agent:", e$message), type = "error")
    })
  })
  
  output$agent_created <- reactive({
    !is.null(values$ai_agent)
  })
  outputOptions(output, "agent_created", suspendWhenHidden = FALSE)
  
  output$agent_status <- renderText({
    if(is.null(values$ai_agent)) {
      "No agent created"
    } else {
      paste0(
        "Agent Type: ", values$ai_agent$agent_type, "\\n",
        "Learning Rate: ", values$ai_agent$learning_rate, "\\n",
        "Memory Usage: ", length(values$ai_agent$memory), "/", values$ai_agent$memory_size
      )
    }
  })
  
  # Run autonomous analysis
  observeEvent(input$run_autonomous_analysis, {
    if(is.null(values$current_data)) {
      showNotification("⚠️ Please load data first!", type = "warning")
      return()
    }
    
    if(is.null(values$ai_agent)) {
      showNotification("⚠️ Please create an AI agent first!", type = "warning") 
      return()
    }
    
    tryCatch({
      withProgress(message = "Running AI Analysis", value = 0, {
        incProgress(0.2, detail = "Initializing...")
        
        values$analysis_results <- values$ai_agent$analyze_autonomously(
          data = values$current_data,
          objective = input$analysis_objective,
          autonomy_level = input$autonomy_level
        )
        
        incProgress(0.8, detail = "Completing...")
      })
      
      showNotification("✅ AI Analysis completed!", type = "success")
    }, error = function(e) {
      showNotification(paste("❌ Analysis failed:", e$message), type = "error")
    })
  })
  
  output$analysis_complete <- reactive({
    !is.null(values$analysis_results)
  })
  outputOptions(output, "analysis_complete", suspendWhenHidden = FALSE)
  
  output$ai_insights <- renderText({
    if(is.null(values$analysis_results)) {
      "No analysis results available"
    } else {
      insights <- values$analysis_results$insights
      paste(names(insights), insights, sep = ": ", collapse = "\\n\\n")
    }
  })
  
  # Network Analysis Tab Logic ===============================
  
  # Compute network
  observeEvent(input$compute_network, {
    if(is.null(values$current_data)) {
      showNotification("⚠️ Please load data first!", type = "warning")
      return()
    }
    
    tryCatch({
      # Simple correlation-based network
      cor_matrix <- cor(values$current_data, use = "complete.obs")
      
      # Apply threshold
      adj_matrix <- abs(cor_matrix) > input$network_threshold
      diag(adj_matrix) <- FALSE
      
      # Create igraph object
      g <- igraph::graph_from_adjacency_matrix(adj_matrix, mode = "undirected")
      
      values$network_results <- list(
        graph = g,
        adjacency_matrix = adj_matrix,
        correlation_matrix = cor_matrix,
        threshold = input$network_threshold,
        density = igraph::edge_density(g)
      )
      
      showNotification("✅ Network computed successfully!", type = "success")
    }, error = function(e) {
      showNotification(paste("❌ Network computation failed:", e$message), type = "error")
    })
  })
  
  output$network_computed <- reactive({
    !is.null(values$network_results)
  })
  outputOptions(output, "network_computed", suspendWhenHidden = FALSE)
  
  output$network_plot <- renderPlot({
    if(is.null(values$network_results)) return(NULL)
    
    plot_enhanced_network(
      values$network_results$graph,
      layout = input$layout_algorithm,
      node_size_var = "degree"
    )
  })
  
  # Agent Simulation Tab Logic ===============================
  
  # Create agents
  observeEvent(input$create_agents, {
    tryCatch({
      values$agent_population <- create_enhanced_agent_population(
        n_agents = input$n_agents,
        behavioral_heterogeneity = input$behavioral_heterogeneity,
        wealth_distribution = input$wealth_distribution
      )
      
      showNotification("👥 Agent population created!", type = "success")
    }, error = function(e) {
      showNotification(paste("❌ Agent creation failed:", e$message), type = "error")
    })
  })
  
  output$agents_created <- reactive({
    !is.null(values$agent_population)
  })
  outputOptions(output, "agents_created", suspendWhenHidden = FALSE)
  
  # System Information in Settings =========================
  output$system_info <- renderText({
    paste0(
      "R Version: ", R.version.string, "\\n",
      "Platform: ", .Platform$OS.type, "\\n",
      "CPU Cores: ", parallel::detectCores(), "\\n",
      "AgenticWaves Version: 1.0.0"
    )
  })
  
  # Initialize with sample data on startup
  observe({
    if(is.null(values$current_data)) {
      values$current_data <- get_sample_data("global_markets", n_assets = 10, n_periods = 500)
    }
  })
}

# Run the application
shinyApp(ui = ui, server = server)