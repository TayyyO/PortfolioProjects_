-- looking to see if country's gdp affects the population infected ,also if gdp affects the total death of a country 
SELECT dea.location, MAX(gdp_per_capita) as Country_gdp, MAX(CONVERT(int,total_deaths)) as total_deaths, MAX((Total_cases/population))*100 AS Percentageofpopulationinfected --SUM(CONVERT(int,vac.new_vaccinations))
from PortfolioProject..covidDeaths dea
Join PortfolioProject..covidvaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
group by dea.location 




SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

-- Looking at the likelihood of dying if contracted 
SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%Africa%'
order by 1,2

--Looking at total cases vs pop 
--Shows what percentage of population got covid 
SELECT Location, date, population, total_cases, (Total_cases/population)*100 AS Percentageofpopulationinfected
FROM PortfolioProject..CovidDeaths
Where location like '%Africa%'
and continent is not null 
order by 1,2

 
 -- Looking at countries with highest infection rate comapared to pop
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/population))*100 AS Percentageofpopulationinfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
order by Percentageofpopulationinfected DESC


-- showing countries with the highest death count per pop 
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent 
order by TotalDeathCount DESC


-- Breaking it down by continents 
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent IS not NULL
GROUP BY continent 
order by TotalDeathCount DESC



-- showing the continent with the highest deathcount per pop
SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent 
order by TotalDeathCount DESC


-- GLOBAL NUMBERS to find total cases, total deaths and death percentage per date 

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2


-- Total Global numbers in the world( total_cases, total_deaths, deathpercentage)

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- looking at total population vs vaccinations 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingpeopleVaccinated/population)
from PortfolioProject..covidDeaths dea
Join PortfolioProject..covidvaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--USE CTE to find percentage of pop vaccinated in country 
with popvsVac (continent, location, date, population, New_Vaccinations, rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingpeopleVaccinated/population)
from PortfolioProject..covidDeaths dea
Join PortfolioProject..covidvaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null 
)
Select *, (rollingpeoplevaccinated/population)*100
From popvsVac
 


 --TEMP TABLE to find percentage of pop vaccinated in country 
 DROP Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 INSERT INTO #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingpeopleVaccinated/population)
from PortfolioProject..covidDeaths dea
Join PortfolioProject..covidvaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null 

Select *, (rollingpeoplevaccinated/population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later viz

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingpeopleVaccinated/population)
from PortfolioProject..covidDeaths dea
Join PortfolioProject..covidvaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null 



Select *
From PercentPopulationVaccinated