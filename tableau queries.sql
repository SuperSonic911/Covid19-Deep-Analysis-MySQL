-- total cases, deaths around the world
select 
sum(cast(new_cases as signed)) as total_cases, 
sum(cast(new_deaths as signed)) as total_deaths, 
((sum(cast(new_deaths as signed)) / sum(cast(new_cases as signed))) *100) as death_percentage
from coviddeaths
where continent != ''
order by total_deaths /*death_percentage*/ desc;


-- total deaths per continent
select location,
sum(cast(new_deaths as signed)) as total_deaths
from coviddeaths
where continent = ''
and location not in ('low income', 'lower middle income', 'upper middle income', 'high income','World', 'European Union', 'International')
group by location
order by total_deaths desc;

-- percent of population infected per country
select location, population, max(cast(total_cases as signed)) as HighestInfectionCount, max((cast(total_cases as signed)/ cast(population as signed))) * 100 as PercentPopulationInfected
from coviddeaths
group by location, population
order by percentpopulationinfected desc;

-- daily infected by country
select location, population, date, max(cast(total_cases as signed)) as HighestInfectionCount, max((cast(total_cases as signed)/ cast(population as signed))) * 100 as PercentPopulationInfected
from coviddeaths
group by location, population, date
order by percentpopulationinfected desc;















