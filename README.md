# PM2.5 Trend Analysis & Forecasting – Fresno County, CA

## Project Overview

This project analyzes long-term trends in **fine particulate matter (PM2.5)** for **Fresno County, California** using publicly available data from the **U.S. EPA Air Quality System (AQS)**.

The analysis combines daily PM2.5 data from **2017–2025**, performs **time-series modeling**, **seasonal decomposition**, and **ARIMA forecasting**, and evaluates air quality relative to the **EPA annual standard (12 µg/m³)**.

This project demonstrates applied skills in:

- Environmental data analysis  
- Time-series modeling  
- Statistical forecasting  
- Data visualization in R  

---

## Data Source

Daily PM2.5 monitoring data were downloaded from:

**EPA Air Quality System (AQS) Data Mart**  
https://aqs.epa.gov/aqsweb/airdata/download_files.html  

- **Parameter Code:** 88101 (PM2.5 Mass)  
- **State Code:** 06 (California)  
- **County Code:** 019 (Fresno County)  

Only Fresno County observations were retained and aggregated for analysis.

---

## Tools & Packages Used

- **R**
- `tidyverse` – data wrangling  
- `lubridate` – date handling  
- `forecast` – ARIMA modeling & interpolation  
- `tseries` – Augmented Dickey-Fuller (ADF) test  
- `zoo` – rolling averages  
- `ggplot2` – visualization  

---

## Project Workflow

### 1. Data Preparation

- Loaded annual daily PM2.5 CSV files (2017–2025)
- Filtered for Fresno County (State Code 06, County Code 019)
- Combined all years into a single dataset
- Removed missing date values
- Saved cleaned dataset: data/pm25_fresno_2017_2025.csv


---

### 2. Monthly Aggregation

- Converted daily observations into monthly averages
- Generated a complete monthly sequence
- Filled missing months with `NA` to preserve proper time indexing

---

### 3. Time Series Construction

- Created a monthly time series object
- Interpolated missing months using `na.interp()`
- Ensured correct date alignment for modeling and plotting

---

### 4. STL Decomposition

Performed **Seasonal-Trend Decomposition using Loess (STL)** to separate:

- **Trend** → Long-term pollution changes  
- **Seasonal** → Recurring annual patterns  
- **Remainder** → Irregular fluctuations (e.g., wildfire events)  

Output: outputs/decomposition_plot.png


---

### 5. Stationarity Testing

Performed **Augmented Dickey-Fuller (ADF) test** to evaluate time series stationarity.

---

### 6. ARIMA Forecasting

- Used `auto.arima()` to select optimal model parameters
- Forecasted PM2.5 concentrations **12 months ahead**
- Generated confidence intervals for prediction uncertainty

Output: outputs/forecast_plot.png


---

### 7. Annual Averages vs EPA Standard

Calculated annual mean PM2.5 concentrations and compared them to the:

**EPA Annual PM2.5 Standard: 12 µg/m³**

Output: outputs/annual_standard_comparison.png


---

### 8. Rolling Average Analysis

Computed a **6-month rolling average** to smooth short-term variability and highlight long-term trends.

Output: outputs/rolling_average.png
