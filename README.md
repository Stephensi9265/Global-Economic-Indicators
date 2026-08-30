# Global-Economic-Indicators
**Live Interactive App:** [https://stephensi9265.shinyapps.io/global-economy-explorer/](https://stephensi9265.shinyapps.io/global-economy-explorer/)
An interactive R Shiny application for exploring and comparing macroeconomic indicators across countries and regions using World Bank data.
## About the Project
This project originated as a final project for a statistical programming course at UIUC, where the original version used a static built-in dataset that ended in 2017.

I later rebuilt and expanded the application out of an interest in macroeconomic development. The app connects directly to the World Bank API using the WDI package, updating the time series to cover 1960 through 2024. It also adds several new indicators (including PPP-adjusted GDP metrics, trade openness, and life expectancy), custom regional groupings, and built-in statistical testing tools.
## Features
Live Data Ingestion: Downloads data across 200+ countries directly from the World Bank API on startup.  
Predefined Country Groupings: Includes standard World Bank regional aggregates as well as custom groupings (such as Southeast Asia, Europe, Central Asia, Former USSR, and MENA) to make multi-country comparisons faster.  
Interactive Visualizations:Time Series: Multi-country trajectory plots over custom year ranges, with optional logarithmic scaling for population and income metrics.  
Scatterplots: Cross-sectional comparisons between any two indicators with optional log-scale transformations.  
Bar Charts: Single-year horizontal rankings across selected countries.  
Statistical Analysis:Pearson Correlation: Calculates correlation coefficients ($r$), confidence intervals, sample sizes, and $p$-values. 
Linear Regression: Fits an Ordinary Least Squares (OLS) model, displays model summaries and $R^2$, and renders fitted regression lines with standard error bands.  
One-Way ANOVA: Tests for statistically significant mean differences across selected countries or groups.  
Data Table: Interactive, searchable, and sortable data view built with DT.  
## Indicators Included
GDP: Nominal GDP (current US$) and GDP, PPP (current international $)  
GDP per Capita: Nominal GDP per capita and GDP per capita, PPP  
Growth & Labor: Annual GDP growth (%) and Unemployment rate (% of labor force)  
Demographics & Prices: Total Population, Inflation (annual CPI %), and Life Expectancy at birth  
Trade: Trade (% of GDP)
