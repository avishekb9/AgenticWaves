#' Simulate Enhanced Market Dynamics
#'
#' @description Run comprehensive market simulation with agent interactions
#'
#' @param agents List of agents from create_enhanced_agent_population
#' @param asset_data Matrix of asset return data
#' @param n_periods Integer number of simulation periods
#' @param network_effects Logical whether to include network effects
#'
#' @return List containing simulation results
#' @export
#' 
#' @examples
#' \donttest{
#' # Create sample agents and data
#' agents <- create_enhanced_agent_population(n_agents = 50)
#' asset_data <- get_sample_data("global_markets", n_assets = 5, n_periods = 100)
#' 
#' # Run short simulation
#' sim_results <- simulate_enhanced_market_dynamics(
#'   agents = agents,
#'   asset_data = asset_data,
#'   n_periods = 50,
#'   network_effects = TRUE
#' )
#' 
#' # Examine results
#' cat("Simulation completed with", sim_results$n_agents, "agents\n")
#' cat("Final wealth Gini:", round(sim_results$final_wealth_gini, 3), "\n")
#' cat("Average agent return:", round(mean(sim_results$agent_returns) * 100, 2), "%\n")
#' }
simulate_enhanced_market_dynamics <- function(agents, asset_data, n_periods = 500, network_effects = TRUE) {
  
  n_agents <- length(agents)
  n_assets <- ncol(asset_data)
  
  cat("🎬 Starting market simulation...\\n")
  cat("   • Agents:", n_agents, "\\n")
  cat("   • Assets:", n_assets, "\\n") 
  cat("   • Periods:", n_periods, "\\n")
  
  # Initialize tracking arrays
  agent_wealth <- matrix(0, n_periods, n_agents)
  agent_positions <- array(0, dim = c(n_periods, n_agents, n_assets))
  market_prices <- matrix(0, n_periods, n_assets)
  trading_volumes <- matrix(0, n_periods, n_assets)
  market_regimes <- numeric(n_periods)
  
  # Initialize starting values
  agent_wealth[1, ] <- sapply(agents, function(x) x$current_wealth)
  market_prices[1, ] <- rep(100, n_assets)  # Starting price index
  
  # Create network for information flow (if network effects enabled)
  if(network_effects && n_agents > 10) {
    network <- create_dynamic_multilayer_network(agents, density = 0.05)
    info_network <- network$networks$information$adjacency_matrix
  } else {
    info_network <- NULL
  }
  
  # Market-level variables
  market_sentiment <- 0.5
  volatility_regime <- 1  # 1 = low, 2 = medium, 3 = high
  crisis_probability <- 0.02
  
  # Main simulation loop
  for(t in 2:n_periods) {
    if(t %% 50 == 0) cat("   ⏱️ Period", t, "/", n_periods, "\\n")
    
    # Update market regime
    if(runif(1) < crisis_probability) {
      volatility_regime <- 3  # Crisis
      market_sentiment <- pmax(0.1, market_sentiment - 0.3)
    } else if(volatility_regime == 3 && runif(1) < 0.3) {
      volatility_regime <- 2  # Recovery
      market_sentiment <- pmin(0.9, market_sentiment + 0.2)
    } else if(runif(1) < 0.05) {
      volatility_regime <- sample(1:2, 1)  # Normal regime switching
      market_sentiment <- market_sentiment + runif(1, -0.1, 0.1)
    }
    
    market_regimes[t] <- volatility_regime
    market_sentiment <- pmax(0.1, pmin(0.9, market_sentiment))
    
    # Generate asset returns for this period
    base_returns <- asset_data[min(t, nrow(asset_data)), ]
    
    # Adjust returns based on regime
    regime_multiplier <- switch(volatility_regime,
      "1" = 0.8,    # Low volatility
      "2" = 1.0,    # Normal
      "3" = 2.5     # High volatility/crisis
    )
    
    period_returns <- base_returns * regime_multiplier + rnorm(n_assets, 0, 0.001)
    
    # Calculate market signals
    market_signals <- list()
    for(i in 1:n_assets) {
      # Price momentum (last 10 periods)
      start_idx <- max(1, t - 10)
      momentum <- ifelse(t > 10, 
                        mean(diff(market_prices[start_idx:(t-1), i])), 
                        0)
      
      # Volatility signal
      volatility <- ifelse(t > 5,
                          sd(market_prices[max(1, t-5):(t-1), i]),
                          0.1)
      
      market_signals[[i]] <- list(
        momentum = momentum,
        volatility = volatility,
        sentiment = market_sentiment,
        regime = volatility_regime
      )
    }
    
    # Agent decision making
    total_demand <- rep(0, n_assets)
    
    for(agent_id in 1:n_agents) {
      agent <- agents[[agent_id]]
      
      # Get agent's current state
      current_wealth <- agent_wealth[t-1, agent_id]
      current_positions <- agent_positions[t-1, agent_id, ]
      
      # Agent information processing
      agent_signals <- market_signals
      
      # Add noise based on agent sophistication
      noise_level <- 1 - agent$noise_tolerance
      for(i in 1:n_assets) {
        agent_signals[[i]]$momentum <- agent_signals[[i]]$momentum + 
          rnorm(1, 0, noise_level * 0.01)
        agent_signals[[i]]$sentiment <- agent_signals[[i]]$sentiment + 
          rnorm(1, 0, noise_level * 0.1)
      }
      
      # Network information sharing
      if(!is.null(info_network) && any(info_network[agent_id, ] > 0)) {
        connected_agents <- which(info_network[agent_id, ] > 0)
        if(length(connected_agents) > 0) {
          # Average signals from connected agents (simplified)
          for(i in 1:n_assets) {
            avg_sentiment <- mean(sapply(connected_agents, function(j) {
              agents[[j]]$social_influence * market_sentiment + 
                (1 - agents[[j]]$social_influence) * 0.5
            }))
            agent_signals[[i]]$sentiment <- 0.7 * agent_signals[[i]]$sentiment + 
                                           0.3 * avg_sentiment
          }
        }
      }
      
      # Agent-specific decision making
      new_positions <- rep(0, n_assets)
      
      for(i in 1:n_assets) {
        signal <- agent_signals[[i]]
        
        # Calculate desired position based on agent type
        if(agent$type == "momentum") {
          position_signal <- agent$trend_sensitivity * signal$momentum
        } else if(agent$type == "contrarian") {
          position_signal <- -agent$trend_sensitivity * signal$momentum
        } else if(agent$type == "fundamentalist") {
          # Mean reversion toward expected value
          expected_return <- 0.001  # Long-term expected return
          position_signal <- (expected_return - period_returns[i]) * agent$trend_sensitivity
        } else if(agent$type == "noise") {
          position_signal <- rnorm(1, 0, 0.1)
        } else if(agent$type == "herding") {
          # Follow market sentiment
          position_signal <- (signal$sentiment - 0.5) * 2 * agent$trend_sensitivity
        } else if(agent$type == "sophisticated") {
          # Combine multiple signals
          momentum_signal <- agent$trend_sensitivity * signal$momentum
          sentiment_signal <- (signal$sentiment - 0.5) * 0.5
          volatility_signal <- -signal$volatility * 0.1  # Lower position in high vol
          position_signal <- momentum_signal + sentiment_signal + volatility_signal
        } else {
          position_signal <- 0
        }
        
        # Apply risk tolerance and wealth constraints
        max_position <- current_wealth * agent$risk_tolerance / n_assets / market_prices[t-1, i]
        desired_position <- position_signal * max_position
        
        # Apply trading frequency (probability of actually trading)
        if(runif(1) < agent$trading_frequency) {
          new_positions[i] <- pmax(-max_position, pmin(max_position, desired_position))
        } else {
          new_positions[i] <- current_positions[i]  # Hold current position
        }
      }
      
      # Update agent positions
      agent_positions[t, agent_id, ] <- new_positions
      
      # Calculate demand contribution
      position_change <- new_positions - current_positions
      total_demand <- total_demand + position_change
    }
    
    # Update market prices based on supply/demand
    price_impact <- total_demand / (n_agents * 100)  # Scale factor
    market_prices[t, ] <- market_prices[t-1, ] * (1 + period_returns + price_impact * 0.1)
    
    # Calculate trading volumes
    trading_volumes[t, ] <- abs(total_demand)
    
    # Update agent wealth
    for(agent_id in 1:n_agents) {
      position_value <- sum(agent_positions[t, agent_id, ] * market_prices[t, ])
      cash_change <- sum((agent_positions[t-1, agent_id, ] - agent_positions[t, agent_id, ]) * 
                        market_prices[t, ])
      
      # Apply transaction costs
      transaction_cost <- sum(abs(agent_positions[t, agent_id, ] - agent_positions[t-1, agent_id, ])) * 
                         agents[[agent_id]]$transaction_costs * market_prices[t, ]
      
      agent_wealth[t, agent_id] <- position_value + 
        (agent_wealth[t-1, agent_id] - sum(agent_positions[t-1, agent_id, ] * market_prices[t-1, ])) +
        cash_change - sum(transaction_cost)
    }
  }
  
  # Calculate final statistics
  final_wealth_gini <- calculate_gini_coefficient(agent_wealth[n_periods, ])
  wealth_evolution_gini <- apply(agent_wealth, 1, calculate_gini_coefficient)
  
  # Performance metrics
  agent_returns <- (agent_wealth[n_periods, ] - agent_wealth[1, ]) / agent_wealth[1, ]
  market_returns <- (market_prices[n_periods, ] - market_prices[1, ]) / market_prices[1, ]
  
  cat("✅ Simulation completed!\\n")
  cat("   • Final wealth Gini:", round(final_wealth_gini, 3), "\\n")
  cat("   • Average agent return:", round(mean(agent_returns) * 100, 2), "%\\n")
  cat("   • Average market return:", round(mean(market_returns) * 100, 2), "%\\n")
  
  return(list(
    agent_wealth = agent_wealth,
    agent_positions = agent_positions,
    market_prices = market_prices,
    trading_volumes = trading_volumes,
    market_regimes = market_regimes,
    market_sentiment_evolution = market_sentiment,
    
    # Summary statistics
    final_wealth_gini = final_wealth_gini,
    wealth_evolution_gini = wealth_evolution_gini,
    agent_returns = agent_returns,
    market_returns = market_returns,
    
    # Simulation parameters
    n_agents = n_agents,
    n_assets = n_assets,
    n_periods = n_periods,
    network_effects = network_effects,
    
    # Metadata
    simulation_time = Sys.time(),
    agents_summary = table(sapply(agents, function(x) x$type))
  ))
}

#' Calculate Dynamic Spillover Networks
#'
#' @description Calculate time-varying spillover networks and detect contagion episodes
#'
#' @param simulation_results Results from simulate_enhanced_market_dynamics
#' @param window_size Integer size of rolling window for spillover calculation
#' @param significance_level Numeric significance level for spillover detection
#'
#' @return List containing spillover analysis results
#' @export
#' 
#' @examples
#' \donttest{
#' # Create simulation first
#' agents <- create_enhanced_agent_population(n_agents = 30)
#' asset_data <- get_sample_data("global_markets", n_assets = 4, n_periods = 200)
#' 
#' sim_results <- simulate_enhanced_market_dynamics(
#'   agents = agents,
#'   asset_data = asset_data,
#'   n_periods = 150,
#'   network_effects = FALSE  # Faster for example
#' )
#' 
#' # Calculate spillover networks
#' spillover_results <- calculate_dynamic_spillover_networks(
#'   simulation_results = sim_results,
#'   window_size = 50,
#'   significance_level = 0.05
#' )
#' 
#' # Examine spillover results
#' cat("Average spillover:", round(mean(spillover_results$total_spillover), 2), "%\n")
#' cat("Contagion episodes:", nrow(spillover_results$contagion_episodes), "\n")
#' cat("Peak spillover:", round(max(spillover_results$total_spillover), 2), "%\n")
#' }
calculate_dynamic_spillover_networks <- function(simulation_results, window_size = 100, significance_level = 0.05) {
  
  cat("🌊 Calculating dynamic spillover networks...\\n")
  
  # Extract price data
  prices <- simulation_results$market_prices
  n_periods <- nrow(prices)
  n_assets <- ncol(prices)
  
  # Calculate returns
  returns <- diff(log(prices))
  
  # Rolling window spillover calculation
  n_windows <- n_periods - window_size
  spillover_evolution <- matrix(0, n_windows, n_assets^2)
  total_spillover <- numeric(n_windows)
  directional_spillovers <- array(0, dim = c(n_windows, n_assets, 2))  # from, to
  
  # Network metrics evolution
  network_density <- numeric(n_windows)
  network_clustering <- numeric(n_windows)
  network_centralization <- numeric(n_windows)
  
  cat("   📊 Processing", n_windows, "rolling windows...\\n")
  
  for(w in 1:n_windows) {
    if(w %% 20 == 0) cat("      Window", w, "/", n_windows, "\\n")
    
    # Extract window data
    window_data <- returns[w:(w + window_size - 1), ]
    
    # Calculate correlation matrix
    cor_matrix <- cor(window_data, use = "complete.obs")
    
    # Convert correlations to spillover measures
    # Using absolute correlations as proxy for spillover strength
    spillover_matrix <- abs(cor_matrix)
    diag(spillover_matrix) <- 0  # Remove self-spillovers
    
    # Apply significance threshold
    # Simulate p-values (in real implementation, use proper statistical tests)
    cor_test_stats <- abs(cor_matrix) * sqrt((window_size - 2) / (1 - cor_matrix^2))
    p_values <- 2 * (1 - pt(cor_test_stats, window_size - 2))
    
    # Keep only significant spillovers
    spillover_matrix[p_values > significance_level] <- 0
    
    # Calculate spillover indices
    row_sums <- rowSums(spillover_matrix)
    col_sums <- colSums(spillover_matrix)
    total_sum <- sum(spillover_matrix)
    
    total_spillover[w] <- total_sum / (n_assets * (n_assets - 1)) * 100
    
    # Directional spillovers
    directional_spillovers[w, , 1] <- row_sums  # Spillovers TO others
    directional_spillovers[w, , 2] <- col_sums  # Spillovers FROM others
    
    # Store vectorized spillover matrix
    spillover_evolution[w, ] <- as.vector(spillover_matrix)
    
    # Calculate network metrics
    spillover_graph <- igraph::graph_from_adjacency_matrix(spillover_matrix, 
                                                          mode = "directed", 
                                                          weighted = TRUE)
    
    network_density[w] <- igraph::edge_density(spillover_graph)
    network_clustering[w] <- igraph::transitivity(spillover_graph)
    network_centralization[w] <- igraph::centr_betw(spillover_graph)$centralization
  }
  
  # Detect contagion episodes
  cat("   🔥 Detecting contagion episodes...\\n")
  
  # Define contagion as periods with unusually high spillovers
  spillover_threshold <- quantile(total_spillover, 0.9)
  contagion_periods <- which(total_spillover > spillover_threshold)
  
  # Group consecutive periods into episodes
  contagion_episodes <- data.frame()
  if(length(contagion_periods) > 0) {
    episode_starts <- c(contagion_periods[1], 
                       contagion_periods[which(diff(contagion_periods) > 1) + 1])
    episode_ends <- c(contagion_periods[which(diff(contagion_periods) > 1)],
                     contagion_periods[length(contagion_periods)])
    
    for(i in 1:length(episode_starts)) {
      episode_periods <- episode_starts[i]:episode_ends[i]
      max_spillover <- max(total_spillover[episode_periods])
      avg_spillover <- mean(total_spillover[episode_periods])
      
      contagion_episodes <- rbind(contagion_episodes, data.frame(
        episode = i,
        start_period = episode_starts[i],
        end_period = episode_ends[i],
        duration = episode_ends[i] - episode_starts[i] + 1,
        max_spillover = max_spillover,
        avg_spillover = avg_spillover,
        intensity = max_spillover / mean(total_spillover)
      ))
    }
  }
  
  # Calculate asset-level spillover statistics
  asset_spillover_stats <- data.frame(
    asset = 1:n_assets,
    avg_spillover_to = apply(directional_spillovers[, , 1], 2, mean),
    avg_spillover_from = apply(directional_spillovers[, , 2], 2, mean),
    max_spillover_to = apply(directional_spillovers[, , 1], 2, max),
    max_spillover_from = apply(directional_spillovers[, , 2], 2, max),
    spillover_volatility = apply(directional_spillovers[, , 1] + directional_spillovers[, , 2], 2, sd)
  )
  
  # Net spillover contributors vs receivers
  asset_spillover_stats$net_spillover <- asset_spillover_stats$avg_spillover_to - 
                                        asset_spillover_stats$avg_spillover_from
  
  # Time-varying network structure analysis
  structural_breaks <- detect_structural_breaks(network_density, network_clustering)
  
  cat("✅ Spillover analysis completed!\\n")
  cat("   • Average total spillover:", round(mean(total_spillover), 2), "%\\n")
  cat("   • Contagion episodes detected:", nrow(contagion_episodes), "\\n")
  cat("   • Peak spillover:", round(max(total_spillover), 2), "%\\n")
  
  return(list(
    # Main results
    total_spillover = total_spillover,
    spillover_evolution = spillover_evolution,
    directional_spillovers = directional_spillovers,
    
    # Network metrics
    network_density = network_density,
    network_clustering = network_clustering,
    network_centralization = network_centralization,
    
    # Episodes and events
    contagion_episodes = contagion_episodes,
    structural_breaks = structural_breaks,
    spillover_threshold = spillover_threshold,
    
    # Asset-level analysis
    asset_spillover_stats = asset_spillover_stats,
    
    # Parameters and metadata
    window_size = window_size,
    significance_level = significance_level,
    n_windows = n_windows,
    analysis_time = Sys.time()
  ))
}

#' Detect Contagion Episodes
#'
#' @description Advanced contagion detection using multiple methodologies
#'
#' @param spillover_results Results from calculate_dynamic_spillover_networks
#' @param market_data Optional market data for additional context
#' @param detection_methods Character vector of detection methods to use
#'
#' @return List containing detailed contagion analysis
#' @export
#' 
#' @examples
#' \donttest{
#' # Build up from previous examples
#' agents <- create_enhanced_agent_population(n_agents = 25)
#' asset_data <- get_sample_data("global_markets", n_assets = 3, n_periods = 150)
#' 
#' # Run simulation
#' sim_results <- simulate_enhanced_market_dynamics(
#'   agents = agents,
#'   asset_data = asset_data,
#'   n_periods = 100,
#'   network_effects = FALSE
#' )
#' 
#' # Calculate spillovers
#' spillover_results <- calculate_dynamic_spillover_networks(
#'   sim_results, window_size = 40, significance_level = 0.1
#' )
#' 
#' # Detect contagion episodes
#' contagion_analysis <- detect_contagion_episodes(
#'   spillover_results = spillover_results,
#'   market_data = sim_results$market_prices,
#'   detection_methods = c("threshold", "correlation")
#' )
#' 
#' # View results
#' cat("Consensus episodes:", length(contagion_analysis$consensus_episodes), "\n")
#' cat("Detection methods:", paste(contagion_analysis$detection_methods, collapse = ", "), "\n")
#' }
detect_contagion_episodes <- function(spillover_results, 
                                     market_data = NULL,
                                     detection_methods = c("threshold", "regime", "correlation", "volatility")) {
  
  cat("🔍 Advanced contagion detection using", length(detection_methods), "methods...\\n")
  
  total_spillover <- spillover_results$total_spillover
  n_periods <- length(total_spillover)
  
  contagion_indicators <- list()
  
  # Method 1: Threshold-based detection
  if("threshold" %in% detection_methods) {
    cat("   📊 Threshold-based detection...\\n")
    
    # Multiple threshold levels
    thresholds <- c(0.75, 0.85, 0.90, 0.95)
    threshold_episodes <- list()
    
    for(thresh in thresholds) {
      threshold_val <- quantile(total_spillover, thresh)
      episodes <- which(total_spillover > threshold_val)
      
      # Group consecutive periods
      if(length(episodes) > 0) {
        episode_groups <- split(episodes, cumsum(c(1, diff(episodes) != 1)))
        
        threshold_episodes[[paste0("p", thresh*100)]] <- lapply(episode_groups, function(group) {
          list(
            periods = group,
            start = min(group),
            end = max(group),
            duration = length(group),
            peak_spillover = max(total_spillover[group]),
            avg_spillover = mean(total_spillover[group])
          )
        })
      }
    }
    
    contagion_indicators$threshold <- threshold_episodes
  }
  
  # Method 2: Regime switching detection
  if("regime" %in% detection_methods) {
    cat("   🔄 Regime switching detection...\\n")
    
    # Simple 2-state regime model using changepoint detection
    if(requireNamespace("changepoint", quietly = TRUE)) {
      cpt_result <- changepoint::cpt.mean(total_spillover, method = "PELT")
      changepoints <- changepoint::cpts(cpt_result)
    } else {
      # Fallback: moving average based detection
      ma_short <- zoo::rollmean(total_spillover, k = 5, fill = NA)
      ma_long <- zoo::rollmean(total_spillover, k = 20, fill = NA)
      
      regime_signal <- ifelse(ma_short > ma_long, 1, 0)
      changepoints <- which(diff(regime_signal) != 0)
    }
    
    # Identify high spillover regimes
    if(length(changepoints) > 0) {
      regime_periods <- list()
      starts <- c(1, changepoints + 1)
      ends <- c(changepoints, length(total_spillover))
      
      for(i in 1:length(starts)) {
        period_range <- starts[i]:ends[i]
        avg_spillover <- mean(total_spillover[period_range])
        
        if(avg_spillover > median(total_spillover)) {
          regime_periods[[i]] <- list(
            start = starts[i],
            end = ends[i],
            duration = length(period_range),
            avg_spillover = avg_spillover,
            type = "high_spillover_regime"
          )
        }
      }
      
      contagion_indicators$regime <- regime_periods
    }
  }
  
  # Method 3: Correlation-based detection
  if("correlation" %in% detection_methods) {
    cat("   🔗 Correlation-based detection...\\n")
    
    # Extract correlation evolution from spillover data
    n_assets <- sqrt(ncol(spillover_results$spillover_evolution))
    
    # Calculate average correlation over time
    avg_correlations <- numeric(nrow(spillover_results$spillover_evolution))
    for(t in 1:length(avg_correlations)) {
      spillover_matrix <- matrix(spillover_results$spillover_evolution[t, ], n_assets, n_assets)
      avg_correlations[t] <- mean(spillover_matrix[upper.tri(spillover_matrix)])
    }
    
    # Detect periods of unusually high correlation
    correlation_threshold <- quantile(avg_correlations, 0.85)
    high_correlation_periods <- which(avg_correlations > correlation_threshold)
    
    contagion_indicators$correlation <- list(
      high_correlation_periods = high_correlation_periods,
      avg_correlations = avg_correlations,
      threshold = correlation_threshold
    )
  }
  
  # Method 4: Volatility-based detection
  if("volatility" %in% detection_methods && !is.null(market_data)) {
    cat("   📈 Volatility-based detection...\\n")
    
    # Calculate market volatility
    if(is.matrix(market_data)) {
      market_returns <- diff(log(market_data))
      market_volatility <- apply(market_returns, 1, function(x) sqrt(mean(x^2, na.rm = TRUE)))
    } else {
      market_volatility <- zoo::rollsd(market_data, k = 5, fill = NA)
    }
    
    # Detect volatility spikes
    vol_threshold <- quantile(market_volatility, 0.9, na.rm = TRUE)
    volatility_spikes <- which(market_volatility > vol_threshold)
    
    contagion_indicators$volatility <- list(
      volatility_spikes = volatility_spikes,
      market_volatility = market_volatility,
      threshold = vol_threshold
    )
  }
  
  # Combine indicators into consensus episodes
  cat("   🤝 Creating consensus contagion episodes...\\n")
  
  consensus_episodes <- create_consensus_episodes(contagion_indicators, n_periods)
  
  # Calculate episode characteristics
  episode_characteristics <- analyze_episode_characteristics(consensus_episodes, 
                                                           total_spillover,
                                                           spillover_results)
  
  cat("✅ Advanced contagion detection completed!\\n")
  cat("   • Total episodes identified:", length(consensus_episodes), "\\n")
  cat("   • Detection methods used:", paste(detection_methods, collapse = ", "), "\\n")
  
  return(list(
    consensus_episodes = consensus_episodes,
    episode_characteristics = episode_characteristics,
    individual_indicators = contagion_indicators,
    detection_methods = detection_methods,
    analysis_timestamp = Sys.time()
  ))
}

# Helper functions
detect_structural_breaks <- function(density, clustering) {
  breaks <- list()
  
  # Simple change detection based on moving averages
  if(length(density) > 10) {
    density_ma <- zoo::rollmean(density, k = 5, fill = NA)
    density_changes <- which(abs(diff(density_ma, lag = 5)) > sd(density, na.rm = TRUE))
    breaks$density <- density_changes
  }
  
  if(length(clustering) > 10) {
    clustering_ma <- zoo::rollmean(clustering, k = 5, fill = NA)
    clustering_changes <- which(abs(diff(clustering_ma, lag = 5)) > sd(clustering, na.rm = TRUE))
    breaks$clustering <- clustering_changes
  }
  
  return(breaks)
}

create_consensus_episodes <- function(indicators, n_periods) {
  # Simple consensus: periods flagged by multiple methods
  consensus_flags <- rep(0, n_periods)
  
  # Threshold method
  if(!is.null(indicators$threshold)) {
    for(thresh_level in indicators$threshold) {
      for(episode in thresh_level) {
        consensus_flags[episode$periods] <- consensus_flags[episode$periods] + 1
      }
    }
  }
  
  # Regime method
  if(!is.null(indicators$regime)) {
    for(regime in indicators$regime) {
      if(!is.null(regime$start) && !is.null(regime$end)) {
        consensus_flags[regime$start:regime$end] <- consensus_flags[regime$start:regime$end] + 1
      }
    }
  }
  
  # Correlation method
  if(!is.null(indicators$correlation)) {
    periods <- indicators$correlation$high_correlation_periods
    consensus_flags[periods] <- consensus_flags[periods] + 1
  }
  
  # Volatility method
  if(!is.null(indicators$volatility)) {
    periods <- indicators$volatility$volatility_spikes
    periods <- periods[periods <= n_periods]  # Ensure within bounds
    consensus_flags[periods] <- consensus_flags[periods] + 1
  }
  
  # Require agreement from at least 2 methods
  consensus_periods <- which(consensus_flags >= 2)
  
  # Group into episodes
  if(length(consensus_periods) > 0) {
    episode_groups <- split(consensus_periods, cumsum(c(1, diff(consensus_periods) != 1)))
    return(episode_groups)
  } else {
    return(list())
  }
}

analyze_episode_characteristics <- function(episodes, spillover, spillover_results) {
  if(length(episodes) == 0) {
    return(data.frame())
  }
  
  characteristics <- data.frame()
  
  for(i in 1:length(episodes)) {
    episode_periods <- episodes[[i]]
    
    char <- data.frame(
      episode_id = i,
      start_period = min(episode_periods),
      end_period = max(episode_periods),
      duration = length(episode_periods),
      peak_spillover = max(spillover[episode_periods]),
      avg_spillover = mean(spillover[episode_periods]),
      spillover_increase = max(spillover[episode_periods]) / mean(spillover) - 1,
      severity = ifelse(max(spillover[episode_periods]) > quantile(spillover, 0.95), "severe",
                       ifelse(max(spillover[episode_periods]) > quantile(spillover, 0.85), "moderate", "mild"))
    )
    
    characteristics <- rbind(characteristics, char)
  }
  
  return(characteristics)
}