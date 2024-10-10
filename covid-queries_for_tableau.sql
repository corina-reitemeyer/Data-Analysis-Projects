
/* Queries used for Tableau */


-- 1.

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM `covid-deaths-vaccs.Covid_19.covid_deaths` AS deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;



-- 2.

SELECT location, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM `covid-deaths-vaccs.Covid_19.covid_deaths` AS deaths
WHERE continent IS NULL 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- 3.

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM `covid-deaths-vaccs.Covid_19.covid_deaths` AS deaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;


-- 4.


SELECT Location, Population,date, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM `covid-deaths-vaccs.Covid_19.covid_deaths` AS deaths
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected DESC;

