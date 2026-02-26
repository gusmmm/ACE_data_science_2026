# -------------------------------------------------------------------------
# script: R/extract_data.R
# purpose: Contains functions to extract clinical concepts from MIMIC demo
# -------------------------------------------------------------------------

#' Extract a clinical cohort from the MIMIC demo database
#' 
#' @return A wide dataframe containing patient Age, Length of Stay, and Lactate
pull_mimic_cohort <- function() {
  
  # Ensure the ricu package is loaded
  library(ricu)
  
  # Tell the user what is happening
  message("Extracting clinical data from MIMIC Demo...")
  
  # load_wide() is a brilliant ricu function that pulls multiple concepts 
  # and formats them into a standard, easy-to-read clinical spreadsheet.
  # We will pull:
  # - 'age': Patient age at admission
  # - 'los_icu': Intensive Care Unit Length of Stay
  # - 'lact': Lactate levels (which we know is highly predictive of outcomes)
  
  raw_cohort <- load_wide(
    c("age", "los_icu", "lact"), 
    src = "mimic_demo"
  )
  
  # Return the extracted dataframe
  return(raw_cohort)
}