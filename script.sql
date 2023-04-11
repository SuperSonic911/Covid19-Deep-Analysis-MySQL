CREATE TABLE `coviddeaths` (
  `iso_code` VARCHAR(100),
  `continent` VARCHAR(100),
  `location` VARCHAR(100),
  `date` VARCHAR(100),
  `population` VARCHAR(100),
  `total_cases` VARCHAR(100),
  `new_cases` VARCHAR(100),
  `new_cases_smoothed` VARCHAR(100),
  `total_deaths` VARCHAR(100),
  `new_deaths` VARCHAR(100),
  `new_deaths_smoothed` VARCHAR(100),
  `total_cases_per_million` VARCHAR(102),
  `new_cases_per_million` VARCHAR(102),
  `new_cases_smoothed_per_million` VARCHAR(102),
  `total_deaths_per_million` VARCHAR(102),
  `new_deaths_per_million` VARCHAR(102),
  `new_deaths_smoothed_per_million` VARCHAR(102),
  `reproduction_rate` VARCHAR(102),
  `icu_patients` VARCHAR(102),
  `icu_patients_per_million` VARCHAR(102),
  `hosp_patients` VARCHAR(102),
  `hosp_patients_per_million` VARCHAR(102),
  `weekly_icu_admissions` VARCHAR(102),
  `weekly_icu_admissions_per_million` VARCHAR(102),
  `weekly_hosp_admissions` VARCHAR(102),
  `weekly_hosp_admissions_per_million` VARCHAR(102),
  `total_tests` VARCHAR(102)
);

SHOW VARIABLES LIKE "secure_file_priv";

select * from coviddeaths;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CovidDeaths.csv' 
INTO TABLE coviddeaths
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


CREATE TABLE `covidvaccinations` (
  `iso_code` VARCHAR(102),
  `continent` VARCHAR(102),
  `location` VARCHAR(102),
  `date` VARCHAR(102),
  `total_tests` VARCHAR(102),
  `new_tests` VARCHAR(102),
  `total_tests_per_thousand` VARCHAR(102),
  `new_tests_per_thousand` VARCHAR(102),
  `new_tests_smoothed` VARCHAR(102),
  `new_tests_smoothed_per_thousand` VARCHAR(102),
  `positive_rate` VARCHAR(102),
  `tests_per_case` VARCHAR(102),
  `tests_units` VARCHAR(102),
  `total_vaccinations` VARCHAR(102),
  `people_vaccinated` VARCHAR(102),
  `people_fully_vaccinated` VARCHAR(102),
  `total_boosters` VARCHAR(102),
  `new_vaccinations` VARCHAR(102),
  `new_vaccinations_smoothed` VARCHAR(104),
  `total_vaccinations_per_hundred` VARCHAR(102),
  `people_vaccinated_per_hundred` VARCHAR(102),
  `people_fully_vaccinated_per_hundred` VARCHAR(102),
  `total_boosters_per_hundred` VARCHAR(102),
  `new_vaccinations_smoothed_per_million` VARCHAR(102),
  `new_people_vaccinated_smoothed` VARCHAR(102),
  `new_people_vaccinated_smoothed_per_hundred` VARCHAR(102),
  `stringency_index` VARCHAR(102),
  `population_density` VARCHAR(102),
  `median_age` VARCHAR(102),
  `aged_65_older` VARCHAR(102),
  `aged_70_older` VARCHAR(102),
  `gdp_per_capita` VARCHAR(102),
  `extreme_poverty` VARCHAR(102),
  `cardiovasc_death_rate` VARCHAR(102),
  `diabetes_prevalence` VARCHAR(102),
  `female_smokers` VARCHAR(102),
  `male_smokers` VARCHAR(102),
  `handwashing_facilities` VARCHAR(102),
  `hospital_beds_per_thousand` VARCHAR(102),
  `life_expectancy` VARCHAR(102),
  `human_development_index` VARCHAR(102),
  `excess_mortality_cumulative_absolute` VARCHAR(102),
  `excess_mortality_cumulative` VARCHAR(102),
  `excess_mortality` VARCHAR(102),
  `excess_mortality_cumulative_per_million` VARCHAR(102)
);

select * from covidvaccinations;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CovidVaccinations.csv' 
INTO TABLE covidvaccinations
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;




-- Start of analysis
select * from coviddeaths;
select * from covidvaccinations;

-- genral overview of deaths data
select location, date, population, total_cases, new_cases, total_deaths
from coviddeaths;

-- total cases vs total deaths or percentage for Egypt
-- shows the likelyhood  of would you die if you get Covid
select location, date, total_cases, total_deaths, format(((total_deaths/total_cases)*100),2) AS death_percentage
from coviddeaths
where location = 'egypt';

-- total cases over population in egypt
select location, date, total_cases, population, format(((total_cases/population)*100),2) AS infection_percentage
from coviddeaths
where location = 'egypt';

-- countries with highest infection percentage
-- the FORMAT function returns a string value with the specified format. As a result, the ORDER BY clause is sorting the values as strings, not as numbers.
select location, max((total_cases/population)*100) AS infection_percentage
from coviddeath
group by location
order by infection_percentage DESC;

-- countries with the highest death rates
select location, max((total_cases/population)*100) AS death_percentage
from coviddeaths
group by location
order by death_percentage desc;

-- countries with the highest deaths
-- we had to cast as signed because total deaths is considered a varchar 
SELECT location, max(cast(total_deaths AS Signed)) AS max_deaths
FROM coviddeaths
GROUP BY location
ORDER BY max_deaths DESC;

-- showing continents with highest death counts
select continent, max(cast(total_deaths AS Signed)) AS max_deaths
from coviddeaths
where continent != ''
group by continent
order by max_deaths desc;

-- the entire world's death percentage (from people who got it)
select date,
sum(cast(new_cases as signed)) as total_cases, 
sum(cast(new_deaths as signed)) as total_deaths, 
((sum(cast(new_deaths as signed)) / sum(cast(new_cases as signed))) *100) as death_percentage
from coviddeaths
where continent != ''
group by date
order by total_deaths /*death_percentage*/ desc;

-- total cases and deaths for entire world
select
sum(cast(new_cases as signed)) as total_cases, 
sum(cast(new_deaths as signed)) as total_deaths, 
((sum(cast(new_deaths as signed)) / sum(cast(new_cases as signed))) *100) as death_percentage
from coviddeaths
where continent != '';

-- Let's start with the vaccinations table
select * from covidvaccinations;

-- we can join the 2 tables together for a general overview
select * 
from coviddeaths
join covidvaccinations
on coviddeaths.location = covidvaccinations.location
and coviddeaths.date = covidvaccinations.date;

-- total vaccinated per country
-- this query sums up every country's vaccinations based only on the new vaccinations column to ensure correct data is used
-- some countries have added their data through total_vaccinations only, some with new_vaccinations only
-- so it really depends each country's data, when we work country by country, we have to double check
select coviddeaths.continent, coviddeaths.location, coviddeaths.date, 
coviddeaths.population, covidvaccinations.total_vaccinations, covidvaccinations.new_vaccinations
, sum(cast(new_vaccinations as signed)) over (partition by covidvaccinations.location) as country_all_vaccinations
from coviddeaths
join covidvaccinations
on coviddeaths.location = covidvaccinations.location
and coviddeaths.date = covidvaccinations.date
where coviddeaths.continent !=''
order by coviddeaths.location, STR_TO_DATE(coviddeaths.date, '%m/%d/%Y'); 

-- if we want to find the percentage of population that is vaccinated
-- (country_all_vaccinations/population)*100
-- we can create a view table to store the column of country_all_vaccinations for ease of use
create view all_vaccinations AS
select coviddeaths.continent, coviddeaths.location, coviddeaths.date, 
coviddeaths.population, covidvaccinations.total_vaccinations, covidvaccinations.new_vaccinations
, sum(cast(new_vaccinations as signed)) over (partition by covidvaccinations.location) as country_all_vaccinations
from coviddeaths
join covidvaccinations
on coviddeaths.location = covidvaccinations.location
and coviddeaths.date = covidvaccinations.date
where coviddeaths.continent !=''
order by coviddeaths.location, STR_TO_DATE(coviddeaths.date, '%m/%d/%Y'); 

select location, (all_vaccinations.country_all_vaccinations / population)*100 as percentage_vaccinated2
from all_vaccinations
limit 8000;


-- total population vs vaccinated in United States
select coviddeaths.location, coviddeaths.date, coviddeaths.population, 
covidvaccinations.total_vaccinations, covidvaccinations.new_vaccinations
from coviddeaths
join covidvaccinations
on coviddeaths.location = covidvaccinations.location
and coviddeaths.date = covidvaccinations.date
where coviddeaths.location = 'United States'; /* Egypt didn't aggregate new vaccinations daily, so I had to work with a different country that aggregated consistent data*/

