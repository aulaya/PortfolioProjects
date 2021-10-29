Select *
From PortfolioProject..CovidDeaths$
--Where location like '%italy%'

Select location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths$

--Looking at Total Cases vs Total Deaths (percentage of dead who got infected)
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths$
Order by 1,2

--Looking at what percentage of population got covid
Select location, date, population,total_cases, (total_cases/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths$
Order by 1,2 

--Looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths$
Group by location, population
Order by InfectionPercentage desc

Select location, date, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths$
Group by location, date, population
Order by InfectionPercentage desc

--Looking at countries with highest death count per population
Select location, population, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by location, population
Order by TotalDeathCount desc

--Let's break things down by Continent, showing continents with highest death count
Select location, SUM(CAST(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths$
Where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
Order by TotalDeathCount desc

Create View DeathCountContinent as
Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths$
Where continent is null
Group by location

--Global Numbers
Select SUM(new_cases) as GlobalNewCases, SUM(CAST(new_deaths as int)) as GlobalNewDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
Order by 1,2

Create View GlobalNumbers as
Select SUM(new_cases) as GlobalNewCases, SUM(CAST(new_deaths as int)) as GlobalNewDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null


--Joining two tables and looking at total population vs vaccinations 
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)

--USING CTE -- we can find the percent of population who got the vaccine. 
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From PopvsVac

--Create a view to store data for later visualisations
Create View PercentVaccination as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

select *
From PercentVaccination