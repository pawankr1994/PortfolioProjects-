/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject.dbo.CovidDeaths$

SELECT *
FROM PortfolioProject.dbo.CovidVaccinations$


SELECT *
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL 
ORDER BY 3,4



-- Select Data that we are going to be starting with

SELECT
	Location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM
	PortfolioProject.dbo.CovidDeaths$
Where
	continent IS NOT NULL 
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT
	Location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 as DeathPercentage
FROM
	PortfolioProject.dbo.CovidDeaths$
WHERE
	continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Total Deaths (in India)

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location LIKE '%india%'
AND continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT
	Location,
	date,
	Population,
	total_cases,
	(total_cases/population)*100 as PercentPopulationInfected
FROM
	PortfolioProject.dbo.CovidDeaths$
ORDER by 1,2




-- Countries with Highest Infection Rate compared to Population

SELECT
	Location,
	Population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM
	PortfolioProject.dbo.CovidDeaths$
GROUP BY
	Location,
	Population
ORDER BY PercentPopulationInfected DESC

-- Infection Rate in India

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location LIKE '%india%'
GROUP BY Location, Population


-- Countries with Highest Death Count per Population

SELECT
	Location,
	MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM
	PortfolioProject.dbo.CovidDeaths$
WHERE
	continent IS NOT NULL 
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Highest Death Count in India

SELECT Location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location LIKE '%india%'
GROUP BY Location



-- Showing contintents with the highest death count per population

SELECT
	continent,
	MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM
	PortfolioProject.dbo.CovidDeaths$
WHERE
	continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- Global Number

SELECT
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS INT)) AS total_deaths,
	SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM
	PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL 

-- Joining CovidDeath and CovidVaccination Data

SELECT *
FROM PortfolioProject.dbo.CovidDeaths$ dea
JOIN PortfolioProject.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM 
    PortfolioProject.dbo.CovidDeaths$ dea
    Join PortfolioProject.dbo.CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent is not null
ORDER BY 2,3



-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM 
    PortfolioProject.dbo.CovidDeaths$ dea
    Join PortfolioProject.dbo.CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPeopleVaccinationPercentage
FROM PopvsVac