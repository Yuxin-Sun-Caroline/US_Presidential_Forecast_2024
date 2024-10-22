#### Preamble ####
# Purpose: Clean the Raw Dataset and Label for the graph
# Author: Yuxin Sun
# Date: 26 September 2024 
# Contact: yuxin.sun@mail.utoronto.ca
# License: MIT
# Pre-requisites: none

# Load necessary library
library(dplyr)

# Load the data
data <- read.csv("/Users/so_watermelon/Downloads/starter_folder-main-2/data/raw_data/raw_data.csv")

# Clean column names
clean_data <- data %>%
  rename(
    id = X_id,
    date = date.mmm.yy.,
    population_group = population_group,
    returned_from_housing = returned_from_housing,
    returned_to_shelter = returned_to_shelter,
    newly_identified = newly_identified,
    moved_to_housing = moved_to_housing,
    became_inactive = became_inactive,
    actively_homeless = actively_homeless,
    age_under_16 = ageunder16,
    age_16_24 = age16.24,
    age_25_34 = age25.34,
    age_35_44 = age35.44,
    age_45_54 = age45.54,
    age_55_64 = age55.64,
    age_65_over = age65over,
    gender_male = gender_male,
    gender_female = gender_female,
    gender_transgender_non_binary_or_two_spirit = gender_transgender.non.binary_or_two_spirit,
    population_group_percentage = population_group_percentage
  )

# Convert percentage column to numeric by removing the percentage sign
clean_data <- clean_data %>%
  mutate(population_group_percentage = as.numeric(gsub("%", "", population_group_percentage)))

write_csv(cleaned_data, "/Users/so_watermelon/Downloads/starter_folder-main-2/data/analysis_data/analysis_data.csv")
