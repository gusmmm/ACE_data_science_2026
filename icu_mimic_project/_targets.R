# -------------------------------------------------------------------------
# script: _targets.R
# purpose: Master control file for the reproducible ICU data pipeline
# -------------------------------------------------------------------------

# 1. Load the pipeline manager packages
library(targets)
library(tarchetypes)

# 2. Set global options for the pipeline
# We tell targets which packages it needs to load before running any functions.
tar_option_set(
  packages = c("tidyverse", "ricu", "here")
)

# 3. Source our custom surgical instruments (functions)
# This loads the scripts we wrote earlier into the pipeline's memory.
tar_source("R/extract_data.R")
tar_source("R/clean_data.R")

# 4. Define the Clinical Pipeline (The Order Set)
# This list contains the exact, chronological steps of our data research.
list(
  
  # Step A: Extract the raw data
  # We call the function we wrote and assign the output to a target named 'raw_data'
  tar_target(
    name = raw_data,
    command = pull_mimic_cohort()
  ),
  
  # Step B: Clean the data
  # We pass the 'raw_data' target into our cleaning function.
  tar_target(
    name = cleaned_data,
    command = clean_mimic_data(raw_data)
  ),
  
  # Step C: Export the bridge file for Python
  # We use our export function to save the clean data. 
  # CRITICAL: We set format = "file" so targets knows to watch the actual .csv file!
  tar_target(
    name = exported_csv,
    command = export_clean_data(
      clean_data = cleaned_data, 
      file_path = here::here("data", "cleaned_mimic.csv")
    ),
    format = "file"
  )
)