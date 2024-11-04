#### Preamble ####
# Purpose: Use simulated data to check if the Model overfit
# Author: Yuxin Sun
# Date: 4 November 2024
# Contact: yuxin.sun@mail.utoronto.ca
# License: MIT
# Pre-requisites: tidyverse, brms, bayesplot, ggplot2


#### Preamble ####
# Purpose: Validate the Bayesian model using simulated state and national polls
# Author: [Your Name]
# Date: 4 November 2024
# Pre-requisites: tidyverse, brms, bayesplot

library(tidyverse)
library(brms)
library(bayesplot)

# Load the saved model and simulated data
model <- readRDS(here("models", "model.rds"))
simulated_state_polls <- read_csv("data/00-simulated_data/simulated_state_polls.csv")
simulated_national_polls <- read_csv("data/00-simulated_data/simulated_national_polls.csv")

# Function to prepare data in the same format as the original model
prepare_simulation_data <- function(data) {
  data %>%
    filter(candidate_name %in% c("Donald Trump", "Kamala Harris")) %>%
    select(state, candidate_name, pct, combined_weight, numeric_grade, 
           age_in_days, final_state_weight, simulation_id) %>%
    mutate(is_trump = if_else(candidate_name == "Donald Trump", 1, 0))
}

# Prepare simulated state data
sim_state_model_data <- prepare_simulation_data(simulated_state_polls)

# Function to get predictions with simulation IDs
get_predictions <- function(model, data) {
  fitted_values <- fitted(model, newdata = data, allow_new_levels = TRUE)
  data.frame(
    actual = data$pct,
    predicted = fitted_values[,"Estimate"],
    simulation_id = data$simulation_id,
    state = data$state,
    candidate_name = data$candidate_name
  )
}

# Get predictions for simulated state data
sim_predictions <- get_predictions(model, sim_state_model_data)

# Calculate residuals
calculate_residuals <- function(predictions) {
  predictions %>%
    mutate(residuals = predicted - actual)
}

sim_residuals <- calculate_residuals(sim_predictions)

# Calculate metrics for all simulations and by simulation
calculate_metrics <- function(predictions, by_simulation = FALSE) {
  if (by_simulation) {
    predictions %>%
      group_by(simulation_id) %>%
      summarise(
        rmse = sqrt(mean((predicted - actual)^2)),
        mae = mean(abs(predicted - actual)),
        r_squared = cor(predicted, actual)^2
      )
  } else {
    data.frame(
      Metric = c("RMSE", "MAE", "R-squared"),
      Value = c(
        sqrt(mean((predictions$predicted - predictions$actual)^2)),
        mean(abs(predictions$predicted - predictions$actual)),
        cor(predictions$predicted, predictions$actual)^2
      )
    )
  }
}

# Calculate overall metrics and by-simulation metrics
sim_metrics_overall <- calculate_metrics(sim_predictions)
sim_metrics_by_simulation <- calculate_metrics(sim_predictions, by_simulation = TRUE)

# State-level validation
state_validation <- sim_predictions %>%
  group_by(state, simulation_id) %>%
  summarise(
    rmse = sqrt(mean((predicted - actual)^2)),
    mae = mean(abs(predicted - actual)),
    n = n(),
    .groups = 'drop'
  ) %>%
  group_by(state) %>%
  summarise(
    mean_rmse = mean(rmse),
    sd_rmse = sd(rmse),
    mean_mae = mean(mae),
    n_total = sum(n),
    .groups = 'drop'
  ) %>%
  arrange(desc(mean_rmse))

# Candidate-level validation
candidate_validation <- sim_predictions %>%
  group_by(candidate_name, simulation_id) %>%
  summarise(
    rmse = sqrt(mean((predicted - actual)^2)),
    mae = mean(abs(predicted - actual)),
    n = n(),
    .groups = 'drop'
  ) %>%
  group_by(candidate_name) %>%
  summarise(
    mean_rmse = mean(rmse),
    sd_rmse = sd(rmse),
    mean_mae = mean(mae),
    n_total = sum(n),
    .groups = 'drop'
  )

# Calculate simulation stability metrics
simulation_stability <- sim_predictions %>%
  group_by(simulation_id) %>%
  summarise(
    mean_error = mean(predicted - actual),
    sd_error = sd(predicted - actual),
    .groups = 'drop'
  )

# Compile all validation results
validation_results <- list(
  metrics_overall = sim_metrics_overall,
  metrics_by_simulation = sim_metrics_by_simulation,
  state_validation = state_validation,
  candidate_validation = candidate_validation,
  simulation_stability = simulation_stability,
  residuals_summary = summary(sim_residuals$residuals)
)

# Save validation results
saveRDS(validation_results, here("models", "validation_results.rds"))

# Print summary statistics
cat("\nOverall Validation Metrics:\n")
print(sim_metrics_overall)

cat("\nState-level Validation Summary (Top 5 states by RMSE):\n")
print(head(state_validation, 5))

cat("\nCandidate-level Validation Summary:\n")
print(candidate_validation)

cat("\nSimulation Stability Summary:\n")
print(summary(simulation_stability$mean_error))