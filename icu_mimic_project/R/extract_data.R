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
  
  # load_concepts() pulls multiple concepts and returns them as a list of
  # id_tbl objects, one per concept. merge = TRUE combines them into a
  # single wide table.
  
  raw_cohort <- load_concepts(
    c("age", "los_icu", "lact"), 
    src = "mimic_demo",
    merge = TRUE
  )
  
  # Return the extracted dataframe
  return(raw_cohort)
}