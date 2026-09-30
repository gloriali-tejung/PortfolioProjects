/*

Queries used for Tableau Project

*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..new_coviddeaths
--Where country like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  country


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select continent, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..new_coviddeaths
--Where country like '%states%'
Where continent is not null 
and country not in ('World', 'European Union', 'International')
Group by continent
order by TotalDeathCount desc


-- 3.

Select country, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..new_coviddeaths
Where continent is not null
Group by country, Population
order by PercentPopulationInfected desc


-- 4.


Select country, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..new_coviddeaths
Where continent is not null
Group by country, Population, date
order by PercentPopulationInfected desc


-- additional queries --

-- 5.

--Select country, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..new_coviddeaths
----Where country like '%states%'
--where continent is not null 
--order by 1,2

-- took the above query and added population
Select country, date, population, total_cases, total_deaths
From PortfolioProject..new_coviddeaths
--Where country like '%states%'
where continent is not null 
order by 1,2


-- 6. 

With PopvsVac (Continent, country, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.country Order by dea.country, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..new_coviddeaths dea
Join PortfolioProject..new_covidvax vac
	On dea.country = vac.country
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac


-- 7. 

Select country, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..new_coviddeaths
--Where country like '%states%'
Group by country, Population, date
order by PercentPopulationInfected desc



