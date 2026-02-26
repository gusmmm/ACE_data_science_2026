# -------------------------------------------------------------------------
# script: setup_environment.R
# purpose: Bootstraps the isolated R environment for Positron
# -------------------------------------------------------------------------

# 1. Install renv if it is completely missing from the computer
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv")
}

# 2. FAILSAFE: Only initialize if the project hasn't been initialized yet
if (!file.exists("renv.lock")) {
  renv::init(bare = TRUE) 
} else {
  cat("\nProject is already initialized. Skipping to package installation...\n")
}

# 3. Re-attach Positron telemetry (jsonlite) and install modern package manager (pak)
# We use suppressWarnings so it doesn't complain if they are already installed
suppressWarnings(install.packages(c("jsonlite", "pak")))

# 4. Define our Clinical Data Science Stack
icu_packages <- c(
  "tidyverse",    
  "targets",      
  "tarchetypes",  
  "ricu",         
  "here",         
  "fs"            
)

# 5. Install the stack using pak 
pak::pkg_install(icu_packages)

# 6. Lock in the environment versions
renv::snapshot(prompt = FALSE)

cat("\nEnvironment setup complete! Positron is fully linked, and your project is sterile.\n")
