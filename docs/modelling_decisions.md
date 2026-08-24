# Modelling decisions

How the schema for this project was established, including a design that the data disproved.

## The first model

A four-level chain:

```
organization -> location -> program -> daily_occupancy
```

with `organization_id` stored as a column on `location`. It looked reasonable. It encoded a claim: **each building belongs to one operator.**

## How it was disproved

The migration into `location` failed:

```
ERROR: duplicate key value violates unique constraint "location_pkey"
Detail: Key (location_id)=(1125) already exists.
```

`location_id` is declared `PRIMARY KEY`, so the table permits exactly one row per location. But `SELECT DISTINCT` including `organization_id` produced **three** rows for location 1125 — identical name, address, postal code, city and province, differing only in the operating organization.

The constraint was not malfunctioning. It was refusing to store a contradiction that my own design had created.

## Investigation

Rather than suppressing the error, I wrote diagnostic queries to establish what the relationships actually were.

| Test | Result | What it established |
|---|---|---|
| Programs with more than one organization | Zero rows, dataset-wide | Organization is a stable attribute of a program |
| Location 1125 organizations | Three (6, 15, 26) | Identical address details; only the operator varied |
| Locations with more than one detail combination, organization removed | Zero rows | Every location_id resolves to exactly one physical place |
| Location 1155 | Two programs, two organizations | Org 11 / program 17751 Jan–May; org 36 / program 18891 Jul–Dec |
| Program 18891 | Two locations | 1761 (Jun 20 – Jul 2), then 1155 (Jul 3 – Dec 31), same organization |

A key detail: grouping location against organization made the relationship look many-to-many. Grouping collapses time and hides the program layer. Broken down by program, each program had exactly one organization, with zero exceptions across the dataset.

## The corrected model

```
   Organization                    Location
   (who runs it)              (a physical building)
        |                              |
        +--------------+---------------+
                       |
                    Program
              (carries both keys)
                       |
                Daily_Occupancy
```

Organization and location are independent parents of program. `location` has no `organization_id` column.

**The reasoning in one sentence:** a building has an address; it does not have an operator. What has an operator is the program running inside it.

195 Princes' Boulevard hosted six programs across 2025 under three different agencies. Asking the building to name one operator had three valid answers, and a primary key holds one.

## Consequences

| Anomaly | Resolution |
|---|---|
| Location 1125, three organizations | One `location` row. The organizations travel to `program`, attached to their six programs. Nothing lost. |
| Location 1155, two organizations | One `location` row. Org 11 links to program 17751, org 36 to program 18891. |
| Program 18891 at two locations | Not fully representable. `program` holds one `location_id`, so the July relocation is recorded as its final site only. |
| Locations 1761 and 1155 | Same building at 4584 Kingston Road, recorded twice across a rename. Both rows retained — the source recorded them separately, and merging would misrepresent it. |

## What I would do differently

Test relationship assumptions before building tables, not after. The queries that established the correct model would have taken twenty minutes at the design stage. Running them only after a constraint error cost considerably more.

The wider lesson: a constraint error is not a bug. It is the database catching a contradiction between your design and your data, and it is the most specific feedback available.