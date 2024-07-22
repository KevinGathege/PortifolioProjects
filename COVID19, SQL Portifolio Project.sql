select *
from PortifolioProject..CovidDeaths
order by 3, 4

--select *
--from PortifolioProject..CovidVaccinations
--order by 3, 4

-- Selecting the data that I am going to use

select location, date, total_cases, new_cases, total_deaths, population
from PortifolioProject..CovidDeaths
order by 1,2

-- Looking at Total cases vs Total deaths
-- Showing the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortifolioProject..CovidDeaths
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortifolioProject..CovidDeaths
where location like 'Kenya'
order by 1,2

-- Looking at total cases vs popoulation
-- Showing what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortifolioProject..CovidDeaths
order by 1,2

-- Looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortifolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

-- Showing the countries with heighest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCounts  /* Just converted the data type to integer*/
from PortifolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCounts desc

-- Breaking things down by continent

-- Showing continent with the highest death count

select location, max(cast(total_deaths as int)) as TotalDeathCounts  /* Just converted the data type to integer*/
from PortifolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCounts desc 

-- Global Numbers
-- The death percentage across the whole world on a daily basis

select date, sum(new_cases)as total_cases,sum(cast(new_deaths as int))as total_deaths,
	sum(cast(new_deaths as int)) / sum(new_cases)*100 as DeathPercentage
from PortifolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- The death percentage across the whole world

select sum(new_cases)as total_cases,sum(cast(new_deaths as int))as total_deaths,
	sum(cast(new_deaths as int)) / sum(new_cases)*100 as DeathPercentage
from PortifolioProject..CovidDeaths
where continent is not null

-- Joining the two tables

select *
from PortifolioProject..CovidDeaths as dea
join PortifolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Looking at total poplation vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated /* It sums new_vaccinations for each location separately */
from PortifolioProject..CovidDeaths as dea
join PortifolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE

with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated /* It sums new_vaccinations for each location separately */
from PortifolioProject..CovidDeaths as dea
join PortifolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated / Population)*100
from PopvsVac

-- Using Temp Table

drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated /* It sums new_vaccinations for each location separately */
from PortifolioProject..CovidDeaths as dea
join PortifolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated / Population)*100
from #PercentagePopulationVaccinated

-- Creating view to store data for later visualizations

create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated /* It sums new_vaccinations for each location separately */
from PortifolioProject..CovidDeaths as dea
join PortifolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentagePopulationVaccinated




