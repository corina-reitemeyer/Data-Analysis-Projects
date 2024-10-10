-- Checking if I'm getting the correct data from the spreadsheets -- 
WITH deaths AS (
  SELECT * FROM `covid-deaths-vaccs.Covid_19.covid_deaths`
),
vaccinations AS (
  SELECT * FROM `covid-deaths-vaccs.Covid_19.covid_vaccinations`
)
SELECT *
FROM deaths, vaccinations
ORDER BY 3, 4
LIMIT 100;

SELECT *
FROM `covid-deaths-vaccs.Covid_19.covid_deaths`
WHERE continent is not NULL
ORDER BY 3,4;

-- ******** --
SELECT
  location, 
  date, 
  total_cases, 
  new_cases, 
  total_deaths, 
  population
FROM
  `covid-deaths-vaccs.Covid_19.covid_deaths`
WHERE continent is not NULL
ORDER BY
  1,2;


-- Looking at Total Cases vs Total Deaths --
-- Shows the likelihood of dying from COVID-19 in your country--
SELECT
  location, 
  date, 
  total_cases, 
  total_deaths, 
  (total_deaths/total_cases)*100 AS DeathPercentage
FROM
  `covid-deaths-vaccs.Covid_19.covid_deaths`
WHERE
  location = "New Zealand"and
  continent is not NULL
ORDER BY
  location, population;

-- Looking at total cases vs. population -- 
-- Shows percentage of COVID cases in the population -- 
SELECT
  location, 
  date, 
  population,
  total_cases,  
  (total_cases/population)*100 AS PopulationCasePercentage
FROM
  `covid-deaths-vaccs.Covid_19.covid_deaths`
WHERE
  location = "New Zealand"and
  continent is not NULL
ORDER BY
  location, population;


-- Looking at countries with highest infections rates vs population --
SELECT
  location, 
  population,
  MAX(total_cases) AS HighestInfectionCount,
  MAX((total_cases / population)) * 100 AS InfectedPopulationPercentage
FROM
  `covid-deaths-vaccs.Covid_19.covid_deaths`
WHERE continent is not NULL
GROUP BY
  location, population
ORDER BY
  InfectedPopulationPercentage DESC;


-- Showing Countries with highest death count per population --
SELECT
  location, 
  MAX(CAST(total_deaths AS INT64)) AS TotalDeathCount,
FROM
  `covid-deaths-vaccs.Covid_19.covid_deaths`
WHERE continent is not NULL
GROUP BY
  location
ORDER BY
  TotalDeathCount DESC;

-- Let's break things down by Continent -- 
-- Showing continents with the highest death count per population --
SELECT
  continent, 
  MAX(CAST(total_deaths AS INT64)) AS TotalDeathCount,
FROM
  `covid-deaths-vaccs.Covid_19.covid_deaths`
WHERE continent is not NULL
GROUP BY
  continent
ORDER BY
  TotalDeathCount DESC;

-- GLOBAL NUMBERS --
SELECT
  SUM(new_cases)AS total_cases,
  SUM(CAST(new_deaths AS INT64)) AS total_deaths,
  SUM(CAST(new_deaths AS INT64))/SUM(new_cases)*100 AS DeathToCaseRatioPercentage
FROM
  `covid-deaths-vaccs.Covid_19.covid_deaths`
WHERE continent is not NULL
ORDER BY
  1,2;

--******--
-- JOIN covid_vaccinations table to our covid_deaths table --
SELECT
  deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations,
  SUM(CAST(vacs.new_vaccinations AS BIGINT)) OVER (Partition by deaths.location ORDER BY deaths.location,
  deaths.date) AS RollingPeopleVaccinated -- Alternative -> SUM(CONVERT(bigInt,vacs.new_vaccinations))
FROM `covid-deaths-vaccs.Covid_19.covid_deaths` AS deaths
JOIN `covid-deaths-vaccs.Covid_19.covid_vaccinations` AS vacs
  ON deaths.location = vacs.location
  and deaths.date = vacs.date
WHERE deaths.continent is not NULL
ORDER BY 2,3;

-- USE CTE (Common Table Expression) --
WITH PopsVsVac AS  
(
  SELECT
    deaths.continent,
    deaths.location,
    deaths.date,
    deaths.population,
    vacs.new_vaccinations,
    SUM(SAFE_CAST(vacs.new_vaccinations AS BIGINT)) 
      OVER (PARTITION BY deaths.location ORDER BY deaths.date) AS RollingPeopleVaccinated
  
  FROM 
    `covid-deaths-vaccs.Covid_19.covid_deaths` AS deaths
  JOIN 
    `covid-deaths-vaccs.Covid_19.covid_vaccinations` AS vacs
    ON deaths.location = vacs.location
    AND deaths.date = vacs.date
  WHERE 
    deaths.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinationPercentage
FROM PopsVsVac
ORDER BY location, date;

