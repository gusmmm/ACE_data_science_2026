# -------------------------------------------------------------------------
# script: R/clean_data.R
# purpose: Contains functions to clean and filter the raw MIMIC cohort
# -------------------------------------------------------------------------

#' Clean the raw MIMIC cohort data
#' 
#' @param raw_data The uncleaned dataframe extracted by ricu
#' @return A cleaned dataframe ready for statistical analysis and machine learning
clean_mimic_data <- function(raw_data) {
  
  # Ensure the tidyverse suite is loaded
  library(tidyverse)
  
  message("Cleaning the MIMIC cohort data...")
  
  # We use the "pipe" operator ( |> ) to pass the data through a series of filters.
  # Think of the pipe as saying "and then..."
  
  clean_data <- raw_data |> 
    
    # 1. Filter for adults: 
    # Pediatric ICU physiology is completely different from adults. 
    # We restrict our model to patients 18 years and older.
    filter(age >= 18) |> 
    
    # 2. Filter for valid ICU stays:
    # Some patients might die in the ER or be discharged immediately.
    # We only want patients who actually stayed in the ICU for more than 0 days.
    filter(los_icu > 0) |> 
    
    # 3. Handle missing lab values:
    # A predictive model cannot learn from a blank space. 
    # drop_na() removes any patient who did not have a recorded lactate level.
    drop_na(lact)
  
  # Return the sterilized, ready-to-analyze dataset
  return(clean_data)
}

#' Export the cleaned data to a CSV for Python
#' 
#' @param clean_data The dataframe outputted by clean_mimic_data()
#' @param file_path The destination path (managed by the 'here' package)
#' @return The file path (targets needs this to track the file)
export_clean_data <- function(clean_data, file_path) {
  
  # Write the dataframe to a CSV file
  readr::write_csv(clean_data, file = file_path)
  
  # Return the path so 'targets' knows where the file is located
  return(file_path)
}