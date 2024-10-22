#### Preamble ####
# Purpose: Simulates Toronto Shelter System data with population categories, gender, occupancy status, and year of entry, using 1,000 randomly generated data points.
# Author: Yuxin Sun
# Date: 22 September 2024 
# Contact: yuxin.sun@mail.utoronto.ca
# License: MIT
# Pre-requisites: install janitor package and tidyverse package

# Install the required packages
# install.packages("janitor")
# install.packages("tidyverse")
library(janitor)
library(tidyverse)

#### Data Simulation ####

set.seed(200)

# Simulating shelter system flow data with 1000 entries
simulated_shelter_data <-
  tibble(
    # Generating a unique ID for each entry
    "ID" = 1:1000,
    
    # Simulating the population categories with random assignment
    "Population Category" = sample(
      x = c("All Population", "Families", "Single Adults", "Refugees"),
      size = 1000,
      replace = TRUE),
    
    # Simulating gender distribution with random assignment
    "Gender" = sample(
      x = c("Male", "Female", "Transgender/Non-binary"),
      size = 1000,
      replace = TRUE),
    
    # Simulating shelter occupancy status
    "Occupancy Status" = sample(
      x = c("Sheltered", "Unsheltered"),
      size = 1000,
      replace = TRUE),
    
    # Simulating year of data entry
    "Year" = sample(
      x = 2018:2024,
      size = 1000,
      replace = TRUE)
  )

#### Testing the Simulated Dataset ####

# Check the class of the columns

simulated_shelter_data$`Population Category` |> class() == "character"
simulated_shelter_data$Gender |> class() == "character"
simulated_shelter_data$`Occupancy Status` |> class() == "character"
simulated_shelter_data$Year |> class() == "integer"

# Check that the minimum value in the ID column is 1
simulated_shelter_data$ID |> min() >= 1

# Check that there are four population categories: All Population, Families, Single Adults, and Refugees
simulated_shelter_data$`Population Category` |>
  unique() |>
  sort() == sort(c("All Population", "Families", "Single Adults", "Refugees"))

# Check that there are exactly three gender categories
simulated_shelter_data$Gender |>
  unique() |>
  length() == 3

# Check that occupancy status includes only "Sheltered" and "Unsheltered"
simulated_shelter_data$`Occupancy Status` |>
  unique() == c("Sheltered", "Unsheltered")

# Check that the year range is between 2018 and 2024
simulated_shelter_data$Year |> range() == c(2018, 2024)



