SELECT * FROM PortfolioProject1..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--SELECT * FROM PortfolioProject1..CovidVaccinations
--ORDER BY 3,4

--Selection of Data
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
WHERE continent is not NULL
ORDER BY 1, 2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths,
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM PortfolioProject1..CovidDeaths
WHERE location LIKE '%states%' AND continent is not NULL
ORDER BY 1, 2

--Looking at Total Cases vs Population
--Shows what percentage of population contracted Covid
SELECT Location, date, population, total_cases,
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths
WHERE location = 'United States' AND continent is not NULL
ORDER BY date ASC

--Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,
MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths
WHERE continent is not NULL
GROUP BY Location,Population
ORDER BY PercentPopulationInfected DESC

--Displays Countries with Highest Death Count per Population
SELECT Location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Breaking down by Continent
--(More accurate)
SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC
--(More visually appealing)
SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Displays continents with highest death count per population
SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT date, SUM(new_cases)as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths,
SUM(cast(new_deaths as int))/Nullif(Sum(new_cases),0)*100 AS Death_Percentage
FROM PortfolioProject1..CovidDeaths
WHERE continent is not NULL
GROUP BY date--, total_cases, total_deaths
ORDER BY 1, 2

--Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
as Rolling_Vaccinators
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
ORDER BY 2,3

--USING CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Vaccinators)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
as Rolling_Vaccinators
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (Rolling_Vaccinators/Population) *100
FROM PopvsVac

--TEMP TABLE
--DROP TABLE if exists #PercentPopVac --if going to play around with data
Create Table #PercentPopVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rolling_Vaccinators numeric,
)
INSERT INTO #PercentPopVac
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
as Rolling_Vaccinators
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3

SELECT *, (Rolling_Vaccinators/Population) *100
FROM #PercentPopVac

--Creating View to store data for later visualizations

Create View PercentPopVac as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
as Rolling_Vaccinators
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3

SELECT * 
FROM PercentPopVac
