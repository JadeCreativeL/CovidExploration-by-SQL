Select *
From [Portfolioproject covid]..CovidDeaths
Where continent is not null
order by 3,4 

--Select * 
--From [Portfolioproject covid]..CovidVaccinations
--order by 3,4 

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolioproject covid]..CovidDeaths
order by 1,2 


-- Looking at Total Cases vs Total Deaths (percentage people died when they had covid
-- Show likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolioproject covid]..CovidDeaths
Where location like '%Canada%'
and continent is not null
order by 1,2 

-- Looking at the Total Cases vs Population 
-- Show what percentage of population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
From [Portfolioproject covid]..CovidDeaths
Where location like '%Canada%'
and continent is not null
order by 1,2 

-- Looking at Contries with highest infection rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfection , MAX((total_cases/population))*100 as InfectivePercentage
From [Portfolioproject covid]..CovidDeaths
Where continent is not null
--Where location like '%Canada%'
group by Location, population 
order by InfectivePercentage desc


-- BREAKING THING DOWNS BY CONTINENT 

-- Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeath
From [Portfolioproject covid]..CovidDeaths
Where continent is not null
--Where location like '%Canada%'
group by Location, population 
order by TotalDeath desc
-- United State is number one, Canada is number 25

-- BREAKING THING DOWNS BY CONTINENT 


-- Showing continent with the highest infective count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeath
From [Portfolioproject covid]..CovidDeaths
Where continent is not null
--Where location like '%Canada%'
group by continent
order by TotalDeath desc

-- Global Number

Select SUM(new_cases), SUM(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From [Portfolioproject covid]..CovidDeaths
where continent is not null
--group by date
order by 1,2 

-- Looking at Total Population vs Vaccinations
With PopvsVac (Continen, Location, Date, Population,new_vaccination, RollingPeopleVaccinated) 
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.Location order by dea.Location, 
dea.Date) as RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
From [Portfolioproject covid]..CovidDeaths dea
Join [Portfolioproject covid]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
---order by 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinated numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.Location order by dea.Location, 
dea.Date) as RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
From [Portfolioproject covid]..CovidDeaths dea
Join [Portfolioproject covid]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
---order by 2,3

Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.Location order by dea.Location, 
dea.Date) as RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
From [Portfolioproject covid]..CovidDeaths dea
Join [Portfolioproject covid]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
---order by 2,3