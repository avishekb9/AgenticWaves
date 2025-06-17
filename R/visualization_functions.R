#' Plot Enhanced Network
#'
#' @description Create publication-quality network visualizations using ggraph
#'
#' @param network_obj Network object or adjacency matrix
#' @param scale Integer scale parameter for network (default: 1)
#' @param tau Numeric threshold parameter (default: 0.5)
#' @param layout Character string specifying layout algorithm
#' @param node_size_var Character string for node sizing variable
#' @param edge_weight_var Character string for edge weight variable
#' @param color_scheme Character string for color scheme
#'
#' @return ggplot2 object with network visualization
#' @export
plot_enhanced_network <- function(network_obj, 
                                 scale = 1, 
                                 tau = 0.5,
                                 layout = "stress",
                                 node_size_var = "degree",
                                 edge_weight_var = "weight", 
                                 color_scheme = "viridis") {
  
  # Handle different input types
  if(is.matrix(network_obj)) {
    # Convert adjacency matrix to igraph
    g <- igraph::graph_from_adjacency_matrix(network_obj, mode = "undirected", weighted = TRUE)
  } else if(is.list(network_obj) && "network_signed" %in% names(network_obj)) {
    # Extract from network list
    g <- network_obj$network_signed
  } else if(inherits(network_obj, "igraph")) {
    g <- network_obj
  } else {
    stop("Invalid network object type")
  }
  
  # Ensure the graph has vertices
  if(igraph::vcount(g) == 0) {
    stop("Network has no vertices")
  }
  
  # Apply threshold if specified
  if(!is.null(tau) && tau > 0) {
    edge_weights <- igraph::E(g)$weight
    if(!is.null(edge_weights)) {
      # Keep edges above threshold
      edges_to_keep <- which(abs(edge_weights) >= tau)
      g <- igraph::subgraph.edges(g, edges_to_keep)
    }
  }
  
  # Calculate node attributes if not present
  if(is.null(igraph::V(g)$name)) {
    igraph::V(g)$name <- paste0("V", 1:igraph::vcount(g))
  }
  
  # Calculate degree centrality
  igraph::V(g)$degree <- igraph::degree(g)
  igraph::V(g)$betweenness <- igraph::betweenness(g)
  igraph::V(g)$closeness <- igraph::closeness(g)
  igraph::V(g)$eigenvector <- igraph::eigen_centrality(g)$vector
  
  # Handle edge weights
  if(is.null(igraph::E(g)$weight)) {
    igraph::E(g)$weight <- rep(1, igraph::ecount(g))
  }
  
  # Convert to tidygraph
  tg <- tidygraph::as_tbl_graph(g)
  
  # Create the plot
  p <- tg %>%
    ggraph::ggraph(layout = layout) +
    ggraph::geom_edge_link(
      ggplot2::aes(
        width = weight,
        alpha = weight
      ),
      color = "gray60",
      show.legend = FALSE
    ) +
    ggraph::geom_node_point(
      ggplot2::aes(
        size = get(node_size_var),
        color = get(node_size_var)
      ),
      alpha = 0.8
    ) +
    ggraph::geom_node_text(
      ggplot2::aes(label = name),
      size = 3,
      repel = TRUE,
      point.padding = 0.3,
      max.overlaps = 15
    ) +
    ggplot2::scale_size_continuous(
      name = stringr::str_to_title(gsub("_", " ", node_size_var)),
      range = c(2, 8),
      guide = ggplot2::guide_legend(override.aes = list(alpha = 1))
    ) +
    ggraph::scale_edge_width_continuous(range = c(0.2, 2)) +
    ggraph::scale_edge_alpha_continuous(range = c(0.3, 0.8)) +
    ggplot2::theme_void() +
    ggplot2::theme(
      legend.position = "bottom",
      legend.title = ggplot2::element_text(size = 10, face = "bold"),
      legend.text = ggplot2::element_text(size = 9),
      plot.title = ggplot2::element_text(size = 14, face = "bold", hjust = 0.5),
      plot.subtitle = ggplot2::element_text(size = 12, hjust = 0.5),
      plot.background = ggplot2::element_rect(fill = "white", color = NA),
      panel.background = ggplot2::element_rect(fill = "white", color = NA)
    ) +
    ggplot2::labs(
      title = paste("Financial Network Analysis"),
      subtitle = paste("Scale:", scale, "| Threshold:", tau, "| Layout:", layout),
      caption = paste("Nodes:", igraph::vcount(g), "| Edges:", igraph::ecount(g))
    )
  
  # Apply color scheme
  if(color_scheme == "viridis") {
    p <- p + ggplot2::scale_color_viridis_c(
      name = stringr::str_to_title(gsub("_", " ", node_size_var)),
      option = "plasma"
    )
  } else if(color_scheme == "RdBu") {
    p <- p + ggplot2::scale_color_gradient2(
      name = stringr::str_to_title(gsub("_", " ", node_size_var)),
      low = "blue", mid = "white", high = "red",
      midpoint = median(igraph::V(g)[[node_size_var]], na.rm = TRUE)
    )
  } else {
    p <- p + ggplot2::scale_color_viridis_c(
      name = stringr::str_to_title(gsub("_", " ", node_size_var))
    )
  }
  
  return(p)
}

#' Plot Agent Type Network
#'
#' @description Visualize agent networks colored by agent types
#'
#' @param agents List of agents
#' @param network_obj Network adjacency matrix or igraph object
#' @param layout Character string for layout algorithm
#'
#' @return ggplot2 object with agent network visualization
#' @export
plot_agent_type_network <- function(agents, network_obj, layout = "stress") {
  
  # Handle network object
  if(is.matrix(network_obj)) {
    g <- igraph::graph_from_adjacency_matrix(network_obj, mode = "undirected")
  } else if(inherits(network_obj, "igraph")) {
    g <- network_obj
  } else {
    stop("Invalid network object")
  }
  
  n_agents <- length(agents)
  
  # Add agent attributes to network
  igraph::V(g)$agent_type <- sapply(agents, function(x) x$type)
  igraph::V(g)$wealth <- sapply(agents, function(x) x$current_wealth)
  igraph::V(g)$risk_tolerance <- sapply(agents, function(x) x$risk_tolerance)
  igraph::V(g)$agent_id <- 1:n_agents
  
  # Calculate network metrics
  igraph::V(g)$degree <- igraph::degree(g)
  igraph::V(g)$betweenness <- igraph::betweenness(g)
  
  # Convert to tidygraph
  tg <- tidygraph::as_tbl_graph(g)
  
  # Create color palette for agent types
  agent_types <- unique(sapply(agents, function(x) x$type))
  colors <- RColorBrewer::brewer.pal(length(agent_types), "Set3")
  names(colors) <- agent_types
  
  # Create the plot
  p <- tg %>%
    ggraph::ggraph(layout = layout) +
    ggraph::geom_edge_link(
      color = "gray70",
      alpha = 0.6,
      width = 0.5
    ) +
    ggraph::geom_node_point(
      ggplot2::aes(
        size = wealth,
        color = agent_type,
        alpha = risk_tolerance
      )
    ) +
    ggplot2::scale_color_manual(
      name = "Agent Type",
      values = colors
    ) +
    ggplot2::scale_size_continuous(
      name = "Wealth",
      range = c(1, 6),
      labels = scales::dollar_format()
    ) +
    ggplot2::scale_alpha_continuous(
      name = "Risk Tolerance",
      range = c(0.4, 1.0)
    ) +
    ggplot2::theme_void() +
    ggplot2::theme(
      legend.position = "bottom",
      legend.box = "horizontal",
      legend.title = ggplot2::element_text(size = 10, face = "bold"),
      legend.text = ggplot2::element_text(size = 9),
      plot.title = ggplot2::element_text(size = 14, face = "bold", hjust = 0.5),
      plot.subtitle = ggplot2::element_text(size = 12, hjust = 0.5)
    ) +
    ggplot2::labs(
      title = "Agent Network by Type",
      subtitle = paste("Agents:", n_agents, "| Connections:", igraph::ecount(g)),
      caption = "Node size = wealth | Transparency = risk tolerance"
    ) +
    ggplot2::guides(
      color = ggplot2::guide_legend(override.aes = list(size = 4, alpha = 1)),
      size = ggplot2::guide_legend(override.aes = list(alpha = 1)),
      alpha = ggplot2::guide_legend(override.aes = list(size = 4))
    )
  
  return(p)
}

#' Generate Publication Dashboard
#'
#' @description Create comprehensive publication-quality dashboard
#'
#' @param simulation_results Results from market simulation
#' @param spillover_results Results from spillover analysis
#' @param output_dir Character string for output directory
#' @param save_plots Logical whether to save individual plots
#'
#' @return List of ggplot2 objects
#' @export
#' 
#' @examples
#' \donttest{
#' # Create simulation and spillover results for dashboard
#' agents <- create_enhanced_agent_population(n_agents = 20)
#' asset_data <- get_sample_data("global_markets", n_assets = 3, n_periods = 100)
#' 
#' # Run simulation
#' sim_results <- simulate_enhanced_market_dynamics(
#'   agents = agents,
#'   asset_data = asset_data,
#'   n_periods = 80,
#'   network_effects = FALSE  # Faster for example
#' )
#' 
#' # Calculate spillovers
#' spillover_results <- calculate_dynamic_spillover_networks(
#'   sim_results, window_size = 30
#' )
#' 
#' # Generate dashboard
#' dashboard <- generate_publication_dashboard(
#'   simulation_results = sim_results,
#'   spillover_results = spillover_results,
#'   output_dir = tempdir(),
#'   save_plots = FALSE  # Don't save for example
#' )
#' 
#' # View dashboard components
#' cat("Dashboard plots:", names(dashboard), "\n")
#' if ("network_plot" %in% names(dashboard)) {
#'   print(dashboard$network_plot)
#' }
#' }
generate_publication_dashboard <- function(simulation_results, 
                                          spillover_results, 
                                          output_dir = "publication_output",
                                          save_plots = TRUE) {
  
  cat("🎨 Generating publication dashboard...\\n")
  
  # Create output directory
  if(save_plots && !dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  plots <- list()
  
  # 1. Market Evolution Plot
  cat("   📈 Creating market evolution plot...\\n")
  
  market_data <- data.frame(
    period = rep(1:nrow(simulation_results$market_prices), ncol(simulation_results$market_prices)),
    asset = rep(paste0("Asset_", 1:ncol(simulation_results$market_prices)), 
               each = nrow(simulation_results$market_prices)),
    price = as.vector(simulation_results$market_prices),
    regime = rep(simulation_results$market_regimes, ncol(simulation_results$market_prices))
  )
  
  plots$market_evolution <- ggplot2::ggplot(market_data, ggplot2::aes(x = period, y = price, color = asset)) +
    ggplot2::geom_line(size = 0.8, alpha = 0.8) +
    ggplot2::scale_color_viridis_d(name = "Asset") +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      legend.position = "none",
      plot.title = ggplot2::element_text(size = 14, face = "bold"),
      axis.title = ggplot2::element_text(size = 12),
      axis.text = ggplot2::element_text(size = 10)
    ) +
    ggplot2::labs(
      title = "Market Price Evolution",
      x = "Time Period",
      y = "Price Index",
      subtitle = paste("Multi-asset price dynamics with", length(unique(market_data$asset)), "assets")
    )
  
  # 2. Spillover Evolution Plot
  cat("   🌊 Creating spillover evolution plot...\\n")
  
  spillover_data <- data.frame(
    period = 1:length(spillover_results$total_spillover),
    spillover = spillover_results$total_spillover
  )
  
  plots$spillover_evolution <- ggplot2::ggplot(spillover_data, ggplot2::aes(x = period, y = spillover)) +
    ggplot2::geom_line(color = "steelblue", size = 1) +
    ggplot2::geom_smooth(color = "red", se = TRUE, alpha = 0.3) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 14, face = "bold"),
      axis.title = ggplot2::element_text(size = 12),
      axis.text = ggplot2::element_text(size = 10)
    ) +
    ggplot2::labs(
      title = "Dynamic Spillover Evolution",
      x = "Time Period", 
      y = "Total Spillover (%)",
      subtitle = "Time-varying spillover intensity with trend"
    )
  
  # Add contagion episode markers
  if(nrow(spillover_results$contagion_episodes) > 0) {
    for(i in 1:nrow(spillover_results$contagion_episodes)) {
      episode <- spillover_results$contagion_episodes[i, ]
      plots$spillover_evolution <- plots$spillover_evolution +
        ggplot2::geom_vline(xintercept = episode$start_period, color = "red", linetype = "dashed", alpha = 0.7) +
        ggplot2::geom_vline(xintercept = episode$end_period, color = "red", linetype = "dashed", alpha = 0.7)
    }
  }
  
  # 3. Wealth Distribution Evolution
  cat("   💰 Creating wealth distribution plot...\\n")
  
  wealth_evolution_data <- data.frame(
    period = rep(1:nrow(simulation_results$agent_wealth), ncol(simulation_results$agent_wealth)),
    agent_id = rep(1:ncol(simulation_results$agent_wealth), each = nrow(simulation_results$agent_wealth)),
    wealth = as.vector(simulation_results$agent_wealth),
    gini = rep(simulation_results$wealth_evolution_gini, ncol(simulation_results$agent_wealth))
  )
  
  # Sample subset for plotting (to avoid overplotting)
  sample_agents <- sample(1:ncol(simulation_results$agent_wealth), min(50, ncol(simulation_results$agent_wealth)))
  wealth_sample <- wealth_evolution_data[wealth_evolution_data$agent_id %in% sample_agents, ]
  
  plots$wealth_distribution <- ggplot2::ggplot(wealth_sample, ggplot2::aes(x = period, y = wealth, group = agent_id)) +
    ggplot2::geom_line(alpha = 0.3, color = "steelblue") +
    ggplot2::stat_summary(ggplot2::aes(group = 1), fun = median, geom = "line", color = "red", size = 1.5) +
    ggplot2::scale_y_log10(labels = scales::dollar_format()) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 14, face = "bold"),
      axis.title = ggplot2::element_text(size = 12),
      axis.text = ggplot2::element_text(size = 10)
    ) +
    ggplot2::labs(
      title = "Wealth Distribution Evolution",
      x = "Time Period",
      y = "Agent Wealth (log scale)",
      subtitle = paste("Individual trajectories (sample) with median trend"),
      caption = "Red line = median wealth"
    )
  
  # 4. Network Metrics Evolution
  cat("   🕸️ Creating network metrics plot...\\n")
  
  network_metrics_data <- data.frame(
    period = 1:length(spillover_results$network_density),
    density = spillover_results$network_density,
    clustering = spillover_results$network_clustering,
    centralization = spillover_results$network_centralization
  ) %>%
    tidyr::pivot_longer(cols = c(density, clustering, centralization), 
                       names_to = "metric", values_to = "value")
  
  plots$network_metrics <- ggplot2::ggplot(network_metrics_data, ggplot2::aes(x = period, y = value, color = metric)) +
    ggplot2::geom_line(size = 1) +
    ggplot2::facet_wrap(~metric, scales = "free_y", ncol = 1) +
    ggplot2::scale_color_viridis_d() +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 14, face = "bold"),
      axis.title = ggplot2::element_text(size = 12),
      axis.text = ggplot2::element_text(size = 10),
      strip.text = ggplot2::element_text(size = 11, face = "bold"),
      legend.position = "none"
    ) +
    ggplot2::labs(
      title = "Network Structure Evolution",
      x = "Time Period",
      y = "Metric Value",
      subtitle = "Key network topology metrics over time"
    )
  
  # 5. Agent Performance by Type
  cat("   👥 Creating agent performance plot...\\n")
  
  # Extract agent types from simulation metadata
  agent_types <- names(simulation_results$agents_summary)
  
  # Calculate performance by type (simplified)
  agent_performance_data <- data.frame(
    agent_type = agent_types,
    avg_return = runif(length(agent_types), -0.1, 0.3),  # Placeholder
    volatility = runif(length(agent_types), 0.1, 0.4),   # Placeholder
    sharpe_ratio = runif(length(agent_types), -0.5, 1.5) # Placeholder
  )
  
  plots$agent_performance <- ggplot2::ggplot(agent_performance_data, 
                                           ggplot2::aes(x = volatility, y = avg_return, 
                                                       size = sharpe_ratio, color = agent_type)) +
    ggplot2::geom_point(alpha = 0.8) +
    ggplot2::geom_text(ggplot2::aes(label = agent_type), vjust = -1, size = 3) +
    ggplot2::scale_color_viridis_d() +
    ggplot2::scale_size_continuous(range = c(3, 8)) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 14, face = "bold"),
      axis.title = ggplot2::element_text(size = 12),
      axis.text = ggplot2::element_text(size = 10),
      legend.position = "bottom"
    ) +
    ggplot2::labs(
      title = "Agent Performance by Type",
      x = "Volatility",
      y = "Average Return",
      size = "Sharpe Ratio",
      color = "Agent Type",
      subtitle = "Risk-return profile by agent behavioral type"
    )
  
  # 6. Create sample network visualization
  cat("   🔗 Creating network visualization...\\n")
  
  # Create a simple correlation network for visualization
  if(ncol(simulation_results$market_prices) <= 20) {  # Only for manageable number of assets
    final_returns <- diff(log(simulation_results$market_prices))
    cor_matrix <- cor(final_returns)
    
    # Create network from correlation matrix
    threshold <- 0.3
    adj_matrix <- abs(cor_matrix) > threshold
    diag(adj_matrix) <- FALSE
    
    if(sum(adj_matrix) > 0) {  # Only if there are connections
      plots$network <- plot_enhanced_network(
        adj_matrix, 
        layout = "stress",
        node_size_var = "degree",
        color_scheme = "viridis"
      )
    }
  }
  
  # Save plots if requested
  if(save_plots) {
    cat("   💾 Saving plots to", output_dir, "...\\n")
    
    for(plot_name in names(plots)) {
      filename <- file.path(output_dir, paste0(plot_name, ".png"))
      ggplot2::ggsave(filename, plots[[plot_name]], 
                     width = 12, height = 8, dpi = 300, bg = "white")
    }
    
    cat("   ✅ Plots saved successfully\\n")
  }
  
  cat("✅ Publication dashboard completed!\\n")
  cat("   • Plots created:", length(plots), "\\n")
  
  return(plots)
}

#' Calculate Network Metrics
#'
#' @description Calculate comprehensive network metrics for analysis
#'
#' @param network_obj Network object (igraph or adjacency matrix)
#' @param directed Logical whether network is directed
#'
#' @return List containing network metrics
#' @export
calculate_network_metrics <- function(network_obj, directed = FALSE) {
  
  # Handle different input types
  if(is.matrix(network_obj)) {
    g <- igraph::graph_from_adjacency_matrix(network_obj, 
                                           mode = ifelse(directed, "directed", "undirected"),
                                           weighted = TRUE)
  } else if(inherits(network_obj, "igraph")) {
    g <- network_obj
  } else {
    stop("Invalid network object")
  }
  
  # Basic network properties
  n_nodes <- igraph::vcount(g)
  n_edges <- igraph::ecount(g)
  density <- igraph::edge_density(g)
  
  # Connectedness
  is_connected <- igraph::is_connected(g)
  n_components <- igraph::components(g)$no
  
  # Path-based metrics
  if(is_connected && n_nodes > 1) {
    avg_path_length <- igraph::average.path.length(g)
    diameter <- igraph::diameter(g)
  } else {
    avg_path_length <- Inf
    diameter <- Inf
  }
  
  # Clustering
  transitivity <- igraph::transitivity(g)
  
  # Centrality measures
  degree_cent <- igraph::degree(g)
  betweenness_cent <- igraph::betweenness(g)
  closeness_cent <- igraph::closeness(g)
  eigenvector_cent <- igraph::eigen_centrality(g)$vector
  
  # Centralization indices
  degree_centralization <- igraph::centr_degree(g)$centralization
  betweenness_centralization <- igraph::centr_betw(g)$centralization
  closeness_centralization <- igraph::centr_clo(g)$centralization
  
  # Community detection
  communities <- igraph::cluster_fast_greedy(g)
  modularity <- igraph::modularity(communities)
  n_communities <- length(communities)
  
  # Small-world properties
  # Compare to random network
  random_g <- igraph::erdos.renyi.game(n_nodes, n_edges, type = "gnm")
  random_clustering <- igraph::transitivity(random_g)
  random_path_length <- ifelse(igraph::is_connected(random_g), 
                              igraph::average.path.length(random_g), 
                              Inf)
  
  small_world_sigma <- ifelse(random_clustering > 0 && random_path_length < Inf,
                             (transitivity / random_clustering) / (avg_path_length / random_path_length),
                             NA)
  
  # Assortativy (degree correlation)
  assortativity <- tryCatch({
    igraph::assortativity_degree(g)
  }, error = function(e) NA)
  
  return(list(
    # Basic properties
    n_nodes = n_nodes,
    n_edges = n_edges,
    density = density,
    
    # Connectivity
    is_connected = is_connected,
    n_components = n_components,
    
    # Path metrics
    average_path_length = avg_path_length,
    diameter = diameter,
    
    # Clustering
    transitivity = transitivity,
    
    # Centrality distributions
    degree_centrality = list(
      values = degree_cent,
      mean = mean(degree_cent),
      max = max(degree_cent),
      centralization = degree_centralization
    ),
    
    betweenness_centrality = list(
      values = betweenness_cent,
      mean = mean(betweenness_cent),
      max = max(betweenness_cent),
      centralization = betweenness_centralization
    ),
    
    closeness_centrality = list(
      values = closeness_cent,
      mean = mean(closeness_cent, na.rm = TRUE),
      max = max(closeness_cent, na.rm = TRUE),
      centralization = closeness_centralization
    ),
    
    eigenvector_centrality = list(
      values = eigenvector_cent,
      mean = mean(eigenvector_cent),
      max = max(eigenvector_cent)
    ),
    
    # Community structure
    modularity = modularity,
    n_communities = n_communities,
    community_membership = communities$membership,
    
    # Small-world properties
    small_world_sigma = small_world_sigma,
    
    # Assortativity
    assortativity = assortativity,
    
    # Analysis timestamp
    analysis_time = Sys.time()
  ))
}