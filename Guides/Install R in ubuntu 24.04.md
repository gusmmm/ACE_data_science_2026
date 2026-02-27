# Reproducible Analytical Pipelines (RAP) in R for Critical Care Medicine

> **A Comprehensive Guide for Medical Doctors Transitioning to Data Science**

Designing a fully reproducible analytical pipeline (RAP) for intensive care datasets demands the same level of rigorous isolation, tracking, and protocol adherence that you apply in the ICU. In clinical practice, you rely on standardized protocols and checklists to minimize errors and ensure predictable patient outcomes. In data science, Reproducible Analytical Pipelines (RAP) serve the exact same purpose: they ensure your research is transparent, error-free, and perfectly replicable by other researchers—or by yourself six months from now.

This guide provides a foolproof, step-by-step blueprint for building a future-proof data science environment in R, tailored specifically for critical care datasets like MIMIC and eICU. We will use the most modern tech stack available: **Positron**, **`renv`**, **`pak`**, and **`targets`**. We will also address core engineering practices emphasized in modern RAP literature, such as functional programming, unit testing, and OS-level encapsulation.

---

## The Modern Clinical Data Science Stack

Before we build the environment, let's understand the instruments in our toolkit:

*   **Positron:** Posit’s next-generation IDE built on Code OSS. It offers the familiar, powerful interface of VS Code but is meticulously optimized for R and Python data science workflows.
*   **`renv` (The Locked Medication Chart):** An environment manager that creates an isolated library for your project. It prevents the "it works on my machine" syndrome by tracking the exact versions of every package you use.
*   **`pak` (The Automated Pharmacy Dispenser):** A modern, blazing-fast package manager that handles parallel HTTP downloads to vastly outperform standard R dependency resolution.
*   **`targets` (The Clinical Pathway):** A pipeline tool that builds a Directed Acyclic Graph (DAG) of your project. If you update a specific patient cohort definition, `targets` recalculates *only* the downstream models affected by that change, saving hours of computational time.
*   **`ricu`:** A dedicated critical care data interface that bypasses complex credentialing hurdles for demonstration purposes, allowing you to directly download and query the `mimic.demo` and `eicu.demo` datasets as mapped, standardized objects.

---

## Phase 1: Installing R on Ubuntu 24.04

Before configuring project-level dependencies, you must install R and the underlying OS dependencies necessary for building data science packages. We install R via the official CRAN repository to ensure access to the latest versions.

### 1. OS Preparation and CRAN Repository Setup
Update your system and install the tools required to manage software repositories:
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install --no-install-recommends software-properties-common dirmngr wget curl -y
```

### 2. Add the CRAN Repository
Import the official GPG key and add the repository for Ubuntu 24.04 ("Noble"):
```bash
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/"
```

### 3. Install Base R and Developer Tools
Install the R base system along with `r-base-dev`. The developer tools provide the C/C++ compilers and headers required to build R packages from their source code.
```bash
sudo apt update
sudo apt install --no-install-recommends r-base r-base-dev -y
```

### 4. Core System Dependencies
Many R packages (especially those handling APIs, graphics, or data manipulation) require underlying Linux libraries to compile successfully. Install these mandatory system dependencies:
```bash
sudo apt install -y \
 libcurl4-openssl-dev \
 libssl-dev \
 libxml2-dev \
 libfontconfig1-dev \
 libharfbuzz-dev \
 libfribidi-dev \
 libfreetype6-dev \
 libpng-dev \
 libtiff5-dev \
 libjpeg-dev
```

---

## Phase 2: The Foundation – IDE and Git

Global packages are the enemy of reproducibility. We will bypass global package installations entirely to ensure complete isolation.

### 1. Install Positron
Because Positron shares the same architecture as VS Code, it offers superior support for language servers and integrated terminals compared to classic RStudio.

*   Download the appropriate release for your OS from the [Positron GitHub releases page](https://github.com/posit-dev/positron/releases).
*   Install via terminal: `sudo apt install ./positron-*.deb`

### 2. Initialize the Project and Version Control
Version control (Git) must be initialized at "second zero" to track every change in your configuration. Open your terminal and run:

```bash
# Create the project directory
mkdir icu_mimic_project
cd icu_mimic_project

# Initialize Git tracking
git init

# Launch Positron in the current directory
positron .
```

---

## Phase 3: Bootstrapping the Dependency Engine (`renv` + `pak`)

We need to establish our isolated environment (`renv`) and power it with our fast package manager (`pak`).

### 1. Isolate the Library & Initialize `renv`
In the Positron R console, create a local path for the libraries to strictly isolate this project from your system R installation.

```R
# Create a local library folder
dir.create("r-lib", showWarnings = FALSE)

# Instruct R to use this local folder first
.libPaths(c(normalizePath("r-lib"), .libPaths()))
```

To ensure we don't accidentally commit thousands of package files to our Git repository, create a `.gitignore` file in the root of your folder and add:

```text
# .gitignore
r-lib/*
.Rproj.user
.Rhistory
.RData
.Ruserdata
```

Now, initialize the reproducible environment:

```R
install.packages("renv")
renv::init()
```

### 2. Install `jsonlite` and `pak`
Restart your R session. With `renv` active, install the foundational package manager. `jsonlite` is often a prerequisite for APIs and dependency parsing.

```R
install.packages(c("jsonlite", "pak"))
```

### 3. Marry `renv` with `pak`
By default, `renv` uses standard installation methods. We want to force it to use `pak` for its lightning-fast, parallelized dependency resolution.

Create an `.Renviron` file in your project root to make this setting permanent across sessions:

```text
# .Renviron
RENV_CONFIG_PAK_ENABLED=TRUE
```
*(Restart your R session one more time so it reads the `.Renviron` file).*

---

## Phase 4: Sourcing the Critical Care Stack

Now that the infrastructure is sterile and locked, we use `pak` to install the core analytical suite. 

To dramatically speed up installations on Linux systems by using pre-compiled binaries, create an `.Rprofile` file in your project root and add:

```R
# .Rprofile
options(repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/noble/latest"))
```
*(Note: Adjust the URL based on your specific Ubuntu distribution if not using Ubuntu 24.04 Noble).*

Now, in your Positron R console, install the stack:

```R
pak::pkg_install(c("tidyverse", "targets", "tarchetypes", "ricu", "here", "fs", "gt", "testthat"))
```

### The Analytical Suite Breakdown:
*   **`tidyverse`**: Your primary operative toolset for data wrangling and visualization.
*   **`ricu`**: Provides immediate access to critical care datasets (`mimic.demo`, `eicu.demo`).
*   **`targets` & `tarchetypes`**: The engine of the reproducible pipeline and its extension for seamlessly rendering Quarto documents.
*   **`testthat`**: Essential for unit testing your custom functions (a core RAP principle).
*   **`here` & `fs`**: Geographical anchors. `here::here("data", "patients.csv")` dynamically locates the project root.
*   **`gt`**: For creating publication-ready tables of patient characteristics.

### Lock the Environment
Once the installation is complete, snapshot the environment to lock the parameters:

```R
renv::snapshot()
```
This generates an `renv.lock` file containing the exact hash, version, and repository of every package installed. This file is the "recipe" for your environment.

---

## Phase 5: Constructing the `targets` Pipeline

To adhere to the RAP philosophy, your project structure should be highly organized. 

### 1. Initialize the Pipeline
In the R console, run:

```R
targets::tar_script()
```
This generates the `_targets.R` file, which is the control center for your pipeline. Instead of running linear scripts, you will populate this file with targets (steps) that pull data via `ricu`, clean it with `tidyverse`, and output robust models.

### 2. Recommended Folder Architecture
Organize your project directory like this:

```text
icu_mimic_project/
├── .git/
├── .gitignore
├── .Renviron            # Forces renv to use pak
├── .Rprofile            # Sets fast package repos & activates renv
├── renv/                # The isolated project library
├── renv.lock            # The exact package state recipe
├── _targets.R           # The master pipeline configuration file
├── R/                   # Folder for your custom pure R functions
│   ├── fetch_data.R
│   └── clean_vitals.R
├── tests/               # Unit testing framework
│   └── testthat/
└── reports/             # Quarto documents (.qmd)
```
*Rule of thumb: Write small, modular functions in the `R/` folder, and string them together in `_targets.R`.*

---

## Phase 6: Elevating to Full RAP Status (Functional Programming & Testing)

A critical flaw in basic scripts is the lack of verification. Bruno Rodrigues' *Building reproducible analytical pipelines with R* emphasizes two concepts required to harden your analysis:

1.  **Pure Functions**: Do not rely on global variables. The functions in your `R/` directory should take explicit inputs (like a raw patient data frame) and return explicit outputs (like a cleaned data frame) without side effects.
2.  **Unit Testing (`{testthat}`)**: Just as you calibrate ICU monitors, you must calibrate your code. Use the `{testthat}` package to write tests for your functions (e.g., verifying that `clean_vitals.R` correctly drops biologically impossible heart rates >300 bpm).

---

## Phase 7: The OS-Level Reproducibility Flaw (Docker & Nix)

While `renv` perfectly locks R packages, it **does not** lock the underlying system dependencies (like the Linux libraries installed in Phase 1). If a colleague tries to run your project on a Mac or a 5-year-old CentOS server, it might fail.

To achieve "bit-for-bit" reproducibility:
*   **Docker Containerization:** Package your entire pipeline (OS + R + Packages) into a Docker image. This guarantees it runs identically anywhere.
*   **The Nix Philosophy / `{rix}`:** Modern RAP methodology increasingly advocates for declarative environments using tools like `{rix}`. This manages both system-level binaries and R packages simultaneously, creating an entirely self-contained, reproducible environment independent of the host OS.

---

## Phase 8: Version Control and Sharing

Finally, secure your foundation by committing your code to Git and pushing it to GitHub. This makes your research transparent and accessible.

### Create a repository on GitHub
You can do this manually on github.com, or use the GitHub CLI (`gh`) directly from the terminal:

```bash
gh repo create icu_mimic_project --public --source=. --remote=origin --push
```

### Commit your foundation
Using Positron’s source control tab or the integrated terminal:

```bash
git add .
git commit -m "feat: establish reproducible environment with renv, pak, targets, and test infrastructure"
git push origin main
```

---

## How to Collaborate (The Magic of RAP)

This workflow provides an airtight, deterministic environment. Whenever you decide to share this repository with a colleague (or a future version of yourself on a new laptop), they simply need to:

1. Clone the Git repository.
2. Open it in Positron.
3. Run `renv::restore()` in the console.

R will read the `renv.lock` file and perfectly recreate your exact analytical conditions, downloading the precise package versions you used.

---

## Advisor's Reference Material and Further Reading

To deepen your mastery of this architecture, review the following texts:

1. **Pipeline Philosophy & The Nix Approach:** [Building reproducible analytical pipelines with R](https://raps-with-r.dev/) by Bruno Rodrigues. This is the definitive text on moving from scripts to pipelines, unit testing, and leveraging Nix/Docker for ultimate reproducibility.
2. **The Targets Engine:** [The targets R package user manual](https://books.ropensci.org/targets/). The introductory walkthrough is essential for understanding how to define a pipeline instead of a script.
3. **Critical Care Data:** [The ricu GitHub Repository & Vignettes](https://github.com/eth-mds/ricu). Review their documentation on data concepts to understand how they map complex physiological time-series data into actionable R objects.
4. **Modern Package Management:** [pak documentation](https://pak.r-lib.org/). Explore how it handles parallel HTTP downloads to vastly outperform standard R dependency resolution.
