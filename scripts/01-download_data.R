#### Preamble ####
# Purpose: Downloads and saves the data from OpenDataTotonto
# Author: Yuxin Sun
# Date: 26 September 2024 
# Contact: yuxin.sun@mail.utoronto.ca
# License: MIT
# Pre-requisites: None 

#### Loading Packages ####

# install.packages("opendatatoronto")
# install.packages("tidyverse")
library(opendatatoronto)
library(tidyverse)

#### Searching for Available Resources ####

# Search for the Toronto Shelter System Flow dataset
package_info <- search_packages("Toronto Shelter System Flow")

# List available resources to see what can be downloaded
resources <- list_package_resources(package_info)

# View available resource names to identify the correct one
print(resources)

#### Downloading the Correct Resource ####

# After inspecting the printed resource names, modify the filter accordingly
outbreak_raw_data <- 
  resources |>
  filter(name == "Toronto Shelter System Flow Data") |>  # Make sure this name matches exactly with one of the available resources
  get_resource()

#### Saving the Dataset ####

# Save the dataset to the specified file path
write_csv(outbreak_raw_data, "/Users/so_watermelon/Downloads/starter_folder-main-2/data/raw_data/raw_data.csv")


         
