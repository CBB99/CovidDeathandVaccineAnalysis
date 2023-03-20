SELECT * 
from portfolioproject..CovidDeaths$
where continent is not null
order by 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject..CovidDeaths$
where continent is not null
Order BY 1,2

-- looking at total cases vs total deaths
-- below query shows likelihood of dying if you contract covid in the United States

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
FROM portfolioproject..CovidDeaths$
WHERE location Like '%states%'
Order BY 1,2

--looking at total cases vs population

SELECT location, date, total_cases, population, (total_cases/population)* 100 as PercentofPopulation
FROM portfolioproject..CovidDeaths$
WHERE location Like '%states%'
Order BY 1,2

--Looking at country with highest infection rate compared to populkation

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))* 100 as PercentofPopulation
FROM portfolioproject..CovidDeaths$
--WHERE location Like '%states%'
where continent is not null
group by location, population
Order BY PercentofPopulation desc

--looking at Countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portfolioproject..CovidDeaths$
--WHERE location Like '%states%'
where continent is null
group by location
Order By TotalDeathCount desc

-- Showing Continents with Highest Death Count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portfolioproject..CovidDeaths$
--WHERE location Like '%states%'
where continent is not null
group by continent
Order By TotalDeathCount desc

--Global Numbers

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM portfolioproject..CovidDeaths$
--WHERE location Like '%states%'
WHERE continent is not null
--Group By date
Order BY 1,2

--looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated,

from portfolioproject..CovidDeaths$ dea
Join portfolioproject..CovidVaccinations$ vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not null
Order by 2,3

--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations))
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from portfolioproject..CovidDeaths$ dea
Join portfolioproject..CovidVaccinations$ vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations))
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from portfolioproject..CovidDeaths$ dea
Join portfolioproject..CovidVaccinations$ vac
  ON dea.location = vac.location
  AND dea.date = vac.date
--WHERE dea.continent is not null
--Order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Create View to store data for later Visualizations

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations))
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from portfolioproject..CovidDeaths$ dea
Join portfolioproject..CovidVaccinations$ vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3