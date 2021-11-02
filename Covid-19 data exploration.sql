/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From [portfolio project]..['covid-deaths_data$']
Where continent is not null 
order by  continent, date

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From [portfolio project]..['covid-deaths_data$']
Where continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
from [portfolio project].dbo.['covid-deaths_data$']
--Where location like '%canada%'
order by location, date desc

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths,
		(total_deaths/total_cases)*100 AS death_percentage
from [portfolio project].dbo.['covid-deaths_data$']
where continent is not null
-- AND location LIKE '%canada%'
ORDER BY date DESC;

-- Sorting countries based on their infection_rate
select location, population,
		MAX(total_cases) AS Highest_Infection_count,
		Max((total_cases/population)*100) AS Highest_infection_rate
from [portfolio project].dbo.['covid-deaths_data$']
GROUP BY location, population
ORDER BY Highest_infection_rate DESC;

-- Sorting countries based on their Death_per_Population_rate
select location, population,
		MAX(cast(total_deaths as int)) AS Highest_Death_count,
		Max(cast(total_deaths as int)/population*100) AS Highest_Death_rate
from [portfolio project].dbo.['covid-deaths_data$']
WHERE continent is not null
GROUP BY location, population
ORDER BY Highest_Death_rate DESC

-- BREAKING THINGS DOWN BY CONTINENT

-- Sorting continents based on their infection_rate
select continent,
		MAX(total_cases) AS Highest_Infection_count,
		Max((total_cases/population)*100) AS Highest_infection_rate
from [portfolio project].dbo.['covid-deaths_data$']
WHERE continent is not null
GROUP BY continent
ORDER BY Highest_infection_rate DESC;



-- Sorting continent based on their Death_per_Population_rate

SELECT continent,
		max(cast(total_deaths as int)) AS Highest_Death_Count,
		max(cast(total_deaths as int)/population * 100) as Highest_Death_rate
from [portfolio project].dbo.['covid-deaths_data$']
WHERE continent is not null
GROUP BY continent
ORDER BY Highest_Death_rate DESC

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [portfolio project].dbo.['covid-deaths_data$']
where continent is not null 
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [portfolio project].dbo.['covid-deaths_data$'] dea
Join [portfolio project]..['covid-vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by dea.location, dea.date


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVaccination,
vac.people_vaccinated as vaccinated_population,
vac.people_fully_vaccinated as fully_vaccinated_population

From [portfolio project].dbo.['covid-deaths_data$'] dea
Join [portfolio project]..['covid-vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

)
Select *, (vaccinated_population/population)*100 as vaccinated_population_rate, (fully_vaccinated_population/population)*100 as fully_vaccinated_population_rate
From PopvsVac
--WHERE location = 'canada'

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccination numeric,
vaccinated_population numeric,
fully_vaccinated_population numeric

)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVaccination,
vac.people_vaccinated as vaccinated_population,
vac.people_fully_vaccinated as fully_vaccinated_population
From [portfolio project].dbo.['covid-deaths_data$'] dea
Join [portfolio project]..['covid-vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (vaccinated_population/population)*100 as vaccinated_population_rate, (fully_vaccinated_population/population)*100 as fully_vaccinated_population_rate
From #PercentPopulationVaccinated
order by location, date


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVaccination,
vac.people_vaccinated as vaccinated_population,
vac.people_fully_vaccinated as fully_vaccinated_population
From [portfolio project].dbo.['covid-deaths_data$'] dea
Join [portfolio project]..['covid-vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

SELECT *
FROM PercentPopulationVaccinated