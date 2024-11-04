#### Preamble ####
# Purpose: Downloads and saves the data from 538
# Author: Yuxin Sun
# Date: 4 November 2024
# Contact: yuxin.sun@mail.utoronto.ca
# License: MIT
# Pre-requisites: download readr and here package



library(readr)
library(here)

# Read the CSV file from the 538
poll_raw <- read_csv(
  file = "https://projects.fivethirtyeight.com/polls/data/president_polls.csv",
  show_col_types = FALSE
)

# Write the CSV file using the 'here' package
write_csv(
  x = poll_raw,
  file = here("data", "01-raw_data","president_polls.csv")
)
