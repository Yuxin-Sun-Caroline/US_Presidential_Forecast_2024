#### Preamble ####
# Purpose: Tests the simulation data
# Author: Yuxin Sun
# Date: 26 September 2024 
# Contact: yuxin.sun@mail.utoronto.ca
# License: MIT
# Pre-requisites: None
# Any other information needed? None

#### Loading Packages ####
# You can uncomment this line if tidyverse is not installed
# install.packages("tidyverse")
library(tidyverse)

#### Loading the Cleaned Dataset ####
# Load the cleaned data
cleaned_data <- read_csv("path_to_cleaned_data.csv")

#### Data Testing ####

# Check that the `population_group` column is of type character
is_character <- class(cleaned_data$population_group) == "character"
print(is_character)  # Should return TRUE

# Check that the `returned_from_housing` column is numeric
is_numeric <- class(cleaned_data$returned_from_housing) == "numeric"
print(is_numeric)  # Should return TRUE

# Ensure that the minimum value in the `X_id` column is at least 1
min_id_value <- min(cleaned_data$X_id)
print(min_id_value >= 1)  # Should return TRUE

# Check that the `population_group_percentage` contains only valid numeric values
cleaned_data$population_group_percentage <- as.numeric(gsub("%", "", cleaned_data$population_group_percentage))
print(summary(cleaned_data$population_group_percentage))

#### Data Summarization and Visualization ####

# Plot the distribution of actively homeless individuals by population group
ggplot(cleaned_data, aes(x = population_group, y = actively_homeless)) +
  geom_bar(stat = "identity") +
  labs(title = "Actively Homeless by Population Group", x = "Population Group", y = "Count of Actively Homeless") +
  theme_minimal()

# Plot the percentage of population group over time
ggplot(cleaned_data, aes(x = as.Date(paste("01-", date.mmm.yy., sep = ""), "%d-%b-%y"), y = population_group_percentage)) +
  geom_line(aes(color = population_group)) +
  labs(title = "Population Group Percentage Over Time", x = "Date", y = "Population Group Percentage") +
  theme_minimal()
