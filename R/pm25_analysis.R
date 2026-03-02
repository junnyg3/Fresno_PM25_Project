# PM2.5 Trend Analysis & Forecasting – Fresno County, CA
# 1. Load Libraries
library(tidyverse)
library(lubridate)
library(forecast)
library(tseries)
library(zoo)
library(ggplot2)



# 2. Load & Filter Raw CSVs for Fresno
# https://aqs.epa.gov/aqsweb/airdata/download_files.html
files <- c(
  "data/daily_88101_2017.csv",
  "data/daily_88101_2018.csv",
  "data/daily_88101_2019.csv",
  "data/daily_88101_2020.csv",
  "data/daily_88101_2021.csv",
  "data/daily_88101_2022.csv",
  "data/daily_88101_2023.csv",
  "data/daily_88101_2024.csv",
  "data/daily_88101_2025.csv"
)

fresno_list <- list()

for (file in files) {
  temp <- read_csv(file,
                   col_types = cols(
                     `Date Local` = col_date(format = "%Y-%m-%d"),
                     `Arithmetic Mean` = col_double(),
                     `State Code` = col_character(),
                     `County Code` = col_character()
                   )) %>%
    select(`Date Local`, `Arithmetic Mean`, `State Code`, `County Code`) %>%
    filter(`State Code` == "06", `County Code` == "019")  # Fresno County
  
  fresno_list[[file]] <- temp
}

# Combine all Fresno data, remove rows with missing dates
pm25_fresno <- bind_rows(fresno_list) %>%
  filter(!is.na(`Date Local`)) %>%
  arrange(`Date Local`)

# view(pm25_fresno)

# Save combined CSV
write_csv(pm25_fresno, "data/pm25_fresno_2017_2025.csv")



# 3. Monthly Aggregation & Fill Missing Months
monthly_pm25 <- pm25_fresno %>%
  rename(Date = `Date Local`, PM25 = `Arithmetic Mean`) %>%
  mutate(YearMonth = floor_date(Date, "month")) %>%
  group_by(YearMonth) %>%
  summarise(mean_PM25 = mean(PM25, na.rm = TRUE)) %>%
  ungroup()

# view(monthly_pm25)

# Fill in missing months with NA
full_months <- seq(min(monthly_pm25$YearMonth),
                   max(monthly_pm25$YearMonth),
                   by = "month")

# view(full_months)

monthly_pm25_full <- tibble(YearMonth = full_months) %>%
  left_join(monthly_pm25, by = "YearMonth") %>%
  arrange(YearMonth)

# view(monthly_pm25_full)



# 4. Plot Monthly Trend
trend_plot <- ggplot(monthly_pm25_full, aes(x = YearMonth, y = mean_PM25)) +
  geom_line(color = "darkred", size = 1) +
  labs(title = "Monthly Average PM2.5 - Fresno County",
       x = "Year",
       y = expression("PM2.5 ("*mu*"g/m"^3*")")) +
  theme_minimal()

ggsave("outputs/trend_plot.png", trend_plot, width = 8, height = 5)



# 5. Create Time Series with Proper Dates
start_year <- year(min(monthly_pm25_full$YearMonth))
start_month <- month(min(monthly_pm25_full$YearMonth))

ts_pm25 <- ts(monthly_pm25_full$mean_PM25,
              frequency = 12,
              start = c(start_year, start_month))

# Interpolate missing months for STL & forecast
ts_pm25_interp <- na.interp(ts_pm25)



# 6. STL Decomposition
decomp <- stl(ts_pm25_interp, s.window = "periodic")

png("outputs/decomposition_plot.png", width = 800, height = 600)
plot(decomp)
dev.off()



# 7. Stationarity Check (ADF Test)
adf_test <- adf.test(ts_pm25_interp)
print(adf_test)



# 8. ARIMA Forecast (12 months ahead)
model <- auto.arima(ts_pm25_interp)
forecast_pm25 <- forecast(model, h = 12)

png("outputs/forecast_plot.png", width = 800, height = 600)
plot(forecast_pm25,
     main = "12-Month PM2.5 Forecast - Fresno County",
     ylab = expression("PM2.5 ("*mu*"g/m"^3*")"))
dev.off()



# 9. Annual Averages vs EPA Standard
annual_avg <- pm25_fresno %>%
  rename(Date = `Date Local`, PM25 = `Arithmetic Mean`) %>%
  mutate(Date = as.Date(Date)) %>%
  mutate(Year = year(Date)) %>%
  group_by(Year) %>%
  summarise(mean_PM25 = mean(PM25, na.rm = TRUE))

annual_plot <- ggplot(annual_avg, aes(x = Year, y = mean_PM25)) +
  geom_line(color = "blue", size = 1) +
  geom_hline(yintercept = 12, linetype = "dashed", color = "red") +
  labs(title = "Annual Average PM2.5 vs EPA Standard",
       y = expression("PM2.5 ("*mu*"g/m"^3*")"),
       x = "Year") +
  theme_minimal()

ggsave("outputs/annual_standard_comparison.png", annual_plot, width = 8, height = 5)



# 10. Rolling Average (6-Month)
monthly_pm25_full$rolling_avg <- rollmean(monthly_pm25_full$mean_PM25, 6, fill = NA)

rolling_plot <- ggplot(monthly_pm25_full, aes(x = YearMonth)) +
  geom_line(aes(y = mean_PM25), color = "gray70") +
  geom_line(aes(y = rolling_avg), color = "darkblue", size = 1) +
  labs(title = "6-Month Rolling Average PM2.5",
       y = expression("PM2.5 ("*mu*"g/m"^3*")"),
       x = "Year") +
  theme_minimal()

ggsave("outputs/rolling_average.png", rolling_plot, width = 8, height = 5)

