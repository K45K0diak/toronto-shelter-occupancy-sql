# Data dictionary

Every column in the four normalized tables, its type and its meaning.

> **Note:** descriptions marked [VERIFY] are inferred from column names and should be checked against the City's own documentation on the dataset portal page before this file is considered complete.

## organization

Operating agencies. One row per organization.

| Column | Type | Key | Description |
|---|---|---|---|
| organization_id | integer | PK | Identifier assigned by the City |
| organization_name | text | | Name of the operating agency |

## location

Physical buildings. One row per location. **No organization column** — see modelling_decisions.md.

| Column | Type | Key | Description |
|---|---|---|---|
| location_id | integer | PK | Identifier assigned by the City |
| location_name | text | | Site name |
| location_address | text | | Street address |
| location_postal_code | text | | Postal code |
| location_city | text | | City or district |
| location_province | text | | Province |

## program

Services. One row per program. Carries both foreign keys.

| Column | Type | Key | Description |
|---|---|---|---|
| program_id | integer | PK | Identifier assigned by the City |
| location_id | integer | FK → location | The building this program runs in |
| organization_id | integer | FK → organization | The agency operating this program |
| program_name | text | | Program name |
| sector | text | | Population served [VERIFY] |
| program_model | text | | Emergency or transitional [VERIFY] |
| overnight_service_type | text | | Shelter, respite, warming centre [VERIFY] |
| program_area | text | | Service or funding stream [VERIFY] |
| capacity_type | text | | Whether measured in beds or rooms |

## daily_occupancy

One row per program per day.

| Column | Type | Key | Description |
|---|---|---|---|
| occupancy_id | integer | PK | Generated surrogate key |
| program_id | integer | FK → program | The program this record belongs to |
| occupancy_date | date | | Reporting date |
| service_user_count | integer | | People served that night [VERIFY] |
| capacity_actual_bed | integer | | Beds available [VERIFY] |
| capacity_funding_bed | integer | | Beds funded [VERIFY] |
| occupied_beds | integer | | Beds occupied |
| unoccupied_beds | integer | | Beds unoccupied |
| unavailable_beds | integer | | Beds out of service [VERIFY] |
| capacity_actual_room | integer | | Rooms available [VERIFY] |
| capacity_funding_room | integer | | Rooms funded [VERIFY] |
| occupied_rooms | integer | | Rooms occupied |
| unoccupied_rooms | integer | | Rooms unoccupied |
| unavailable_rooms | integer | | Rooms out of service [VERIFY] |
| occupancy_rate_beds | numeric | | Percentage of beds occupied |
| occupancy_rate_rooms | numeric | | Percentage of rooms occupied |

## Notes on NULLs

A program is measured in either beds or rooms, not both. Bed columns are NULL for room-based programs and vice versa. These NULLs mean *not applicable*, not zero — zero occupied beds would be a real measurement.

## Columns dropped from staging

| Column | Why |
|---|---|
| _id | Row number added by the export, not a fact about shelters |