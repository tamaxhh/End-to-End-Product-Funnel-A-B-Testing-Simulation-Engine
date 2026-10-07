# Funnel A/B Testing Analysis

## 1. Objective

This project evaluates whether a treatment or variant changed user behavior through a product funnel and whether the observed difference is statistically significant. The analysis combines event-level product data, SQL-based sessionization, funnel conversion metrics, and A/B testing methods to assess the impact of the experiment on conversion and business outcomes.

The core business question is:

- Did the treatment group meaningfully outperform the control group in the funnel?
- If yes, was the lift statistically reliable or likely due to random variation?

## 2. Business Context

The analysis is designed for a digital product / e-commerce funnel where user actions can be tracked across stages such as:

- view
- add-to-cart
- purchase

This kind of experiment is common when a product team tests changes to onboarding flows, pricing, layout, merchandising, or conversion-oriented experiences. In this project, the treatment is evaluated against a baseline control with a focus on funnel completion and conversion efficiency.

## 3. Data and Experiment Design

The data pipeline is built around raw event-level records that contain user identifiers, session identifiers, timestamps, event type, product information, and revenue-related fields.

The project includes:

- raw and cleaned event datasets in `Data/`
- SQL scripts for sessionization and funnel aggregation in `SQL/`
- Python scripts for MySQL ingestion and export in `Python/`
- exploratory and experimental notebook analysis in `Notebooks/`
- summary outputs in `reports/`

### Experiment groups

The repository contains both control and treatment cohorts in the experimental data. Users are assigned to an experiment group, and conversion behavior is compared between the two groups.

## 4. Analytical Workflow

### 4.1 Data ingestion

The workflow loads a cleaned CSV dataset into a MySQL database using `Python/load_data.py`.

This step creates the source table used for sessionization and downstream analysis:

- `A_B_testing_data`

### 4.2 Sessionization

The SQL logic in `SQL/01_sessionization.sql` defines sessions using user activity patterns and a 30-minute inactivity threshold. This ensures events belonging to the same user journey are grouped into a coherent session.

Key logic:

- partition by `user_id`
- order by `event_time`
- compare with the previous event timestamp
- create a new session when the time gap exceeds 30 minutes

### 4.3 Funnel construction

The queries in `SQL/02_Funnel.building.sql` aggregate session-level funnel behavior by converting events into binary stage indicators:

- `viewed`
- `added_to_cart`
- `purchased`

This enables funnel-level metrics such as:

- view-to-cart rate
- cart-to-purchase rate
- overall conversion rate

### 4.4 Analytical table preparation

The analytical table in `SQL/03_Analytical.table.sql` summarizes each session with metrics including:

- `user_session`
- `user_id`
- `session_start`
- `session_end`
- `session_duration_seconds`
- `viewed`
- `added_to_cart`
- `removed_from_cart`
- `purchased`
- `revenue`
- `product_count`

This creates a consistent session-level dataset for experiment comparison.

## 5. Metrics Used

The analysis centers around conversion and session outcomes.

### Core metrics

- conversion rate
- absolute lift
- relative lift
- p-value
- revenue per session
- average order value (AOV)

### Conversion formula

For each group, conversion is measured as:

- Conversion Rate = converted users / total users

Absolute lift is defined as:

- Treatment Conversion - Control Conversion

Relative lift is defined as:

- (Treatment Conversion - Control Conversion) / Control Conversion

## 6. Experiment Results

The final experiment summary is stored in `reports/experiment_results.csv` and `reports/experiment_scorecard.csv`.

### 6.1 Primary conversion metric

| Metric | Control | Treatment | Difference |
|---|---:|---:|---:|
| Conversion Rate | 0.2843 | 0.2932 | +0.0089 |
| Absolute Lift | - | - | +0.8878 percentage points |
| Relative Lift | - | - | +3.12% |

Interpretation:

- Control conversion rate: 28.43%
- Treatment conversion rate: 29.32%
- Absolute lift: 0.89 percentage points
- Relative lift: 3.12%

This indicates that the treatment improved conversion performance in the funnel.

### 6.2 Statistical significance

The experiment output shows a conversion p-value of approximately:

- 1.18e-96

This is effectively zero at practical significance thresholds. Since the p-value is far below 0.05, the difference in conversion rates is statistically significant.

This means the observed increase is unlikely to be due to random noise and is consistent with a real treatment effect.

## 7. Revenue and Commercial Impact

The analysis also evaluated whether the conversion uplift translated into stronger commercial value.

### Revenue per session

The revenue analysis shows:

- Control revenue per session: approximately 1.40
- Treatment revenue per session: approximately 1.40
- Revenue p-value: approximately 0.7469

Interpretation:

- There is no statistically significant difference in revenue per session between the control and treatment groups.
- Although conversion improved, the added sessions did not produce a statistically meaningful revenue lift in this dataset.

This is an important business insight: the treatment improved acquisition or conversion behavior without materially changing revenue per session.

## 8. Funnel Interpretation

The funnel analysis uses stage progression to understand where the treatment is creating value.

Relevant funnel measures include:

- view-to-cart rate
- cart-to-purchase rate
- overall conversion rate

The query in `SQL/02_Funnel.building.sql` measures: 

- sessions where users viewed a product
- sessions where users added to cart
- sessions where users completed purchase

This helps determine whether the lift is driven by earlier-stage engagement or by the final conversion stage.

## 9. Key Conclusions

The analysis supports the following conclusion:

1. The treatment improved conversion performance relative to the control.
2. The effect is statistically significant with a p-value near zero.
3. The absolute lift is modest but meaningful in a large-scale product experiment.
4. The conversion uplift did not translate into a statistically significant change in revenue per session.
5. Therefore, the treatment appears to improve product flow conversion, but the business value depends on whether this uplift is economically meaningful in the broader product context.

## 10. Interpretation for Product Decision-Making

From a product analytics standpoint, the experiment suggests a positive funnel effect. However, decision-makers should ask:

- Is the uplift large enough to justify full rollout?
- Are there downstream effects not captured in the session-level metrics?
- Does the treatment improve customer quality or retention beyond a single purchase event?
- Would a larger revenue or retention metric show value over a longer time window?

In other words, the statistically significant conversion lift is encouraging, but business adoption should also consider customer lifetime value, retention, and long-term monetization.

## 11. Repository Structure

```text
.
├── Data/
│   ├── Cleaned_data/
│   │   └── cleaned_data.csv
│   ├── Raw_data/
│   │   ├── 2019-Dec.csv
│   │   ├── 2019-Nov.csv
│   │   ├── 2019-Oct.csv
│   │   ├── 2020-Feb.csv
│   │   └── 2020-Jan.csv
│   └── SQL_Query_Results/
│       ├── session_metrics.csv
│       └── Session_rates.csv
├── Notebooks/
│   ├── A.B_test_experimentation.ipynb
│   └── exploration.ipynb
├── Python/
│   ├── export_csv.py
│   └── load_data.py
├── SQL/
│   ├── 00_Secure.session.sql
│   ├── 01_sessionization.sql
│   ├── 02_Funnel.building.sql
│   └── 03_Analytical.table.sql
├── reports/
│   ├── experiment_results.csv
│   └── experiment_scorecard.csv
├── requirements.txt
├── README.md
└── venv1/
```

## 12. Tools and Technologies

- Python
- pandas
- NumPy
- SciPy
- statsmodels
- matplotlib
- seaborn
- MySQL
- SQLAlchemy
- Jupyter Notebook

## 13. Setup

### 1. Clone the repository

```bash
git clone https://github.com/<your-username>/<your-repo-name>.git
cd <your-repo-name>
```

### 2. Create a virtual environment

```bash
python -m venv venv
```

On Windows:

```bash
venv\Scripts\activate
```

On macOS/Linux:

```bash
source venv/bin/activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure MySQL

Create a MySQL database named `product_analytics` and update the database credentials in:

- `Python/load_data.py`
- `Python/export_csv.py`

Example:

```python
USER = "root"
PASSWORD = "root12345"
HOST = "localhost"
PORT = "3306"
DATABASE = "product_analytics"
```

## 14. Execution Workflow

### Load raw data into MySQL

```bash
python Python/load_data.py
```

### Run SQL pipeline

Execute the following SQL files in order:

1. `SQL/01_sessionization.sql`
2. `SQL/02_Funnel.building.sql`
3. `SQL/03_Analytical.table.sql`

### Export session metrics

```bash
python Python/export_csv.py
```

### Open analysis notebook

```bash
jupyter notebook Notebooks/A.B_test_experimentation.ipynb
```

## 15. Project Outputs

Generated outputs include:

- `reports/experiment_scorecard.csv`
- `reports/experiment_results.csv`
- `Data/SQL_Query_Results/session_metrics.csv`
- `Data/SQL_Query_Results/Session_rates.csv`

## 16. Final Summary

This project demonstrates a complete product analytics A/B testing workflow from raw event data to sessionization, funnel analysis, and statistical validation. The main takeaway is clear:

- the treatment improved conversion rate significantly
- the uplift is statistically reliable
- the immediate revenue per session impact was not statistically significant

This makes the project a strong example of how experimentation should be interpreted analytically: not just by looking at raw lift, but by combining business signal with significance testing and funnel-level reasoning.

## 17. License

This project is intended for educational and analytical use. If you plan to publish it publicly on GitHub, consider adding a formal license such as MIT or Apache 2.0.

## 18. Contributing

Pull requests and improvements are welcome. Suggested areas include:

- improved segmentation analysis
- cohort analysis by user type
- retention impact analysis
- dashboard visualization using Power BI or Streamlit
- causal interpretation and business case modeling

