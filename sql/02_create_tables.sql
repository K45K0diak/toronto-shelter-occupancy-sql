CREATE TABLE organization (
  ORGANIZATION_ID    integer PRIMARY KEY,
  ORGANIZATION_NAME  text NOT NULL
);

CREATE TABLE location (
  LOCATION_ID           integer PRIMARY KEY,
  ORGANIZATION_ID       integer NOT NULL REFERENCES organization(ORGANIZATION_ID),
  LOCATION_NAME         text,
  LOCATION_ADDRESS      text,
  LOCATION_POSTAL_CODE  text,
  LOCATION_CITY         text,
  LOCATION_PROVINCE     text
);

CREATE TABLE program (
  PROOGRAM_ID             integer PRIMARY KEY,
  LOCATION_ID             integer NOT NULL REFERENCES location(LOCATION_ID),
  PROGRAM_NAME            text,
  SECTOR                  text,
  PROGRAM_MODEL           text,
  OVERNIGHT_SERVICE_TYPE  text,
  PROGRAM_AREA            text,
  CAPACITY_TYPE           text
);

ALTER TABLE program 
RENAME COLUMN PROOGRAM_ID TO PROGRAM_ID;

CREATE TABLE daily_occupancy (
  OCCUPANCY_ID           integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  PROGRAM_ID             integer NOT NULL REFERENCES program(PROGRAM_ID),
  OCCUPANCY_DATE         date NOT NULL,
  SERVICE_USER_COUNT     integer,
  CAPACITY_ACTUAL_BED    integer,
  CAPACITY_FUNDING_BED   integer,
  OCCUPIED_BEDS          integer,
  UNOCCUPIED_BEDS        integer,
  UNAVAILABLE_BEDS       integer,
  CAPACITY_ACTUAL_ROOM   integer,
  CAPACITY_FUNDING_ROOM  integer,
  OCCUPIED_ROOMS         integer,
  UNOCCUPIED_ROOMS       integer,
  UNAVAILABLE_ROOMS      integer,
  OCCUPANCY_RATE_BEDS    numeric,
  OCCUPANCY_RATE_ROOMS   numeric
);