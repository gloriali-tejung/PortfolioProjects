select *
from PortfolioProject..new_coviddeaths
where continent is not null
order by 3, 4


--total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
select country, date, total_cases, total_deaths, 
	(convert(float,total_deaths)/ nullif(convert(float, total_cases),0))*100 as deathpercentage
from PortfolioProject..new_coviddeaths
where country like '%states%'
order by 1, 2


-- total cases vs population
--shows what percentage of population got covid
select country, date, total_cases, population, 
	(convert(float,total_cases)/ nullif(convert(float, population),0))*100 as PercentPopulationInfected
from PortfolioProject..new_coviddeaths
--where country like '%states%'
order by 1, 2



--looking at countries with highest infection rate compared to population
select country, population, MAX(total_cases) as HighestInfectionCount, 
	Max((convert(float,total_cases)/ nullif(convert(float, population),0)))*100 as PercentPopulationInfected
from PortfolioProject..new_coviddeaths
--where country like '%states%'
group by country, population
order by PercentPopulationInfected desc


--showing countries with highest death count per population
select country, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..new_coviddeaths
--where country like '%states%'
where continent is not null
group by country, population
order by TotalDeathCount desc


--break things down by continent
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..new_coviddeaths
--where country like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..new_coviddeaths
--where country like '%states%'
where continent is not null
--group by continent
order by 1,2


--Using CTE
With PopvsVac (Continent, Country, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as(
select dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) 
	over (partition by dea.country
			order by dea.country, dea.date) as RollingPeopleVaccinated
from PortfolioProject..new_coviddeaths dea
join PortfolioProject..new_covidvax vac
 on dea.country = vac.country
 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- temp table
DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Country nvarchar(255),
Date datetime,
Population float,
New_vaccinations float,
RollingPeopleVaccinated float
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.country, dea.date, convert(float, dea.population)
, convert(float, vac.new_vaccinations)
, sum(convert(float, vac.new_vaccinations)) 
	over (partition by dea.country
			order by dea.country, dea.date) as RollingPeopleVaccinated
from PortfolioProject..new_coviddeaths dea
join PortfolioProject..new_covidvax vac
 on dea.country = vac.country
 and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- creating view to store data for later visualizations
Create view PercentPopulationVaccinated as
select dea.continent, dea.country, dea.date, convert(float, dea.population) as population
, convert(float, vac.new_vaccinations) as new_vaccinations
, sum(convert(float, vac.new_vaccinations)) 
	over (partition by dea.country
			order by dea.country, dea.date) as RollingPeopleVaccinated
from PortfolioProject..new_coviddeaths dea
join PortfolioProject..new_covidvax vac
 on dea.country = vac.country
 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*
from PercentPopulationVaccinated