SELECT
  deaths.continent,
  deaths.location,
  deaths.date,
  deaths.population,
  deaths.total_cases,
  deaths.total_deaths,
  vacs.new_vaccinations,
  
  -- Rolling vaccinations
  SUM(SAFE_CAST(vacs.new_vaccinations AS BIGINT)) 
    OVER (PARTITION BY deaths.location ORDER BY deaths.date) AS RollingPeopleVaccinated,

  -- Vaccination percentage
  (SUM(SAFE_CAST(vacs.new_vaccinations AS BIGINT)) 
    OVER (PARTITION BY deaths.location ORDER BY deaths.date) / deaths.population) * 100 AS VaccinationPercentage,
  
  -- Death percentage
  (deaths.total_deaths / NULLIF(deaths.total_cases, 0)) * 100 AS DeathPercentage,  -- Prevent division by zero
  
  -- Population case percentage
  (deaths.total_cases / NULLIF(deaths.population, 0)) * 100 AS PopulationCasePercentage

FROM 
  `covid-deaths-vaccs.Covid_19.covid_deaths` AS deaths
JOIN 
  `covid-deaths-vaccs.Covid_19.covid_vaccinations` AS vacs
  ON deaths.location = vacs.location
  AND deaths.date = vacs.date
WHERE 
  deaths.continent IS NOT NULL
ORDER BY 
  deaths.location, deaths.date;