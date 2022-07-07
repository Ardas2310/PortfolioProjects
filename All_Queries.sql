-- Select *

Select *
from  PortfolioProject..CovidVaccinations
where continent is not null
order by 3,4


Select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select Data that we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total cases vs Total Deaths
Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select Location, date,Population , total_cases, (total_cases/Population)*100 as InfectedPopulationPercentage
from PortfolioProject..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2


-- Looking at Countres with Highest Infection Rate compared to Population
Select Location ,Population , MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPopulationPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by Location ,Population
order by InfectedPopulationPercentage desc


-- Showing Countries with Highest Death Count per Population
Select Location , MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by Location 
order by TotalDeathCount desc


-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent 
order by TotalDeathCount desc


-- Global Numbers
Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentageGlobally
from PortfolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2 


-- Looking at Total Population vs Vaccinations

Select dea.continent , dea.location, dea.date , dea.population , vac.new_vaccinations
, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,dea.date) as PeopleVaccinated
--, (PeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE
With PopvsVac ( Continent, Location, Date, Population, New_vaccinations, PeopleVaccinated)
as
(Select dea.continent , dea.location, dea.date , dea.population , vac.new_vaccinations
, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,dea.date) as PeopleVaccinated
--, (PeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (PeopleVaccinated/Population)*100
From PopvsVac 



-- TEMP TABLE


Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent , dea.location, dea.date , dea.population , vac.new_vaccinations
, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,dea.date) as PeopleVaccinated
--, (PeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * , (PeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations


Create view PercentPopulationVaccinated as
Select dea.continent , dea.location, dea.date , dea.population , vac.new_vaccinations
, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,dea.date) as PeopleVaccinated
--, (PeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select * 
From PercentPopulationVaccinated