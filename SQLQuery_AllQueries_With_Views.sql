Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


Select *
From PortfolioProject..CovidVaccinations
order by 3,4

--Select data that we are going to be using, based on location and date

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths in Denmark (percentage of people who are dying and who report getting infected)
-- Shows the likelihood of dying if you contract COVID in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%denmark%'
order by 1,2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got COVID

Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%denmark%'
order by 1,2


-- Looking at Countries with Highest Infection Rates compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentagePopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing the Countries with the Highest Death Count

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccination


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by  dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE
/*
This is a SQL query that calculates the rolling number of people vaccinated against Covid-19 for each location, 
along with their population, continent, date, and the number of new vaccinations for that date.*/

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by  dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE



DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by  dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by  dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null



-- This view shows the number of cases and population by location and date.

Create view CovidCases_and_Population_by_Location as
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths


-- The percentage of population infected in Denmark.

Create view Percentage_Population_Infected_In_Denmark as
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%denmark%'



-- Countries with the highest death counts by continent.

Create view HighestDeathCount_by_Continent as
Select location, Max(cast(total_deaths AS int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent IS NULL
Group By location


-- Countries with the highest infection counts compared to population.

Create view HighestInfectionCount_by_Location as
Select location, population, MAX(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 AS PercentagePopulationInfected
From PortfolioProject..CovidDeaths
Group By Location, Population
