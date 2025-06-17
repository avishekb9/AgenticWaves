test_that("create_autonomous_agent creates valid agent", {
  # Test basic agent creation
  agent <- create_autonomous_agent("explorer")
  
  expect_true(inherits(agent, "autonomous_agent"))
  expect_true(inherits(agent, "R6"))
  expect_equal(agent$agent_type, "explorer")
  expect_true(is.numeric(agent$learning_rate))
  expect_true(is.numeric(agent$memory_size))
  expect_true(is.list(agent$parameters))
  
  # Test different agent types
  optimizer <- create_autonomous_agent("optimizer")
  expect_equal(optimizer$agent_type, "optimizer")
  
  predictor <- create_autonomous_agent("predictor")
  expect_equal(predictor$agent_type, "predictor")
  
  # Test parameters are different for different types
  expect_false(identical(agent$parameters, optimizer$parameters))
})

test_that("autonomous agent can perform analysis", {
  # Create test data
  test_data <- get_sample_data("global_markets", n_assets = 5, n_periods = 100)
  
  # Create agent
  agent <- create_autonomous_agent("explorer")
  
  # Run analysis
  results <- agent$analyze_autonomously(test_data, objective = "exploration", autonomy_level = 2)
  
  expect_true(is.list(results))
  expect_true("analysis_id" %in% names(results))
  expect_true("data_quality" %in% names(results))
  expect_true("asset_classes" %in% names(results))
  expect_true("analysis_results" %in% names(results))
  expect_true("insights" %in% names(results))
  expect_true("performance_score" %in% names(results))
  
  # Check that performance score is reasonable
  expect_true(results$performance_score >= 0 && results$performance_score <= 100)
  
  # Check that analysis results contain expected components
  analysis <- results$analysis_results
  expect_true("returns_statistics" %in% names(analysis))
  expect_true("network_metrics" %in% names(analysis))
  expect_true("risk_metrics" %in% names(analysis))
})

test_that("create_enhanced_agent_population works correctly", {
  # Test basic population creation
  agents <- create_enhanced_agent_population(n_agents = 50, behavioral_heterogeneity = 0.5)
  
  expect_equal(length(agents), 50)
  expect_true(is.list(agents))
  
  # Check agent structure
  agent1 <- agents[[1]]
  expect_true("id" %in% names(agent1))
  expect_true("type" %in% names(agent1))
  expect_true("initial_wealth" %in% names(agent1))
  expect_true("risk_tolerance" %in% names(agent1))
  expect_true("trading_frequency" %in% names(agent1))
  
  # Check attributes
  expect_equal(attr(agents, "n_agents"), 50)
  expect_true("wealth_gini" %in% names(attributes(agents)))
  expect_true("type_distribution" %in% names(attributes(agents)))
  
  # Test different wealth distributions
  agents_equal <- create_enhanced_agent_population(n_agents = 20, wealth_distribution = "equal")
  equal_wealth <- sapply(agents_equal, function(x) x$initial_wealth)
  expect_true(all(equal_wealth == equal_wealth[1]))
  
  agents_pareto <- create_enhanced_agent_population(n_agents = 20, wealth_distribution = "pareto")
  pareto_wealth <- sapply(agents_pareto, function(x) x$initial_wealth)
  expect_true(var(pareto_wealth) > var(equal_wealth))
})

test_that("create_dynamic_multilayer_network creates valid networks", {
  # Create test agents
  agents <- create_enhanced_agent_population(n_agents = 20, behavioral_heterogeneity = 0.7)
  
  # Create multilayer network
  network <- create_dynamic_multilayer_network(
    agents, 
    network_types = c("trading", "information"), 
    density = 0.1
  )
  
  expect_true(is.list(network))
  expect_true("networks" %in% names(network))
  expect_true("interlayer_correlations" %in% names(network))
  expect_true("network_types" %in% names(network))
  expect_equal(network$n_agents, 20)
  
  # Check individual networks
  expect_true("trading" %in% names(network$networks))
  expect_true("information" %in% names(network$networks))
  
  trading_net <- network$networks$trading
  expect_true("graph" %in% names(trading_net))
  expect_true("adjacency_matrix" %in% names(trading_net))
  expect_true("metrics" %in% names(trading_net))
  
  # Check adjacency matrix dimensions
  adj_matrix <- trading_net$adjacency_matrix
  expect_equal(nrow(adj_matrix), 20)
  expect_equal(ncol(adj_matrix), 20)
  expect_true(all(adj_matrix %in% c(0, 1)))  # Binary adjacency
  expect_true(all(diag(adj_matrix) == 0))    # No self-loops
  
  # Check network metrics
  metrics <- trading_net$metrics
  expect_true("density" %in% names(metrics))
  expect_true("clustering" %in% names(metrics))
  expect_true(metrics$density >= 0 && metrics$density <= 1)
})

test_that("agent parameters are within valid ranges", {
  agents <- create_enhanced_agent_population(n_agents = 100, behavioral_heterogeneity = 0.8)
  
  # Extract all parameter values
  risk_tolerances <- sapply(agents, function(x) x$risk_tolerance)
  trading_frequencies <- sapply(agents, function(x) x$trading_frequency)
  trend_sensitivities <- sapply(agents, function(x) x$trend_sensitivity)
  noise_tolerances <- sapply(agents, function(x) x$noise_tolerance)
  
  # Check ranges
  expect_true(all(risk_tolerances >= 0.1 & risk_tolerances <= 1.0))
  expect_true(all(trading_frequencies >= 0.1 & trading_frequencies <= 1.0))
  expect_true(all(trend_sensitivities >= -1 & trend_sensitivities <= 1))
  expect_true(all(noise_tolerances >= 0.1 & noise_tolerances <= 1.0))
  
  # Check diversity (should have some variation)
  expect_true(var(risk_tolerances) > 0.01)
  expect_true(var(trading_frequencies) > 0.01)
  
  # Check agent types are valid
  agent_types <- sapply(agents, function(x) x$type)
  valid_types <- c("momentum", "contrarian", "fundamentalist", "noise", "herding", "sophisticated")
  expect_true(all(agent_types %in% valid_types))
})