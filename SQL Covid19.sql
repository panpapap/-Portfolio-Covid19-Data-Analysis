
SELECT * 
FROM PortfolioProject..['CovidDeaths']
order by 3,4

SELECT location, date, total_cases,new_cases, total_deaths, population
From PortfolioProject..['CovidDeaths']
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in Italy
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['CovidDeaths']
where location like '%italy%'
order by 1,2

-- Looking at Total Cases vs Populations
-- Show percentage of population got Covid
SELECT location, date, Population,total_cases,(total_cases/population)*100 as InfectedPercentage
From PortfolioProject..['CovidDeaths']
--where location like '%italy%'
order by 1,2

-- Looking at country with highest infection rate compare to population
SELECT location, Population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as InfectedPercentage
From PortfolioProject..['CovidDeaths']
--where location like '%italy%'
GROUP BY Location, population
order by InfectedPercentage desc

-- Showing Countries wwith Highest Death Count per Population
SELECT location, MAX( cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['CovidDeaths']
--where location like '%italy%'
where continent is not null
GROUP BY Location
order by TotalDeathCount desc

-- Let's break things down by continent
-- Showing the continent with the Highest Death Count

SELECT continent, MAX( cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['CovidDeaths']
--where location like '%italy%'
where continent is not null
GROUP BY continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

SELECT  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(New_cases)*100 as DeathPercentage
From PortfolioProject..['CovidDeaths']
--where location like '%italy%'
where continent is not null
--Group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['CovidDeaths'] dea
Join PortfolioProject..['CovidVaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['CovidDeaths'] dea
Join PortfolioProject..['CovidVaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['CovidDeaths'] dea
Join PortfolioProject..['CovidVaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['CovidDeaths'] dea
Join PortfolioProject..['CovidVaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated