# Data source

## Dataset

**Daily Shelter & Overnight Service Occupancy & Capacity**  
City of Toronto Open Data Portal

- **Portal page:** https://open.toronto.ca/dataset/daily-shelter-overnight-service-occupancy-capacity/
- **Publisher:** City of Toronto, Shelter & Support Services
- **Licence:** Open Government Licence – Toronto
- **Update frequency:** Daily

## What was used here

- **Period:** 2025-01-01 to 2025-12-31
- **Downloaded:** August 11, 2026
- **Format:** CSV
- **Rows:** 51543

## Why the raw file is not in this repository

The CSV is large and already published by the City under an open licence. Committing tens of megabytes of public data would slow every clone of this repository for no benefit.

Recording the download date is more useful than the file itself, because the City updates this dataset daily. This document identifies exactly which version of the data produced the results reported in the README.

## Reproducing

1. Open the portal page above.
2. Download the CSV for 2025-01-01 to 2025-12-31.
3. Place it in a `data/` folder (excluded by `.gitignore`).
4. Follow the steps in the README under *How to reproduce*.

Note that figures may differ slightly from those reported here if the City has revised historical records since the download date.
