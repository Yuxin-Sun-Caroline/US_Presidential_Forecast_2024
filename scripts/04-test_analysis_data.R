#### Preamble ####
# Purpose: Test the cleaned data  
# Author: Yuxin Sun
# Date: 4 November 2024
# Contact: yuxin.sun@mail.utoronto.ca
# License: MIT
# Pre-requisites: download dplyr and lubridate package


# Load necessary libraries
library(dplyr)
library(lubridate)


# Test 1: Check that all necessary columns are present in the data
test_columns <- function(data) {
  required_columns <- c("state", "candidate_name", "party", "numeric_grade", "pct", "start_date", "end_date", "stage")
  all(required_columns %in% colnames(data))
}

# Test 2: Check that there are no missing values in the relevant columns
test_missing_values <- function(data) {
  sum(is.na(data$state)) == 0 &&
    sum(is.na(data$candidate_name)) == 0 &&
    sum(is.na(data$party)) == 0 &&
    sum(is.na(data$numeric_grade)) == 0 &&
    sum(is.na(data$pct)) == 0 &&
    sum(is.na(data$start_date)) == 0 &&
    sum(is.na(data$end_date)) == 0
}

# Test 3: Verify that the date conversion worked correctly
test_date_conversion <- function(data) {
  all(class(data$start_date) == "Date") && all(class(data$end_date) == "Date")
}

# Test 4: Check that mid_date calculation is within the valid range
test_mid_date <- function(data) {
  all(data$mid_date >= as.Date("1970-01-01") & data$mid_date <= Sys.Date())
}

# Test 5: Verify that polls are within the 60-day window before the election
test_date_filter <- function(data, election_date) {
  all(data$mid_date >= (election_date - 60) & data$mid_date <= election_date)
}

# Example usage:
# Assuming `polls_clean` is your cleaned data and `election_date` is already defined
if (test_columns(polls_clean)) {
  print("Test 1 passed: All required columns are present.")
} else {
  print("Test 1 failed: Missing required columns.")
}

if (test_missing_values(polls_clean)) {
  print("Test 2 passed: No missing values in relevant columns.")
} else {
  print("Test 2 failed: There are missing values.")
}

if (test_date_conversion(polls_clean)) {
  print("Test 3 passed: Date conversion is correct.")
} else {
  print("Test 3 failed: Date conversion issue detected.")
}

if (test_mid_date(polls_clean)) {
  print("Test 4 passed: mid_date is within a valid range.")
} else {
  print("Test 4 failed: mid_date is out of range.")
}

if (test_date_filter(polls_clean, election_date)) {
  print("Test 5 passed: Polls are within the 60-day window before the election.")
} else {
  print("Test 5 failed: Polls are outside the 60-day window.")
}

