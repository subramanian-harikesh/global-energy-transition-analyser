# Global Energy Transition Analyser

A data analytics portfolio project that models global energy consumption patterns using a structured MySQL database, Python-based data pipelines, and business intelligence dashboards. The project uses real-world data from Our World in Data (OWID) to answer meaningful questions about the energy transition, specifically the global shift from fossil fuels toward renewable energy sources.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Why This Project](#why-this-project)
- [Dataset](#dataset)
- [Project Structure](#project-structure)
- [Project Architecture](#project-architecture)
- [Database Design](#database-design)
- [Analytical Queries](#analytical-queries)
- [Project Phases](#project-phases)
- [Tech Stack](#tech-stack)
- [How to Run This Project](#how-to-run-this-project)
- [Key Findings](#key-findings)
- [Skills Demonstrated](#skills-demonstrated)

---

## Project Overview

This project answers real business questions about global energy:

- Which countries are leading the shift to renewable energy?
- How has coal consumption changed since the Paris Agreement (2016)?
- What is the energy consumption per capita across major economies?
- Which renewable sources are growing the fastest globally?

The project is built end-to-end. Raw data is sourced from OWID, transformed through a structured Python pipeline, stored in a normalized star-schema MySQL database, queried with advanced SQL, and visualized through an exploratory data analysis notebook and Power BI dashboards.

---

## Why This Project

Energy transition is one of the most data-rich and strategically relevant topics for companies like Siemens, ABB, and Schneider Electric. These are organizations that operate at the intersection of industrial infrastructure and sustainable energy systems.

This project was built to mirror real analytical work done in such organizations: designing a database schema, writing production-quality queries, building reusable views and stored procedures, and presenting insights through visualizations and dashboards.

---

## Dataset

**Source:** [Our World in Data - Energy Dataset](https://github.com/owid/energy-data)

**File:** `owid_energy_data.csv`

**Coverage:**
- 23,000+ rows spanning 1900 to 2025
- 130 columns covering energy production, consumption, electricity generation, and per-capita metrics
- Data for 200+ countries and regions

**Key columns used in this project:**

| Column | Description |
|---|---|
| `country` | Country name |
| `year` | Year of observation |
| `coal_consumption` | Total coal consumption (TWh) |
| `solar_consumption` | Total solar consumption (TWh) |
| `wind_consumption` | Total wind consumption (TWh) |
| `renewables_share_energy` | Renewables as % of total energy |
| `gdp` | GDP in USD |
| `population` | Country population |

**Note on data scope:** The database focuses on 10 major economies (India, China, United States, Germany, Brazil, France, Japan, South Africa, Australia, Saudi Arabia) across 2015 to 2022. This scope was chosen deliberately to keep the SQL layer clean and focused on query logic while the Python pipeline handles the full dataset.

---

## Project Structure

```
global-energy-transition-analyser/
│
├── notebooks/
│   └── energy_analysis.ipynb        Phase 3 - EDA and visualizations on energy transition
│
├── pipeline/                        Phase 2 - Python data pipeline
│   ├── load_energy_data.py          Reads CSV, filters, loads into staging table
│   └── transform_energy_data.py     Transforms staging data into star schema tables
│
├── notes/                           Personal reference and learning documentation
│   └── notes.md                     Key patterns, concepts, and syntax notes
│
├── energy_analysis.sql              Phase 1 - Star schema design and 15 analytical queries
├── owid_energy_data.csv             Source dataset from Our World in Data
├── README.md                        Project documentation
├── .gitignore                       Excludes .env and virtual environment from Git
└── LICENSE                          MIT License
```

---

## Project Architecture

```
owid_energy_data.csv
        |
        v
[load_energy_data.py - staging layer]
        |
        v
[owid_energy_raw - raw staging table in MySQL]
        |
        v
[transform_energy_data.py - transformation layer]
        |
        v
[MySQL Database - Star Schema]
dim_country, dim_year, dim_energy_source
fact_consumption, fact_country_meta
        |
        v
[Advanced SQL - Window Functions, CTEs, Stored Procedures, Views]
        |
        v
[energy_analysis.ipynb - EDA, trend analysis, visualizations]
        |
        v
[Power BI / Tableau - Dashboards and Reports]
```

The project is structured in phases so that each layer builds on the previous one. A recruiter or reviewer can inspect each phase independently.

---

## Database Design

The database uses a star schema, which is the industry standard for analytical workloads. It separates descriptive information (dimensions) from measurable facts, making queries efficient and readable.

### Tables

**Dimension Tables** (descriptive context)

| Table | Purpose |
|---|---|
| `dim_country` | Country name, ISO code, region, continent |
| `dim_energy_source` | Source name (coal, solar, wind...), renewable flag, source type |
| `dim_year` | Year, decade, post-Paris Agreement flag |

**Fact Tables** (measurable data)

| Table | Purpose |
|---|---|
| `fact_consumption` | Energy consumption in TWh per country per source per year |
| `fact_country_meta` | Population, GDP, and GDP per capita per country per year |

### Schema Diagram

```
dim_country ─────┐
                 ├──── fact_consumption ────── dim_energy_source
dim_year ────────┘
    |
    └──────────── fact_country_meta
```

### Design Decisions

- UNIQUE KEY constraints on fact tables prevent duplicate entries for the same country-source-year combination.
- Indexes are created on foreign key columns (country_id, source_id, year) to optimize join performance on large datasets.
- is_renewable (boolean) and is_post_paris (boolean) flags enable clean conditional aggregations in SQL without complex string matching.

---

## Analytical Queries

The project includes 15 analytical queries organized in three tiers of complexity.

### Tier 1 - Core Aggregations

| Query | Description |
|---|---|
| Q1 | Total energy consumption per country in 2022 |
| Q2 | Renewable energy consumption by country and source in 2022 |
| Q3 | Energy source with highest total global consumption across all years |

### Tier 2 - Intermediate Analytics

| Query | Description |
|---|---|
| Q4 | Renewable share (%) per country per year |
| Q5 | Year-over-Year growth in total consumption per country (LAG window function) |
| Q6 | Rank countries by renewable consumption in each year (RANK window function) |
| Q7 | Countries whose coal consumption decreased post-Paris Agreement (CTE) |
| Q8 | Running cumulative solar consumption per country over years |

### Tier 3 - Advanced SQL and Reusability

| Query | Description |
|---|---|
| Q9 | Energy consumption per capita (TWh per million people) per country per year |
| Q10 | Top 3 fastest-growing renewable energy sources globally (2019 to 2022) |
| Q11 | Countries where renewable share exceeds fossil share in 2022 (HAVING clause) |
| Q12 | Rolling 3-year average consumption per country (CTE + window function) |
| Q13 | Stored procedure: get full energy profile for any country and year |
| Q14 | View: vw_renewable_energy - reusable renewable summary for Power BI |
| Q15 | CTE chain: countries with both high GDP and high renewable share |

---

## Project Phases

### Phase 0 - Python and Pandas Warm-Up (Completed)
Python fundamentals, OOP, Pandas, NumPy, and Matplotlib practiced on sample energy datasets to prepare for the data pipeline phase.

### Phase 1 - MySQL Database and SQL Analytics (Completed)
- Designed the star schema from scratch
- Seeded the database with realistic data derived from the OWID dataset
- Wrote 15 analytical queries covering aggregations, joins, window functions, CTEs, stored procedures, and views

### Phase 2 - Python Data Pipeline with SQLAlchemy (Completed)
- Read and filtered owid_energy_data.csv using Pandas, covering 10 countries from 2015 to 2022
- Connected Python to MySQL using SQLAlchemy and PyMySQL
- Built a two-script pipeline with a staging loader and a star schema transformer
- Loaded 640 rows into fact_consumption and 80 rows into fact_country_meta automatically
- Used ON DUPLICATE KEY UPDATE for safe inserts that can be run multiple times without errors
- Managed credentials securely using .env and python-dotenv

### Phase 3 - Pandas Analysis and Jupyter Notebook (Completed)
- Connected MySQL to Pandas using SQLAlchemy and pulled star schema data directly into DataFrames
- Performed exploratory data analysis across 10 countries and 8 energy sources
- Built 10 visualizations covering total consumption, renewable vs fossil breakdown, renewable share percentage, global renewable trends, India vs China solar comparison, GDP vs renewable correlation, coal consumption post-Paris Agreement, and a full energy source heatmap
- Documented key findings and a conclusive analysis as markdown cells within the notebook

### Phase 4 - Power BI / Tableau Dashboard (Planned)
- Connect Power BI to the MySQL database or exported view
- Build interactive dashboards for renewable share trends, YoY growth, and per-capita comparisons
- Publish and embed dashboard screenshots in this repository

---

## Tech Stack

| Tool | Purpose |
|---|---|
| MySQL | Relational database and analytical querying |
| Python 3 | Data transformation and pipeline scripting |
| Pandas | CSV reading, data cleaning, transformation, and analysis |
| Matplotlib and Seaborn | Data visualization and chart generation |
| SQLAlchemy | Python-to-MySQL connection layer |
| PyMySQL | MySQL driver used by SQLAlchemy |
| python-dotenv | Secure credential management via .env |
| Jupyter Notebook | Interactive analysis and findings documentation |
| Power BI / Tableau | Dashboard and visualization layer |
| Git and GitHub | Version control and project documentation |

---

## How to Run This Project

### Prerequisites

- MySQL 8.0 or higher installed locally
- Python 3.9 or higher
- pip packages: pandas, sqlalchemy, pymysql, python-dotenv, cryptography, matplotlib, seaborn, jupyter

### Step 1 - Set up the database

Open your MySQL client (Workbench or terminal) and run:

```sql
source energy_analysis.sql;
```

This will create the energy_analyzer database, all tables, indexes, and seed data in one step.

### Step 2 - Configure environment variables

Create a .env file in the project root:

```
DB_USER=root
DB_PASSWORD=yourpassword
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=energy_analyzer
```

### Step 3 - Install dependencies

```bash
pip install pandas sqlalchemy pymysql python-dotenv cryptography matplotlib seaborn jupyter
```

### Step 4 - Run the pipeline

```bash
python pipeline/load_energy_data.py
python pipeline/transform_energy_data.py
```

### Step 5 - Explore the analytical queries

All 15 queries are included in energy_analysis.sql. Run them individually in MySQL Workbench after the USE energy_analyzer; statement.

### Step 6 - Open the analysis notebook

```bash
jupyter notebook notebooks/energy_analysis.ipynb
```

---

## Key Findings

These findings are based on the 10-country dataset covering 2015 to 2022.

- China and the United States are the dominant energy consumers across all sources. Together they consume more than the remaining eight countries combined in oil and natural gas categories.
- Brazil leads in renewable share percentage, driven almost entirely by hydroelectric power. Saudi Arabia sits at zero percent renewable share, making it the most fossil-dependent economy in the dataset and the most exposed to any future carbon reduction policies.
- Solar energy showed the steepest growth globally from 2015 to 2022. A notable dip in 2019 was caused by China cutting solar subsidies in 2018, which disrupted the global solar market and slowed India's trajectory as well since India imports a large share of its solar panels from China.
- The Paris Agreement did not cause an immediate reduction in coal consumption. Real reductions in China and the US appeared two to three years later, driven by domestic air quality concerns and the falling economics of natural gas rather than the international commitment itself.
- Wealth does not strongly correlate with renewable share. Natural resource availability, geography, and domestic policy turned out to be stronger predictors than GDP per capita across this dataset.

---

## Skills Demonstrated

**Database Design**
- Star schema design with dimension and fact tables
- Foreign key constraints and referential integrity
- Composite unique keys to prevent duplicate data
- Index strategy for query optimization

**SQL**
- Multi-table JOINs across a normalized schema
- Conditional aggregations using CASE WHEN
- Window functions: LAG, RANK, SUM OVER, AVG OVER with custom ROWS frames
- Common Table Expressions (CTEs) including chained CTEs
- Stored procedures with input parameters
- Reusable views for BI integration
- HAVING clause for post-aggregation filtering

**Python and Data Engineering**
- CSV reading, filtering, and column selection with Pandas
- Two-stage pipeline design with a staging layer and a transformation layer
- SQLAlchemy for database connectivity and query execution
- Safe idempotent inserts using ON DUPLICATE KEY UPDATE
- Secure credential management with python-dotenv

**Data Analysis and Visualization**
- Exploratory data analysis across multiple dimensions
- Trend analysis, country comparisons, and correlation studies
- Bar charts, line charts, scatter plots, and heatmaps using Matplotlib and Seaborn
- Translating visual patterns into written analytical insights

**Analytical Thinking**
- Translated real-world energy policy questions into SQL queries and Python analysis
- Identified counterintuitive patterns such as wealth not correlating with renewable adoption
- Connected data observations to real-world geopolitical and economic context

---

## About

This project is part of a personal data analytics portfolio built during final-year engineering studies, targeting roles in data analytics and business intelligence. The domain was chosen to reflect the energy and infrastructure industry context relevant to companies like Siemens Smart Infrastructure.

Dataset credit: Hannah Ritchie, Pablo Rosado, Max Roser - Our World in Data Energy Dataset. Licensed under CC BY 4.0.
