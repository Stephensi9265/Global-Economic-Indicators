# Global-Economic-Indicators
**Live Interactive App:** [https://stephensi9265.shinyapps.io/global-economy-explorer/](https://stephensi9265.shinyapps.io/global-economy-explorer/)

An interactive R Shiny application for exploring and comparing macroeconomic indicators across countries and regions using World Bank data.
## About the Project
This project originated as a final project for a statistical programming course at UIUC, where the original version used a static built-in dataset that ended in 2017.

I later rebuilt and expanded the application out of an interest in macroeconomic development. The app connects directly to the World Bank API using the WDI package, updating the time series to cover 1960 through 2024. It also adds several new indicators (including PPP-adjusted GDP metrics, trade openness, and life expectancy), custom regional groupings, and built-in statistical testing tools.
## What you can do
Plot Economic Trends Over Time: Select any combination of countries or regions (e.g., US, China, Southeast Asia) and plot metrics like GDP per Capita, Population, or Inflation from 1960 to 2024. You can toggle a log scale on and off to compare economies of vastly different sizes clearly.  

Test Relationships Between Indicators: Pick any two variables—such as Life Expectancy vs. GDP per Capita—and run statistical models right in the browser:  Linear Regression & Correlation: Get instant Pearson correlation coefficients ($r$), $p$-values, and an Ordinary Least Squares (OLS) regression line with $R^2$ variance explanation and confidence bands.  
One-Way ANOVA: Check whether differences across selected countries or regional groups are statistically significant.  
Compare Cross-Sections & Rankings:Scatterplots: See how two indicators align across multiple nations at once.  
Ranked Bar Charts: Compare and rank countries side-by-side for any single year.  
Explore Live World Bank Data:Pre-Set Regions: Use custom regional bundles (like Southeast Asia, Former USSR, or Top 20 Population) to add dozens of countries in one click.  
Searchable Data Table: Filter, search, and sort raw numbers across 10 development metrics using an interactive DT table. 
## Indicators Included
GDP: Nominal GDP (current US$) and GDP, PPP (current international $)  
GDP per Capita: Nominal GDP per capita and GDP per capita, PPP  
Growth & Labor: Annual GDP growth (%) and Unemployment rate (% of labor force)  
Demographics & Prices: Total Population, Inflation (annual CPI %), and Life Expectancy at birth  
Trade: Trade (% of GDP)
