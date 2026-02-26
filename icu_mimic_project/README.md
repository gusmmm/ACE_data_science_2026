# icu_mimic_project

> A reproducible R data pipeline that extracts, cleans, and exports clinical
> ICU data from the [MIMIC-III Demo](https://physionet.org/content/mimiciii-demo/)
> database, intended as a bridge to a downstream Python ML model.

---

## Table of Contents

- [Purpose](#purpose)
- [Architecture](#architecture)
- [Pipeline Targets](#pipeline-targets)
- [Variables Created](#variables-created-in-cleaned-data)
- [Output Files](#output-files)
- [Key R Packages](#key-r-packages)
- [How to Use](#how-to-use)
- [TODO](#whats-still-empty--todo)

---

## Purpose

This project provides a clean, versioned pipeline for extracting clinical
concepts from the MIMIC-III Demo ICU database using the
[`ricu`](https://cran.r-project.org/package=ricu) package. The resulting
cleaned dataset is exported as a CSV file intended to feed a downstream Python
machine learning model.

Reproducibility is ensured by:

- **`targets`** for pipeline orchestration and caching
- **`renv`** for locked R package versions

---

## Architecture

```
icu_mimic_project/
├── _targets.R              # Pipeline definition (master control)
├── R/
│   ├── extract_data.R      # Data extraction from MIMIC demo via ricu
│   └── clean_data.R        # Cleaning, filtering, and CSV export
├── scripts/
│   └── setup_environment.R # One-time environment bootstrap
├── python/
│   └── ml_model.py         # (stub — not yet implemented)
├── icu_report.qmd          # (stub — not yet implemented)
├── renv.lock               # Locked R package versions
├── .Rprofile               # Auto-activates renv
└── README.md               # This file
```

---

## Pipeline Targets

The pipeline defines **3 targets** in this order:

| Target | Function | Description |
|---|---|---|
| `raw_data` | `pull_mimic_cohort()` | Extracts `age`, `los_icu`, and `lact` from `mimic_demo` via `ricu::load_concepts()` — returns a wide `id_tbl` |
| `cleaned_data` | `clean_mimic_data(raw_data)` | Filters adults (age ≥ 18), valid ICU stays (los_icu > 0), drops rows with missing lactate |
| `exported_csv` | `export_clean_data(cleaned_data, ...)` | Writes `data/cleaned_mimic.csv`; tracked as a **file target** (`format = "file"`) |

---

## Variables Created (in cleaned data)

| Column | Source concept | Description |
|---|---|---|
| `age` | `ricu` concept `age` | Patient age in years |
| `los_icu` | `ricu` concept `los_icu` | ICU length of stay in days |
| `lact` | `ricu` concept `lact` | Serum lactate level (mmol/L) |

> The table also retains whatever ID columns `ricu` attaches (typically
> `icustay_id` / `stay_id`).

---

## Output Files

| File | Created by | Notes |
|---|---|---|
| `data/cleaned_mimic.csv` | `export_clean_data()` | Bridge file for Python; `targets` watches it for changes |
| `_targets/objects/raw_data` | `targets` cache | Serialised R object |
| `_targets/objects/cleaned_data` | `targets` cache | Serialised R object |
| `_targets/meta/meta` | `targets` | Pipeline metadata / dependency graph |

---

## Key R Packages

| Package | Role |
|---|---|
| `targets` / `tarchetypes` | Pipeline orchestration |
| `ricu` | Clinical concept extraction from MIMIC |
| `mimic.demo` / `eicu.demo` | Demo ICU datasets (PhysioNet repo) |
| `tidyverse` | Data manipulation |
| `here` | Portable file paths |
| `renv` | Reproducible package environment |

---

## How to Use

### First-time setup (once per machine)

```r
source("scripts/setup_environment.R")
```

### Run the full pipeline

```r
targets::tar_make()
```

### Check pipeline status

```r
# Show which targets are outdated and need to be re-run
targets::tar_outdated()
```

### Visualise the dependency graph

```r
# Interactive HTML widget — opens in browser
targets::tar_visnetwork()

# Simpler ggplot-based view (no htmlwidgets required)
targets::tar_glimpse()
```

### Load a target result into your session

```r
targets::tar_load(cleaned_data)   # assigns 'cleaned_data' to global env
targets::tar_read(raw_data)       # returns 'raw_data' without assigning
```

### Read the exported CSV directly

```r
readr::read_csv(here::here("data", "cleaned_mimic.csv"))
```

---

## What's Still Empty / TODO

- [ ] `icu_report.qmd` — Quarto report (stub, not yet written)
- [ ] `python/ml_model.py` — Python ML model (stub, not yet written)
- [ ] Add unit tests for cleaning functions
- [ ] Expand extracted concepts (e.g. SOFA score, vasopressors, ventilation)

---

## License

For educational and research use only. MIMIC data access requires credentialing
via [PhysioNet](https://physionet.org/). Do not share or publish raw MIMIC data.