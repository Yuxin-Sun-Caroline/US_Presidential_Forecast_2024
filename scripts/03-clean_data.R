#### Preamble ####
# Purpose: Cleans the raw data, seperate state and national and reweight
# Author: Yuxin Sun
# Date: 4 November 2024
# Contact: yuxin.sun@mail.utoronto.ca
# License: MIT
# Pre-requisites: none

# Load necessary libraries
library(dplyr)
library(lubridate)
library(readr)

# Step 1: Data Cleaning (Include "state" column and calculate the midpoint date)
polls_clean <- data %>%
  select(state, candidate_name, party, numeric_grade, pct, start_date, end_date, stage) %>%
  filter(!is.na(pct) & !is.na(numeric_grade) & !is.na(start_date) & !is.na(end_date) & !is.na(state)) %>%
  # Parse the dates using the known format "MM/DD/YY"
  mutate(
    start_date = mdy(start_date), 
    end_date = mdy(end_date)
  ) %>%
  mutate(mid_date = as.Date((as.numeric(start_date) + as.numeric(end_date)) / 2, origin = "1970-01-01"))

# Step 2: Filter polls within the 60-day window before the election using "mid_date"
election_date <- as.Date("2024-11-05")
polls_clean <- polls_clean %>%
  filter(mid_date >= (election_date - 30))

# Step 3: Calculate the age of each poll relative to the election date using "mid_date"
polls_clean <- polls_clean %>%
  mutate(age_in_days = as.numeric(election_date - mid_date))

# Step 4: Choose a Decay Factor Based on the Half-Life
half_life <- 20 # Chosen based on campaign dynamics
decay_factor <- log(2) / half_life

# Step 5: Calculate exponential decay weight using the chosen decay factor
polls_clean <- polls_clean %>%
  mutate(time_weight = exp(-decay_factor * age_in_days))

# Step 6: Re-weight the data based on numeric_grade
polls_clean <- polls_clean %>%
  mutate(
    numeric_grade_weight = case_when(
      numeric_grade >= 2.5 & numeric_grade <= 3.0 ~ 3.0,  # High quality: weight = 3.0
      numeric_grade >= 2.0 & numeric_grade < 2.5  ~ 2.3,  # Medium quality: weight = 2.0
      numeric_grade >= 1.2 & numeric_grade < 2.0  ~ 1.0,  # Low quality: weight = 1.0
      numeric_grade < 1.2                     ~ 0.5   # Least significance: weight = 0.5
    )
  )

# Step 7: Combine Time-Based Weight with Pollster Quality Weight
polls_clean <- polls_clean %>%
  mutate(combined_weight = time_weight * numeric_grade_weight)

# Verify the updated dataset
head(polls_clean)

state_polls <- polls_clean %>% filter(!is.na(state) & state != "")
national_polls <- polls_clean %>% filter(is.na(state) | state == "")

state_polls <- state_polls %>%
  mutate(
    state = str_to_title(str_trim(state)),  # Standardize case and remove extra spaces
    # Simplify state names for districts in Maine and Nebraska
    state = case_when(
      state %in% c("Maine Cd-1", "Maine Cd-2", "Maine Cd-3") ~ "Maine",
      state %in% c("Nebraska Cd-1", "Nebraska Cd-2", "Nebraska Cd-3") ~ "Nebraska",
      state == "D.C." ~ "District Of Columbia",  # Adjust name for D.C.
      TRUE ~ state  # Keep other state names as they are
    )
  )
# Load necessary libraries
library(dplyr)
library(stringr)  # For string manipulation if needed

# Step 1: Check if `electoral_votes` has the necessary columns and create `final_state_weight`
# Calculate total state weight
total_state_weight <- sum(electoral_votes$state_weight, na.rm = TRUE)

# Create `final_state_weight` in `electoral_votes`
electoral_votes <- electoral_votes %>%
  mutate(final_state_weight = state_weight / total_state_weight)


# Step 2: Standardize `state` Names in Both Data Frames
# Make sure state names in both data frames are consistently formatted
state_polls <- state_polls %>%
  mutate(state = str_to_title(str_trim(state)))  # Standardize case and remove extra spaces

electoral_votes <- electoral_votes %>%
  mutate(state = str_to_title(str_trim(state)))  # Standardize case and remove extra spaces


# Step 3: Attempt to Merge `final_state_weight` into `state_polls`
state_polls <- state_polls %>%
  left_join(electoral_votes %>% select(state, final_state_weight), by = "state")



# Proceed with the rest of your analysis and model code if merging is successful


#### Save data ####
write_csv(polls_clean, "data/02-analysis_data/polls_clean.csv")
write_csv(national_polls, "data/02-analysis_data/national_polls.csv")
write_csv(state_polls, "data/02-analysis_data/state_polls.csv")
