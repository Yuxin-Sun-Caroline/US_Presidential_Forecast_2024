#### Preamble ####
# Purpose: Do Bayesian modeling based on weighted data 
# Author: Yuxin Sun
# Date: 4 November 2024
# Contact: yuxin.sun@mail.utoronto.ca
# License: MIT
# Pre-requisites: download tidyverse, brms, bayesplot package



# Load required libraries
library(tidyverse)
library(brms)
library(bayesplot)

# First join state_polls with electoral_votes to get final_state_weight
state_polls <- state_polls %>%
  left_join(
    electoral_votes %>% select(state, final_state_weight),
    by = "state"
  )

# Now prepare state polls data for modeling
model_data_state <- state_polls %>%
  filter(candidate_name %in% c("Donald Trump", "Kamala Harris")) %>%
  # Use only the variables we already have, now including final_state_weight
  select(state, candidate_name, pct, combined_weight, numeric_grade, age_in_days, final_state_weight) %>%
  # Create binary variable for candidate
  mutate(is_trump = if_else(candidate_name == "Donald Trump", 1, 0))

# 2. Fit Bayesian model for state polls
state_model <- brm(
  formula = pct ~ is_trump + 
    combined_weight + 
    final_state_weight +
    numeric_grade +
    age_in_days +
    (1|state),
  data = model_data_state,
  family = gaussian(),
  prior = c(
    prior(normal(45, 10), class = "Intercept"),
    prior(normal(0, 5), class = "b"),
    prior(exponential(1), class = "sigma"),
    prior(exponential(1), class = "sd")
  ),
  chains = 4,
  iter = 2000,
  warmup = 1000,
  cores = 4,
  seed = 123
)

# 3. Generate state-level predictions
# Create prediction data for each state
states <- unique(model_data_state$state)
prediction_data <- expand.grid(
  state = states,
  is_trump = c(1, 0),
  combined_weight = mean(model_data_state$combined_weight),
  final_state_weight = mean(model_data_state$final_state_weight),
  numeric_grade = mean(model_data_state$numeric_grade),
  age_in_days = mean(model_data_state$age_in_days)
)

# Get predictions
state_predictions <- fitted(state_model, newdata = prediction_data)

# Organize predictions into a readable format
results_df <- data.frame(
  state = prediction_data$state,
  candidate = ifelse(prediction_data$is_trump == 1, "Trump", "Harris"),
  estimate = state_predictions[,"Estimate"],
  lower = state_predictions[,"Q2.5"],
  upper = state_predictions[,"Q97.5"]
) %>%
  pivot_wider(
    names_from = candidate,
    values_from = c(estimate, lower, upper)
  ) %>%
  mutate(
    margin = estimate_Trump - estimate_Harris,
    margin_lower = lower_Trump - upper_Harris,
    margin_upper = upper_Trump - lower_Harris
  )

# Calculate swing state results
swing_states <- c("Nevada", "Wisconsin", "Michigan", "Pennsylvania", 
                  "North Carolina", "Arizona", "Georgia")
swing_results <- results_df %>%
  filter(state %in% swing_states) %>%
  arrange(desc(margin))

# Calculate national average (weighted by final_state_weight)
national_estimate <- model_data_state %>%
  group_by(state) %>%
  summarise(weight = mean(final_state_weight)) %>%
  left_join(results_df, by = "state") %>%
  summarise(
    trump_national = weighted.mean(estimate_Trump, weight),
    harris_national = weighted.mean(estimate_Harris, weight),
    margin_national = trump_national - harris_national
  )

# Print results
cat("\nSwing State Predictions:\n")
print(swing_results %>% 
        select(state, estimate_Trump, estimate_Harris, margin) %>%
        arrange(desc(margin)))

cat("\nNational Prediction (State-Weighted Average):\n")
print(national_estimate)

# Model diagnostics
print(summary(state_model))

# Posterior predictive check
pp_check(state_model)

# Extract random effects for states
ranef_summary <- ranef(state_model)
print(ranef_summary)
# Save the model
saveRDS(
  object = state_model,
  file = here("models", "model.rds")
)  


