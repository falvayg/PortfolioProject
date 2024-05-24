---------Total Death vs total cases ---------------

SELECT 
	location,
	date,
	population,
	total_cases,
	total_deaths,
	(100.0 *(CAST(total_deaths as int)) / CAST(total_cases as int)) as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location Like '%Hungary%';


---------Total Infection vs Population ---------------

SELECT 
	location,
	date,
	CAST(population as float) as population,
	CAST(total_cases as float) as total_cases,
	(100.0 *(CAST(total_cases as float)) / CAST(population as float)) as PopulationInfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location Like '%Hungary%';

---------Highest Infection Count + Rate by location ---------------
SELECT 
	location,
	population,
	MAX(CAST(total_cases as int)) as HighestInfectionCount,
	MAX(100.0*CAST(total_cases as float) / CAST(population as float)) as HighestInfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestInfectedPercentage DESC;

--------- Highest Death Count by Location ---------------

SELECT 
	location,
	MAX(CAST(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDEATHCount DESC;

--------- Highest Death Count by continent ---------------

SELECT 
	continent,
	MAX(CAST(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDEATHCount DESC;

--------- Global Numbers --------------

	SELECT 
		date,
		SUM(CAST(new_cases as int)) as total_cases,
		SUM(CAST(new_deaths as int)) as total_death,
		(100.0 * SUM(CAST(new_deaths as int))) / SUM(CAST(new_cases as int)) as DeathPercentageGlobal
	FROM PortfolioProject.dbo.CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY date
	HAVING SUM(CAST(new_cases as int)) > 0
	ORDER BY 1, 2;

--------- Total Population vs. Vactination CTE--------------

WITH PopVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
	SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
		SUM(CONVERT(float, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
	FROM PortfolioProject.dbo.CovidDeaths cd
	JOIN PortfolioProject.dbo.CovidVaccinations cv 
		ON cd.location = cv.location 
		AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT *, (100.0 * RollingPeopleVaccinated / population ) as PopulationVactinated
FROM PopVac
WHERE location = 'Hungary'
ORDER BY 2,3;


--------- Temp Table --------------
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
	(
		Continent nvarchar(255),
		Location  nvarchar(255),
		Date datetime,
		Population numeric,
		New_Vacination numeric,
		RollingPeopleVaccinated numeric
		)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
		SUM(CONVERT(float, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
	FROM PortfolioProject.dbo.CovidDeaths cd
	JOIN PortfolioProject.dbo.CovidVaccinations cv 
		ON cd.location = cv.location 
		AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

SELECT *, (100.0 * RollingPeopleVaccinated / population ) as PopulationVactinated
FROM #PercentPopulationVaccinated
ORDER BY 2,3;

------------ CREATING VIEW FOR VISUALIZATION ------------

CREATE VIEW PercentPopulationVaccinated AS
	SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
			SUM(CONVERT(float, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
		FROM PortfolioProject.dbo.CovidDeaths cd
		JOIN PortfolioProject.dbo.CovidVaccinations cv 
			ON cd.location = cv.location 
			AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL