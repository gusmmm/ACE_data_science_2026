# Install the core ricu package from CRAN
install.packages("ricu")

# Install the MIMIC and eICU demo datasets from the custom repository
install.packages(
  c("mimic.demo", "eicu.demo"), 
  repos = "https://eth-mds.github.io/physionet-demo"
)

# Load and verify the data
## Load the package into your current session
library(ricu)

# Check which data sources are currently available and attached
## You should see "mimic_demo" and "eicu_demo" listed as TRUE
src_data_avail()

## Take a quick look at the admissions table for the MIMIC demo
head(mimic_demo$admissions)
