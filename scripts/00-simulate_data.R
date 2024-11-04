#### Preamble ####
# Purpose: Simulates a dataset of Australian electoral divisions, including the 
  #state and party that won each division.
# Author: Yuxin Sun
# Date: 4 Novermber 2024
# Contact: yuxin.sun@mail.utoronto.ca
# License: MIT
# Pre-requisites: The `tidyverse` package must be installed



library(dplyr)
library(lubridate)
library(readr)
library(tidyverse)

# Function to Simulate Polling Percentages with all necessary columns
simulate_polling_data <- function(polls_clean, electoral_votes, num_simulations) {
  simulations <- list()
  
  # Loop to create multiple simulations
  for (i in 1:num_simulations) {
    # Create simulated data by copying the original data
    simulated_data <- polls_clean %>%
      group_by(state, candidate_name) %>%
      mutate(
        # Retain all the original columns
        numeric_grade = first(numeric_grade),
        start_date = first(start_date),
        end_date = first(end_date),
        mid_date = first(mid_date),
        age_in_days = first(age_in_days),
        time_weight = first(time_weight),
        numeric_grade_weight = first(numeric_grade_weight),
        combined_weight = first(combined_weight),
        
        # Adjust standard deviation based on pollster quality
        sd_value = case_when(
          numeric_grade >= 2.5 ~ 1.5,  # High-quality pollsters: low variability
          numeric_grade >= 2.0 ~ 2.5,  # Medium-quality pollsters: moderate variability
          numeric_grade >= 1.2 ~ 4.0,  # Low-quality pollsters: higher variability
          TRUE                 ~ 6.0   # Very low-quality pollsters: very high variability
        ),
        
        # Generate simulated percentage, matching the trend of the original pct
        pct = pmin(100, pmax(0, rnorm(n(), mean = pct, sd = sd_value)))  # Bounded between 0 and 100
      ) %>%
      ungroup()
    
    # Add simulation identifier
    simulated_data <- simulated_data %>%
      mutate(simulation_id = i)
    
    # Append the simulated data to the list
    simulations[[i]] <- simulated_data
  }
  
  # Combine all simulations into one dataframe
  combined_data <- bind_rows(simulations)
  
  # Add state weights from electoral_votes
  combined_data <- combined_data %>%
    left_join(
      electoral_votes %>% select(state, final_state_weight),
      by = "state"
    )
  
  return(combined_data)
}

# Run the simulation
set.seed(123)  # Set seed for reproducibility
num_simulations <- 100  # Number of simulations

# Generate simulated data
simulated_data <- simulate_polling_data(polls_clean, electoral_votes, num_simulations)

# Split into state and national polls
simulated_state_polls <- simulated_data %>%
  filter(!is.na(state) & state != "")

simulated_national_polls <- simulated_data %>%
  filter(is.na(state) | state == "")

# Basic validation of simulated data
validation_summary <- simulated_state_polls %>%
  group_by(state, candidate_name) %>%
  summarise(
    mean_pct = mean(pct),
    sd_pct = sd(pct),
    min_pct = min(pct),
    max_pct = max(pct),
    n_polls = n(),
    .groups = 'drop'
  )



# Save the simulated data
write_csv(simulated_data, "data/00-simulated_data/simulated_data.csv")
write_csv(simulated_state_polls, "data/00-simulated_data/simulated_state_polls.csv")
write_csv(simulated_national_polls, "data/00-simulated_data/simulated_national_polls.csv")







