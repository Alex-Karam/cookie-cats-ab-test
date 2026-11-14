# Cookie Cats A/B Test

**MySQL Workbench · Python / Jupyter · Power BI**

Did moving the first progression gate from level 30 to level 40 change day-7 retention? I analysed the Cookie Cats experiment to estimate the difference and decide whether the evidence justified moving the gate.

[Power BI report (PDF)](Cookie%20Cats%20A-B%20Test.pdf) · [Analysis notebook](01_cookie_cats_analysis.ipynb) · [Group summary (CSV)](data/retention_by_gate.csv)

## Data and definitions

The public CSV contains 90,189 records from players who installed Cookie Cats during the experiment. The source describes random assignment at install to the level-30 control (`gate_30`) or the level-40 variant (`gate_40`). The unit of analysis is one player, identified by `userid`. [Kaggle dataset](https://www.kaggle.com/datasets/mursideyarkin/mobile-games-ab-testing-cookie-cats) · [Source walkthrough](https://www.kaggle.com/code/mursideyarkin/mobile-games-ab-testing-with-cookie-cats)

Day-7 retention is the share of all players assigned to each group who returned to play on day 7 after install, as recorded in `retention_7`. Day-1 retention uses the same denominator and the day-1 flag. Both rates include players who may never have reached the gate. The file also records rounds played during the first 14 days after install. Gate exposure is unavailable.

## Method

1. In MySQL, I loaded the five columns as text, checked player IDs, assignments and outcome flags, and counted assignments and returns by group.
2. In Python, I read the source CSV independently, reconciled both groups’ counts against SQL and estimated the day-7 difference as level 40 minus level 30. The 95% confidence interval uses a normal approximation with separate variances for two independent proportions. A Pearson chi-square check compares observed group counts with a hypothetical independent 50:50 allocation.
3. In Power BI, I imported the two-row SQL summary and calculated day-7 retention by dividing total day-7 returners by total assigned players within each group.

## Cookie Cats results

| Assigned group | Players | Day-1 returns | Day-1 retention | Day-7 returns | Day-7 retention |
| --- | ---: | ---: | ---: | ---: | ---: |
| Level 30 | 44,700 | 20,034 | 44.82% | 8,502 | 19.02% |
| Level 40 | 45,489 | 20,119 | 44.23% | 8,279 | 18.20% |

Day-7 retention was **0.82 percentage points lower** in the level-40 group (95% CI for level 40 minus level 30, **−1.33 to −0.31 pp**). That is about **eight fewer day-7 returners per 1,000 assigned players**. Day-1 retention provides supporting context.

**Decision.** Keep the level-30 gate for now. The observed difference favours level 30, and the available data leave questions about assignment and follow-up. Confirm the planned allocation and check the assignment logs and outcome coverage. If those records are unavailable and the decision is worth revisiting, rerun the test with a documented allocation, complete follow-up, and an agreed minimum change worth acting on.

## Validation

- MySQL loaded 90,189 rows with zero warnings or skipped rows. The staging checks found 90,189 distinct player IDs and zero invalid IDs, assignments or retention flags.
- Python reproduced all six SQL counts for assignments and day-1 and day-7 returns. A fresh-kernel run reproduced the analysis and environment versions.
- Both Power BI labels match SQL and Python. The one-page PDF was visually checked at actual size for scale and clipping. [Reviewed PDF](Cookie%20Cats%20A-B%20Test.pdf)

## Limitations

- The observed split was 49.56% level 30 and 50.44% level 40. It would be unusual under independent 50:50 assignment (p = 0.0086). The exact planned allocation is unverified. The CSV has no assignment logs to explain the split or install timestamps and coverage metadata to verify complete day-7 follow-up. The confidence interval captures sampling uncertainty under the analysis assumptions.
- The estimate compares players by assigned group. The CSV cannot establish the effect among players who reached the gate. A rollout decision would also require a practical threshold and any relevant product trade-offs, such as longer-term retention or revenue, which are unavailable here.

## Reproduction

1. Download and extract `cookie_cats.csv` from Kaggle. Save a copy under `data/raw/` at the repository root. The analysed file has SHA-256 `5ab54d761fbddcd50de7b88e4eaf7837cba4569474f50c043a4d17ee342c46bd`. [Source CSV download](https://www.kaggle.com/datasets/mursideyarkin/mobile-games-ab-testing-cookie-cats)
2. In MySQL Workbench, run the settings and staging scripts, then copy the CSV to the server import directory reported by `secure_file_priv`. The load script uses the verified Windows MySQL 8.0 Uploads path. Adjust that path for your setup and run the load once on an empty staging table. Run the validation script and export its final result grid to `data/retention_by_gate.csv`. [01 Import settings](sql/01_check_import_settings.sql) · [02 Staging schema](sql/02_create_staging.sql) · [03 Load](sql/03_load_staging.sql) · [04 Validation and retention](sql/04_validate_staging.sql)
3. In a Python 3.14.6 environment, install the [notebook dependencies](requirements.txt) with `python -m pip install -r requirements.txt`. Launch `jupyter notebook 01_cookie_cats_analysis.ipynb` from the repository root in an environment with Jupyter Notebook installed. Restart the kernel and run all cells. The SQL workflow was verified on MySQL 8.0.46 and the notebook was verified with pandas 3.0.3 and ipykernel 6.31.0.
4. To rebuild the Power BI comparison, import the [group summary](data/retention_by_gate.csv) and the [portfolio theme](power-bi/Portfolio_Base_Theme.json). Use a 1920 × 1080 canvas and a horizontal bar chart with `version` on the Y-axis and this measure on the X-axis. Format the measure as a percentage with two decimals and enable direct value labels. Export from **View → Page view → Actual size**.

```dax
Day-7 retention =
DIVIDE(
    SUM(retention_by_gate[day_7_returns]),
    SUM(retention_by_gate[assigned_players])
)
```

## Attribution

Source data and experiment context come from *Mobile Games A/B Testing - Cookie Cats*, shared on Kaggle by Mürşide Yarkın and associated with the DataCamp Cookie Cats exercise. Readers can obtain the raw CSV through Kaggle. Redistribution terms for the raw file could not be verified. [Kaggle source](https://www.kaggle.com/datasets/mursideyarkin/mobile-games-ab-testing-cookie-cats) · [Experiment dataset survey](https://arxiv.org/abs/2111.10198)

I ran the analysis in MySQL Workbench and Jupyter, built the Power BI report, and checked the outputs across all three tools. The code and documentation were developed with AI assistance.

## Proposed experiment — Driver onboarding

**Question.** Would a simpler onboarding flow help more new driver applicants complete their first trip? Randomly assign eligible applicants 1:1 when they start onboarding. Compare the current flow with a simplified flow that clarifies steps and removes redundant prompts. Both flows use the same required verification checks.

- **Primary metric.** The share of all assigned applicants in each group who complete their first trip within seven days of assignment. Keep applicants who never finish verification or never take a trip in the denominator.
- **Guardrail.** Driver-initiated cancellations divided by all trips accepted by drivers in each assigned group during their first seven days after assignment. Follow those accepted trips to their final status. Account for drivers contributing multiple trips when estimating uncertainty.
- **Sample size.** Use the historical seven-day first-trip rate and agree on the smallest absolute lift that would justify the cost of building and supporting the new flow. Estimate applicants per group for a two-sided comparison of proportions at 5% significance and 80% power. Check whether the cancellation guardrail needs a larger sample, using historical trip volumes and a pre-agreed maximum increase.
- **Rollout.** Read the results once the planned sample has complete follow-up. Verify the assignment split and outcome logging. Roll out gradually if the estimated lift meets the agreed minimum, its 95% confidence interval excludes zero in the positive direction, and the upper confidence bound for the cancellation-rate increase stays below the agreed limit. Otherwise keep the current flow.

This is a hypothetical test design. It has no observed results.
