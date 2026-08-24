CREATE TABLE staging_shelter (
_ID                      text,
  OCCUPANCY_DATE          text,
  ORGANIZATION_ID         text,
  ORGANIZATION_NAME       text,
  SHELTER_ID			  text,
  SHELTER_GROUP			  text,
  LOCATION_ID             text,
  LOCATION_NAME           text,
  LOCATION_ADDRESS        text,
  LOCATION_POSTAL_CODE    text,
  LOCATION_CITY           text,
  LOCATION_PROVINCE		  text,
  PROGRAM_ID              text,
  PROGRAM_NAME            text,
  SECTOR                  text,
  PROGRAM_MODEL           text,
  OVERNIGHT_SERVICE_TYPE  text,
  PROGRAM_AREA            text,
  SERVICE_USER_COUNT      text,
  CAPACITY_TYPE           text,
  CAPACITY_ACTUAL_BED     text,
  CAPACITY_FUNDING_BED    text,
  OCCUPIED_BEDS           text,
  UNOCCUPIED_BEDS         text,
  UNAVAILABLE_BEDS        text,
  CAPACITY_ACTUAL_ROOM    text,
  CAPACITY_FUNDING_ROOM   text,
  OCCUPIED_ROOMS         text,
  UNOCCUPIED_ROOMS        text,
  UNAVAILABLE_ROOMS       text,
  OCCUPANCY_RATE_BEDS     text,
  OCCUPANCY_RATE_ROOMS    text
);

SELECT COUNT(*) FROM staging_shelter;

SELECT * FROM staging_shelter LIMIT 10;

select "ORGANIZATION_NAME" from staging_shelter limit 20;

select distinct "SECTOR" from staging_shelter;

select distinct "LOCATION_NAME" as Location, "CAPACITY_FUNDING_ROOM" as AvailableCapacity from staging_shelter order by location limit 50;

select "OCCUPIED_BEDS"::integer from staging_shelter where "OCCUPIED_BEDS" != '' limit 30;

select "SECTOR", count(distinct "PROGRAM_ID") as program_count 
from staging_shelter 
group by "SECTOR" 
having count(distinct "PROGRAM_ID") >= 20
order by program_count ASC;

select "OCCUPANCY_RATE_BEDS"
from staging_shelter
where "OCCUPANCY_RATE_BEDS" is not null
limit 40;

select "SECTOR", COUNT(*) filter (where "OCCUPANCY_RATE_BEDS"::numeric >= 95) as occupancy_greater_than_95
from staging_shelter
where "OCCUPANCY_RATE_BEDS" <> ''
group by "SECTOR"
order by occupancy_greater_than_95 desc;

select count("SECTOR") filter (where "SECTOR" = 'Women')
from staging_shelter;

select count(*)
from staging_shelter
where "SECTOR" = 'Women';

select "SECTOR", COUNT("OCCUPANCY_RATE_BEDS")
from staging_shelter
where "OCCUPANCY_RATE_BEDS"::numeric > 95 and "OCCUPANCY_RATE_BEDS" <> ''
group by "SECTOR";

select "SECTOR", COUNT(*) filter (where "OCCUPANCY_RATE_BEDS"::numeric > 95) as occupancy_greater_than_95
from staging_shelter
where "OCCUPANCY_RATE_BEDS" <> ''
group by "SECTOR"
order by occupancy_greater_than_95 desc;

select "SECTOR", COUNT("OCCUPANCY_RATE_BEDS")
from staging_shelter
where "OCCUPANCY_RATE_BEDS"::numeric > 95 and "OCCUPANCY_RATE_BEDS" <> ''
group by "SECTOR"
order by  COUNT(*) filter (where "OCCUPANCY_RATE_BEDS"::numeric > 95) DESC
;

select "PROGRAM_ID", count(distinct "LOCATION_ID") as numberoflocations
from staging_shelter
group by "PROGRAM_ID"
having count(distinct "LOCATION_ID")>1;

select "LOCATION_ID", count(distinct "ORGANIZATION_ID") as numberoforgs
from staging_shelter
group by "LOCATION_ID"
having count(distinct "ORGANIZATION_ID") > 1;

select "ORGANIZATION_ID", count(distinct "ORGANIZATION_NAME") as numberoforgs
from staging_shelter
group by "ORGANIZATION_ID" 
having count(distinct "ORGANIZATION_NAME")>1
;

select count(distinct "SHELTER_ID"), count(distinct "LOCATION_ID")
from staging_shelter;

select "PROGRAM_ID", count(distinct "PROGRAM_NAME") as "program(s)"
from staging_shelter
group by "PROGRAM_ID"
having count(distinct "PROGRAM_NAME") > 1;

select count(*) as numberofentries
from staging_shelter
where "ORGANIZATION_ID" = '' or "SHELTER_ID" = '' or "LOCATION_ID" = '' or "PROGRAM_ID" = '';

CREATE TABLE organization (
  ORGANIZATION_ID    integer PRIMARY KEY,
  ORGANIZATION_NAME  text NOT NULL
);

