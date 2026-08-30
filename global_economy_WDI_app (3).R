# =============================================================================
# Global Economy Explorer (WDI Version) - Shiny Application
# =============================================================================
# 
# PURPOSE:
# This application allows users to explore macroeconomic indicators from the 
# World Bank using the WDI package. Users can select from various economic
# indicators, filter data by country and year range, visualize trends and 
# relationships, and perform statistical analyses.
#
# DATA SOURCE: World Bank via WDI package (requires internet connection)
# - Hundreds of countries, years 1960-present
# - Indicators: GDP, GDP per capita, GDP growth, Population, Inflation, 
#   Trade (% GDP), Unemployment, Life Expectancy, and more
#
# NOTE: This app downloads data from the World Bank API on startup, which
# may take a few seconds depending on your internet connection.
#
# AUTHOR: Stephen Si
# DATE: 2025.12.28
# =============================================================================

# -----------------------------------------------------------------------------
# SETUP: Install and load required packages
# -----------------------------------------------------------------------------

# Install packages if not already installed
#install.packages("shiny", repos = "https://cloud.r-project.org", quiet = TRUE)
#install.packages("WDI", repos = "https://cloud.r-project.org", quiet = TRUE)
#install.packages("tidyverse", repos = "https://cloud.r-project.org", quiet = TRUE)
#install.packages("DT", repos = "https://cloud.r-project.org", quiet = TRUE)

# Load libraries
library(shiny)
library(WDI)
library(tidyverse)
library(DT)

# -----------------------------------------------------------------------------
# DATA PREPARATION: Download data from World Bank
# -----------------------------------------------------------------------------

# Define indicators to download (code = World Bank indicator code)
# You can find more indicators at: https://data.worldbank.org/indicator
indicators <- c(
  "GDP"            = "NY.GDP.MKTP.CD",      # GDP (current US$)
  "GDP_PPP"        = "NY.GDP.MKTP.PP.CD",   # GDP, PPP (current international $)
  "GDP_per_capita" = "NY.GDP.PCAP.CD",      # GDP per capita (current US$)
  "GDP_per_capita_PPP" = "NY.GDP.PCAP.PP.CD", # GDP per capita, PPP (current international $)
  "GDP_growth"     = "NY.GDP.MKTP.KD.ZG",   # GDP growth (annual %)
  "Population"     = "SP.POP.TOTL",         # Population, total
  "Inflation"      = "FP.CPI.TOTL.ZG",      # Inflation, consumer prices (annual %)
  "Trade_pct_GDP"  = "NE.TRD.GNFS.ZS",      # Trade (% of GDP)
  "Unemployment"   = "SL.UEM.TOTL.ZS",      # Unemployment (% of total labor force)
  "Life_expectancy"= "SP.DYN.LE00.IN"       # Life expectancy at birth (years)
)

# Download data from World Bank (this may take a moment)
message("Downloading data from World Bank... Please wait.")

raw_data <- WDI(
  indicator = indicators,
  country = "all",
  start = 1960,
  end = 2024,
  extra = TRUE  # Include additional country info (region, income level, etc.)
)

# Clean up the data - keep both countries and aggregates in one dataset
econ_data <- raw_data %>%
  as_tibble() %>%
  select(
    Country = country,
    Code = iso2c,
    Year = year,
    Region = region,
    Income_group = income,
    GDP,
    GDP_PPP,
    GDP_per_capita,
    GDP_per_capita_PPP,
    GDP_growth,
    Population,
    Inflation,
    Trade_pct_GDP,
    Unemployment,
    Life_expectancy
  ) %>%
  mutate(
    Country = as.character(Country),
    # Mark whether this is an aggregate or individual country
    Is_aggregate = (Region == "Aggregates")
  )

message("Data download complete!")

# Get list of individual countries
individual_countries <- econ_data %>%
  filter(!Is_aggregate) %>%
  pull(Country) %>%
  unique() %>%
  sort()

# Get list of aggregates (regions, income groups, etc.)
aggregates <- econ_data %>%
  filter(Is_aggregate) %>%
  pull(Country) %>%
  unique() %>%
  sort()

# -----------------------------------------------------------------------------
# CUSTOM REGION DEFINITIONS
# -----------------------------------------------------------------------------
top20_population <- c(
  "India", "China", "United States", "Indonesia", "Pakistan",
  "Nigeria", "Brazil", "Bangladesh", "Russian Federation", "Ethiopia",
  "Mexico", "Japan", "Philippines", "Egypt, Arab Rep.", "Congo, Dem. Rep.",
  "Viet Nam", "Iran, Islamic Rep.", "Turkiye", "Germany", "Thailand"
)

# Top 50 most populous countries (2024 estimates)
top50_population <- c(
  "India", "China", "United States", "Indonesia", "Pakistan",
  "Nigeria", "Brazil", "Bangladesh", "Russian Federation", "Ethiopia",
  "Mexico", "Japan", "Philippines", "Egypt, Arab Rep.", "Congo, Dem. Rep.",
  "Vietnam", "Iran, Islamic Rep.", "Turkey", "Germany", "Thailand",
  "United Kingdom", "Tanzania", "France", "South Africa", "Italy",
  "Kenya", "Myanmar", "Colombia", "Korea, Rep.", "Spain",
  "Argentina", "Uganda", "Algeria", "Sudan", "Iraq",
  "Ukraine", "Canada", "Poland", "Morocco", "Uzbekistan",
  "Angola", "Afghanistan", "Saudi Arabia", "Peru", "Malaysia",
  "Ghana", "Mozambique", "Yemen, Rep.", "Nepal", "Cote d'Ivoire"
)

sea_countries <- c(
  "Brunei Darussalam", "Cambodia", "Indonesia", "Lao PDR", "Malaysia",
  "Myanmar", "Philippines", "Thailand", "Timor-Leste", "Vietnam"
)

# Europe (EU + non-EU European countries, excluding Russia/Belarus and Central Asia)
europe_countries <- c(
  "Albania", "Andorra", "Austria", "Belgium", "Bosnia and Herzegovina",
  "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia",
  "Finland", "France", "Germany", "Greece", "Hungary", "Iceland", "Ireland",
  "Italy", "Kosovo", "Latvia", "Liechtenstein", "Lithuania", "Luxembourg",
  "Malta", "Moldova", "Monaco", "Montenegro", "Netherlands", "North Macedonia",
  "Norway", "Poland", "Portugal", "Romania", "San Marino", "Serbia",
  "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "Ukraine",
  "United Kingdom"
)

# Central Asia (the -stans)
central_asia_countries <- c(
  "Kazakhstan", "Kyrgyz Republic", "Tajikistan", "Turkmenistan", "Uzbekistan"
)

# Former USSR (all 15 post-Soviet states)
former_ussr_countries <- c(
  "Armenia", "Azerbaijan", "Belarus", "Estonia", "Georgia", "Kazakhstan",
  "Kyrgyz Republic", "Latvia", "Lithuania", "Moldova", "Russian Federation",
  "Tajikistan", "Turkmenistan", "Ukraine", "Uzbekistan"
)

# Middle East & North Africa (Arab World minus Sub-Saharan overlap)
# Excludes: Djibouti, Somalia, Comoros, Mauritania, Sudan (which are in SSA)
mena_countries <- c(
  "Algeria", "Bahrain", "Egypt, Arab Rep.", "Iran, Islamic Rep.", "Iraq",
  "Israel", "Jordan", "Kuwait", "Lebanon", "Libya", "Morocco", "Oman",
  "Qatar", "Saudi Arabia", "Syrian Arab Republic", "Tunisia",
  "United Arab Emirates", "West Bank and Gaza", "Yemen, Rep."
)

# Store custom regions in a named list
custom_regions <- list(
  "Top 20 Population (custom)" = top20_population,
  "Top 50 Population (custom)" = top50_population,
  "Southeast Asia (custom)" = sea_countries,
  "Europe (custom)" = europe_countries,
  "Central Asia (custom)" = central_asia_countries,
  "Former USSR (custom)" = former_ussr_countries,
  "Middle East & North Africa (custom)" = mena_countries
)

# Create a combined list with custom regions, aggregates, and countries
all_selections <- list(
  "Custom Regions" = names(custom_regions),
  "World Bank Aggregates" = aggregates,
  "Individual Countries" = individual_countries
)

# Get list of regions and income groups
all_regions <- sort(unique(na.omit(econ_data$Region)))
all_income_groups <- c("All", sort(unique(na.omit(econ_data$Income_group))))

# Define numeric variables available for analysis
numeric_vars <- c("GDP", "GDP_PPP", "GDP_per_capita", "GDP_per_capita_PPP", "GDP_growth", 
                  "Population", "Inflation", "Trade_pct_GDP", "Unemployment", "Life_expectancy")

# Nice labels for dropdown menus (display name = actual column name)
var_choices <- c(
  "GDP (current US$)" = "GDP",
  "GDP, PPP (current intl $)" = "GDP_PPP",
  "GDP per Capita (current US$)" = "GDP_per_capita",
  "GDP per Capita, PPP (current intl $)" = "GDP_per_capita_PPP",
  "GDP Growth (annual %)" = "GDP_growth",
  "Population" = "Population",
  "Inflation (%)" = "Inflation",
  "Trade (% of GDP)" = "Trade_pct_GDP",
  "Unemployment (%)" = "Unemployment",
  "Life Expectancy (years)" = "Life_expectancy"
)

# Reverse lookup: column name -> display label
var_labels <- setNames(names(var_choices), var_choices)

# Define year range
year_range <- range(econ_data$Year, na.rm = TRUE)

# -----------------------------------------------------------------------------
# USER INTERFACE
# -----------------------------------------------------------------------------

ui <- fluidPage(
  
  # Application title
  titlePanel("Global Economy Explorer (WDI)"),
  
  # Subtitle with description
  h4("Explore World Bank Development Indicators", 
     style = "color: gray; margin-bottom: 20px;"),
  
  # Sidebar layout
  sidebarLayout(
    
    # -------------------------------------------------------------------------
    # SIDEBAR PANEL: All user inputs/controls
    # -------------------------------------------------------------------------
    sidebarPanel(
      width = 3,
      
      # --- DATA FILTERING SECTION ---
      h4("Data Selection"),
      
      # Unified country/aggregate selector
      selectizeInput(
        inputId = "selections",
        label = "Select Countries or Aggregates:",
        choices = all_selections,
        selected = c("United States", "China", "Sub-Saharan Africa", "European Union"),
        multiple = TRUE,
        options = list(
          placeholder = "Type to search...",
          maxItems = 15
        )
      ),
      
      # Year range slider
      sliderInput(
        inputId = "year_range",
        label = "Year Range:",
        min = year_range[1],
        max = year_range[2],
        value = c(2000, 2022),
        step = 1,
        sep = ""
      ),
      
      hr(),
      
      # --- VISUALIZATION SECTION ---
      h4("Visualization Options"),
      
      # Plot type selector
      selectInput(
        inputId = "plot_type",
        label = "Plot Type:",
        choices = c(
          "Time Series" = "timeseries",
          "Scatterplot" = "scatter",
          "Bar Chart (Single Year)" = "bar"
        ),
        selected = "timeseries"
      ),
      
      # Variable selector for Y-axis
      selectInput(
        inputId = "var_y",
        label = "Y-Axis Variable:",
        choices = var_choices,
        selected = "GDP_per_capita"
      ),
      
      # Variable selector for X-axis (scatterplot only)
      conditionalPanel(
        condition = "input.plot_type == 'scatter'",
        selectInput(
          inputId = "var_x",
          label = "X-Axis Variable:",
          choices = var_choices,
          selected = "Life_expectancy"
        )
      ),
      
      # Year selector for bar chart
      conditionalPanel(
        condition = "input.plot_type == 'bar'",
        sliderInput(
          inputId = "bar_year",
          label = "Select Year for Bar Chart:",
          min = year_range[1],
          max = year_range[2],
          value = 2020,
          step = 1,
          sep = ""
        )
      ),
      
      # Log scale toggle
      checkboxInput(
        inputId = "log_scale",
        label = "Use Log Scale (for GDP, GDP per capita, Population)",
        value = TRUE
      ),
      
      hr(),
      
      # --- STATISTICS SECTION ---
      h4("Statistical Analysis"),
      
      selectInput(
        inputId = "stat_test",
        label = "Select Analysis:",
        choices = c(
          "Correlation Test" = "correlation",
          "Linear Regression" = "regression",
          "ANOVA (Compare Countries)" = "anova"
        ),
        selected = "correlation"
      ),
      
      selectInput(
        inputId = "stat_var1",
        label = "Variable 1:",
        choices = var_choices,
        selected = "GDP_per_capita"
      ),
      
      conditionalPanel(
        condition = "input.stat_test != 'anova'",
        selectInput(
          inputId = "stat_var2",
          label = "Variable 2:",
          choices = var_choices,
          selected = "Life_expectancy"
        )
      ),
      
      actionButton(
        inputId = "run_stats",
        label = "Run Analysis",
        class = "btn-primary"
      )
    ),
    
    # -------------------------------------------------------------------------
    # MAIN PANEL: Outputs
    # -------------------------------------------------------------------------
    mainPanel(
      width = 9,
      
      tabsetPanel(
        type = "tabs",
        
        # Tab 1: Visualization
        tabPanel(
          "Visualization",
          br(),
          plotOutput("main_plot", height = "500px"),
          br(),
          verbatimTextOutput("plot_info")
        ),
        
        # Tab 2: Statistical Analysis
        tabPanel(
          "Statistics",
          br(),
          h4(textOutput("stats_title")),
          verbatimTextOutput("stats_output"),
          br(),
          conditionalPanel(
            condition = "input.stat_test == 'regression'",
            plotOutput("regression_plot", height = "350px")
          )
        ),
        
        # Tab 3: Data Table
        tabPanel(
          "Data Table",
          br(),
          h4("Filtered Data Summary"),
          verbatimTextOutput("data_summary"),
          br(),
          DTOutput("data_table")
        ),
        
        # Tab 4: About (indicator definitions)
        tabPanel(
          "About Indicators",
          br(),
          h4("World Bank Indicator Definitions"),
          tags$ul(
            tags$li(tags$b("GDP:"), " Gross Domestic Product in current US dollars"),
            tags$li(tags$b("GDP per Capita:"), " GDP divided by midyear population (current US$)"),
            tags$li(tags$b("GDP per Capita, PPP:"), " GDP per capita adjusted for purchasing power parity (current international $). PPP accounts for price differences between countries, making it better for comparing living standards."),
            tags$li(tags$b("GDP Growth:"), " Annual percentage growth rate of GDP at market prices"),
            tags$li(tags$b("Population:"), " Total population based on de facto definition"),
            tags$li(tags$b("Inflation:"), " Annual % change in consumer price index"),
            tags$li(tags$b("Trade (% of GDP):"), " Sum of exports and imports as share of GDP"),
            tags$li(tags$b("Unemployment:"), " Share of labor force without work but seeking employment"),
            tags$li(tags$b("Life Expectancy:"), " Average years a newborn would live under current mortality")
          ),
          br(),
          p("Data source: ", 
            tags$a(href = "https://data.worldbank.org/", "World Bank Open Data", target = "_blank"))
        )
      )
    )
  )
)

# -----------------------------------------------------------------------------
# SERVER LOGIC
# -----------------------------------------------------------------------------

server <- function(input, output, session) {
  
  # ---------------------------------------------------------------------------
  # REACTIVE: Filtered dataset based on user selections
  # ---------------------------------------------------------------------------
  filtered_data <- reactive({
    req(input$selections)
    
    # Expand custom regions into their constituent countries
    expanded_selections <- c()
    for (sel in input$selections) {
      if (sel %in% names(custom_regions)) {
        # This is a custom region - expand to individual countries
        expanded_selections <- c(expanded_selections, custom_regions[[sel]])
      } else {
        # This is a regular country or WB aggregate
        expanded_selections <- c(expanded_selections, sel)
      }
    }
    
    econ_data %>%
      filter(
        Country %in% expanded_selections,
        Year >= input$year_range[1],
        Year <= input$year_range[2]
      )
  })
  
  # ---------------------------------------------------------------------------
  # OUTPUT: Main visualization plot
  # ---------------------------------------------------------------------------
  output$main_plot <- renderPlot({
    req(filtered_data())
    
    df <- filtered_data()
    
    # --- TIME SERIES PLOT ---
    if (input$plot_type == "timeseries") {
      # Remove rows where the selected variable is NA for cleaner lines
      df_plot <- df %>%
        filter(!is.na(.data[[input$var_y]]))
      
      p <- ggplot(df_plot, aes(x = Year, y = .data[[input$var_y]], 
                          color = Country, group = Country)) +
        geom_line(linewidth = 1, na.rm = TRUE) +
        geom_point(size = 1.5, alpha = 0.7, na.rm = TRUE) +
        labs(
          title = paste(var_labels[input$var_y], "Over Time"),
          x = "Year",
          y = var_labels[input$var_y],
          color = "Selection"
        ) +
        theme_minimal(base_size = 14) +
        theme(
          legend.position = "right",
          plot.title = element_text(face = "bold")
        )
      
      if (input$log_scale && input$var_y %in% c("GDP", "GDP_PPP", "GDP_per_capita", "GDP_per_capita_PPP", "Population")) {
        p <- p + scale_y_log10(labels = scales::comma)
      } else {
        p <- p + scale_y_continuous(labels = scales::comma)
      }
    }
    
    # --- SCATTERPLOT ---
    else if (input$plot_type == "scatter") {
      p <- ggplot(df, aes(x = .data[[input$var_x]], y = .data[[input$var_y]], 
                          color = Country)) +
        geom_point(size = 2.5, alpha = 0.6) +
        labs(
          title = paste(var_labels[input$var_y], "vs", var_labels[input$var_x]),
          x = var_labels[input$var_x],
          y = var_labels[input$var_y],
          color = "Selection"
        ) +
        theme_minimal(base_size = 14) +
        theme(
          legend.position = "right",
          plot.title = element_text(face = "bold")
        )
      
      if (input$log_scale) {
        if (input$var_x %in% c("GDP", "GDP_PPP", "GDP_per_capita", "GDP_per_capita_PPP", "Population")) {
          p <- p + scale_x_log10(labels = scales::comma)
        }
        if (input$var_y %in% c("GDP", "GDP_PPP", "GDP_per_capita", "GDP_per_capita_PPP", "Population")) {
          p <- p + scale_y_log10(labels = scales::comma)
        }
      }
    }
    
    # --- BAR CHART ---
    else if (input$plot_type == "bar") {
      bar_df <- df %>%
        filter(Year == input$bar_year) %>%
        arrange(desc(.data[[input$var_y]]))
      
      p <- ggplot(bar_df, aes(x = reorder(Country, .data[[input$var_y]]), 
                               y = .data[[input$var_y]], 
                               fill = Country)) +
        geom_col(show.legend = FALSE) +
        coord_flip() +
        labs(
          title = paste(var_labels[input$var_y], "in", input$bar_year),
          x = "",
          y = var_labels[input$var_y]
        ) +
        theme_minimal(base_size = 14) +
        theme(plot.title = element_text(face = "bold"))
      
      if (input$log_scale && input$var_y %in% c("GDP", "GDP_PPP", "GDP_per_capita", "GDP_per_capita_PPP", "Population")) {
        p <- p + scale_y_log10(labels = scales::comma)
      } else {
        p <- p + scale_y_continuous(labels = scales::comma)
      }
    }
    
    return(p)
  })
  
  # ---------------------------------------------------------------------------
  # OUTPUT: Plot info
  # ---------------------------------------------------------------------------
  output$plot_info <- renderText({
    df <- filtered_data()
    n_obs <- nrow(df)
    n_selections <- length(unique(df$Country))
    year_span <- paste(min(df$Year), "-", max(df$Year))
    
    paste0("Showing ", n_obs, " observations from ", n_selections, 
           " selections (", year_span, ")")
  })
  
  # ---------------------------------------------------------------------------
  # REACTIVE: Statistical analysis results
  # ---------------------------------------------------------------------------
  stats_results <- eventReactive(input$run_stats, {
    req(filtered_data())
    
    df <- filtered_data()
    
    # --- CORRELATION ---
    if (input$stat_test == "correlation") {
      df_clean <- df %>%
        select(all_of(c(input$stat_var1, input$stat_var2))) %>%
        drop_na()
      
      if (nrow(df_clean) < 3) {
        return(list(type = "correlation", 
                    error = "Not enough complete observations for correlation test."))
      }
      
      test_result <- cor.test(
        df_clean[[input$stat_var1]], 
        df_clean[[input$stat_var2]],
        method = "pearson"
      )
      
      return(list(
        type = "correlation",
        var1 = input$stat_var1,
        var2 = input$stat_var2,
        result = test_result,
        n = nrow(df_clean)
      ))
    }
    
    # --- REGRESSION ---
    else if (input$stat_test == "regression") {
      formula <- as.formula(paste(input$stat_var1, "~", input$stat_var2))
      
      df_clean <- df %>%
        select(all_of(c(input$stat_var1, input$stat_var2))) %>%
        drop_na()
      
      if (nrow(df_clean) < 3) {
        return(list(type = "regression", 
                    error = "Not enough complete observations for regression."))
      }
      
      model <- lm(formula, data = df_clean)
      
      return(list(
        type = "regression",
        var1 = input$stat_var1,
        var2 = input$stat_var2,
        model = model,
        summary = summary(model),
        n = nrow(df_clean)
      ))
    }
    
    # --- ANOVA ---
    else if (input$stat_test == "anova") {
      df_clean <- df %>%
        select(Country, all_of(input$stat_var1)) %>%
        drop_na()
      
      if (length(unique(df_clean$Country)) < 2) {
        return(list(type = "anova", 
                    error = "Need at least 2 countries for ANOVA comparison."))
      }
      
      formula <- as.formula(paste(input$stat_var1, "~ Country"))
      model <- aov(formula, data = df_clean)
      
      return(list(
        type = "anova",
        var = input$stat_var1,
        model = model,
        summary = summary(model),
        n = nrow(df_clean),
        n_groups = length(unique(df_clean$Country))
      ))
    }
  })
  
  # ---------------------------------------------------------------------------
  # OUTPUT: Statistics title
  # ---------------------------------------------------------------------------
  output$stats_title <- renderText({
    req(stats_results())
    res <- stats_results()
    
    if (res$type == "correlation") {
      paste("Correlation Test:", var_labels[res$var1], "vs", var_labels[res$var2])
    } else if (res$type == "regression") {
      paste("Linear Regression:", var_labels[res$var1], "~", var_labels[res$var2])
    } else if (res$type == "anova") {
      paste("ANOVA:", var_labels[res$var], "across Countries")
    }
  })
  
  # ---------------------------------------------------------------------------
  # OUTPUT: Statistics output
  # ---------------------------------------------------------------------------
  output$stats_output <- renderPrint({
    req(stats_results())
    res <- stats_results()
    
    if (!is.null(res$error)) {
      cat(res$error)
      return()
    }
    
    # --- CORRELATION OUTPUT ---
    if (res$type == "correlation") {
      cat("=== Pearson Correlation Test ===\n\n")
      cat("Variables:", var_labels[res$var1], "and", var_labels[res$var2], "\n")
      cat("Sample size (complete pairs):", res$n, "\n\n")
      cat("Correlation coefficient (r):", round(res$result$estimate, 4), "\n")
      cat("95% Confidence Interval:", 
          round(res$result$conf.int[1], 4), "to", 
          round(res$result$conf.int[2], 4), "\n")
      cat("t-statistic:", round(res$result$statistic, 4), "\n")
      cat("Degrees of freedom:", res$result$parameter, "\n")
      cat("p-value:", format.pval(res$result$p.value, digits = 4), "\n\n")
      
      r <- res$result$estimate
      if (abs(r) >= 0.7) strength <- "strong"
      else if (abs(r) >= 0.4) strength <- "moderate"
      else if (abs(r) >= 0.2) strength <- "weak"
      else strength <- "very weak"
      
      direction <- ifelse(r > 0, "positive", "negative")
      
      cat("Interpretation: There is a", strength, direction, 
          "correlation between these variables.\n")
    }
    
    # --- REGRESSION OUTPUT ---
    else if (res$type == "regression") {
      cat("=== Linear Regression Results ===\n\n")
      cat("Model:", var_labels[res$var1], "~", var_labels[res$var2], "\n")
      cat("Sample size:", res$n, "\n\n")
      print(res$summary)
      
      cat("\n--- Interpretation ---\n")
      r_squared <- res$summary$r.squared
      cat("R-squared:", round(r_squared, 4), "\n")
      cat("This means", round(r_squared * 100, 1), "% of the variance in", 
          var_labels[res$var1], "\nis explained by", var_labels[res$var2], ".\n")
    }
    
    # --- ANOVA OUTPUT ---
    else if (res$type == "anova") {
      cat("=== One-Way ANOVA Results ===\n\n")
      cat("Dependent variable:", var_labels[res$var], "\n")
      cat("Groups: Countries (", res$n_groups, " levels)\n", sep = "")
      cat("Total observations:", res$n, "\n\n")
      print(res$summary)
      
      p_val <- res$summary[[1]][["Pr(>F)"]][1]
      cat("\n--- Interpretation ---\n")
      if (p_val < 0.05) {
        cat("The p-value is", format.pval(p_val, digits = 4), 
            "(< 0.05), suggesting significant differences\nacross the selected countries.\n")
      } else {
        cat("The p-value is", format.pval(p_val, digits = 4), 
            "(>= 0.05), suggesting no significant differences\nacross the selected countries.\n")
      }
    }
  })
  
  # ---------------------------------------------------------------------------
  # OUTPUT: Regression plot
  # ---------------------------------------------------------------------------
  output$regression_plot <- renderPlot({
    req(stats_results())
    res <- stats_results()
    
    if (res$type == "regression" && is.null(res$error)) {
      df <- filtered_data() %>%
        select(all_of(c(res$var1, res$var2))) %>%
        drop_na()
      
      ggplot(df, aes(x = .data[[res$var2]], y = .data[[res$var1]])) +
        geom_point(alpha = 0.5, color = "steelblue") +
        geom_smooth(method = "lm", se = TRUE, color = "red") +
        labs(
          title = paste("Regression:", var_labels[res$var1], "~", var_labels[res$var2]),
          subtitle = paste("R² =", round(res$summary$r.squared, 3)),
          x = var_labels[res$var2],
          y = var_labels[res$var1]
        ) +
        theme_minimal(base_size = 12)
    }
  })
  
  # ---------------------------------------------------------------------------
  # OUTPUT: Data summary
  # ---------------------------------------------------------------------------
  output$data_summary <- renderPrint({
    df <- filtered_data()
    
    cat("Dataset Summary\n")
    cat("===============\n")
    cat("Countries selected:", length(unique(df$Country)), "\n")
    cat("Year range:", min(df$Year), "-", max(df$Year), "\n")
    cat("Total observations:", nrow(df), "\n\n")
    
    cat("Variable Summaries (non-missing values):\n")
    cat("-----------------------------------------\n")
    
    for (var in numeric_vars) {
      vals <- df[[var]]
      n_valid <- sum(!is.na(vals))
      if (n_valid > 0) {
        cat(sprintf("%-16s: n=%d, min=%.2e, median=%.2e, max=%.2e\n",
                    var, n_valid, min(vals, na.rm = TRUE), 
                    median(vals, na.rm = TRUE), max(vals, na.rm = TRUE)))
      } else {
        cat(sprintf("%-16s: no data available\n", var))
      }
    }
  })
  
  # ---------------------------------------------------------------------------
  # OUTPUT: Data table
  # ---------------------------------------------------------------------------
  output$data_table <- renderDT({
    df <- filtered_data() %>%
      select(Country, Code, Year, Region, Income_group, all_of(numeric_vars)) %>%
      arrange(Country, Year)
    
    datatable(
      df,
      options = list(
        pageLength = 15,
        scrollX = TRUE,
        order = list(list(0, 'asc'), list(2, 'asc'))
      ),
      filter = "top",
      rownames = FALSE
    ) %>%
      formatCurrency(columns = c("GDP", "GDP_PPP", "GDP_per_capita", "GDP_per_capita_PPP"), currency = "$", digits = 0) %>%
      formatRound(columns = c("GDP_growth", "Inflation", "Trade_pct_GDP", 
                              "Unemployment", "Life_expectancy"), digits = 2) %>%
      formatCurrency(columns = "Population", currency = "", digits = 0)
  })
}

# -----------------------------------------------------------------------------
# RUN THE APPLICATION
# -----------------------------------------------------------------------------

shinyApp(ui = ui, server = server)
