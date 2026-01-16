# life-expectancy-panel-data-analysis
Panel data econometric analysis of life expectancy determinants across 167 countries (2000-2016) using Stata

# Life Expectancy Determinants: Panel Data Analysis

Econometric analysis of factors influencing life expectancy across 167 countries using panel data methods (Fixed Effects, Random Effects). Project for Advanced Econometrics I course at University of Warsaw.

## Project Overview

This study examines the relationship between life expectancy at birth and key health, economic, and demographic factors using panel data spanning 2000-2016.

## Research Questions

1. How do mortality rates (infant and adult) affect life expectancy?
2. What is the relationship between national income and life expectancy?
3. Do health expenditures significantly impact life expectancy?
4. How does BMI relate to population longevity?

## Data

**Sample**: 167 countries, 2000-2016 (2,827 observations)

**Sources**: WHO, UNESCO Institute for Statistics

**Variables**:
- **Dependent**: Life expectancy at birth (years)
- **Independent**:
  - `adult_mortality`: Adult mortality rate (deaths per 1,000 aged 15-60)
  - `infant_mort`: Infant mortality rate (deaths per 1,000 live births)
  - `bmi`: Average BMI, age-standardized (kg/m²)
  - `gghed`: Government health expenditure (% of current health expenditure)
  - `che_gdp`: Current health expenditure (% of GDP)
  - `une_gni`: GNI per capita, PPP (current international $)

## Methodology

### Panel Data Models Estimated

1. **Pooled OLS** (baseline)
2. **Random Effects (RE)**
3. **Fixed Effects (FE)**
4. **Two-way Fixed Effects** (with time dummies)

### Model Selection Tests

- **Breusch-Pagan test** (POLS vs RE): χ² = 16,899.24, p < 0.001 -> RE preferred
- **F-test** (POLS vs FE): F = 174.67, p < 0.001 -> FE preferred
- **Hausman test** (RE vs FE): χ² = 322.22, p < 0.001 -> **FE model selected**

### Diagnostic Tests

**Heteroskedasticity**: Wald test rejected homoscedasticity (p < 0.001)

**Autocorrelation**: Wooldridge test detected serial correlation (F = 56.236, p < 0.001)

**Solution**: Robust standard errors (cluster-robust)

**Functional form**: Ramsey RESET test confirmed linear specification

## Final Model: Fixed Effects with Robust SE
```stata
xtreg life_expect adult_mortality infant_mort bmi gghed che_gdp une_gni, ///
     fe vce(robust)
```

### Results

| Variable | Coefficient | Robust SE | t-stat | p-value | Interpretation |
|----------|-------------|-----------|---------|---------|----------------|
| `adult_mortality` | -0.043*** | 0.002 | -131.94 | 0.000 | Higher adult mortality -> lower life expectancy |
| `infant_mort` | -0.098*** | 0.006 | -67.81 | 0.000 | Higher infant mortality -> lower life expectancy |
| `bmi` | -0.340** | 0.104 | -11.44 | 0.000 | Higher BMI -> lower life expectancy |
| `gghed` | 0.129** | 0.041 | 6.85 | 0.000 | Higher gov't health spending -> higher life expectancy |
| `che_gdp` | -0.004 | 0.027 | -0.32 | 0.746 | Not significant |
| `une_gni` | 0.000*** | 0.000 | 22.95 | 0.000 | Higher income -> higher life expectancy |
| Constant | 71.002*** | 2.778 | 93.90 | 0.000 | |

**Model fit**: Within R² = 0.9716, F(6, 2654) = 1,068.06

***, **, * denote significance at 1%, 5%, 10% levels

## Key Findings

### Hypothesis 1: Mortality Indicators (Confirmed)
- **Adult mortality**: Each additional death per 1,000 adults (15-60) reduces life expectancy by **0.043 years**
- **Infant mortality**: Each additional infant death per 1,000 births reduces life expectancy by **0.098 years**
- Both strongly significant (p < 0.001)

### Hypothesis 2: Economic & Health Expenditures (Partially Confirmed)
- **GNI per capita**: Positive and significant (β ≈ 0.00005, p < 0.001)
  - $10,000 increase in GNI -> ~0.5 year increase in life expectancy
- **Government health spending**: Positive and significant (β = 0.129, p < 0.001)
  - 1% increase in gov't health spending share -> 0.13 year increase
- **Total health expenditure (% GDP)**: Not significant (p = 0.746)

### BMI Effect (Unexpected)
- Negative relationship (β = -0.340, p < 0.001)
- Likely driven by developed countries with high obesity rates
- Reflects health challenges in high-income nations

## Policy Implications

1. **Reduce mortality**: Interventions targeting infant and adult mortality have strong impact
2. **Government health spending matters**: Public health investment yields measurable gains
3. **Income effects**: Economic development positively affects longevity
4. **Obesity challenge**: High-income countries face BMI-related health burdens

## Technical Details

### Panel Structure
- N = 2,827 observations
- Countries = 167
- Time periods: avg 16.9 years per country (min 14, max 17)

### Model Advantages
- **Fixed effects** control for time-invariant country characteristics
- **Robust SE** address heteroskedasticity and serial correlation
- **Within estimator** eliminates omitted variable bias from unobserved country effects

## Tools

- **Stata** (primary analysis)
  - Commands: `xtreg`, `xttest`, `hausman`, `xtserial`


## Limitations

- Time-varying omitted variables (e.g., healthcare quality)
- Measurement error in BMI (country averages)
- Potential reverse causality (income / health)
- Missing data for some countries/years

---

**Course**: Advanced Econometrics I (Zaawansowana Ekonometria I)  
**Institution**: University of Warsaw, Faculty of Economic Sciences  

## References

- Deaton A. (2003). Health, income, and inequality. *NBER Reporter*.
- Roser M., Ortiz-Ospina E., Ritchie H. (2019). Life Expectancy. *Our World in Data*.
- WHO (2018). World Health Statistics 2018. World Health Organization.
