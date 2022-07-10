Select *
From [Portfolio-project]..CovidDeaths
order by 3, 4

Select *
from [Portfolio-project]..CovidVaccinations
order by 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio-project]..CovidDeaths
order by 1, 2

-- Looking at total cases vs Total deaths
-- Shows the likelihood of dying from COVID if you contracted it in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
From [Portfolio-project]..CovidDeaths
Where Location='United Kingdom'
order by 1, 2

-- Looking at total cases vs Population

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio-project]..CovidDeaths
Where Location='United Kingdom'
order by 1, 2

-- Looking at countries with Highest infection rate compared to the population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
From [Portfolio-project]..CovidDeaths
Group by Location, population
order by PercentPopulationInfected desc

-- Showing the continents with the highest death count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio-project]..CovidDeaths
WHERE continent is not null
GROUP BY continent	
Order by TotalDeathCount desc


-- Showing the countries with the highest death

SELECT location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM [Portfolio-project]..CovidDeaths
WHERE continent is null
GROUP BY Location
order by TotalDeathCount desc

-- Showing the numbers globally as it acrues
Select date, SUM(new_cases) as TolalDeaths, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio-project]..CovidDeaths
Where continent is not null
Group by date
order by 1, 2

-- Join deaths table with vaccination table on date and location
Select *
From [Portfolio-project]..CovidDeaths dea
Join [Portfolio-project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 1, 2, 3

	-- Looking at total population and vaccinations by location
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as TotalVaccinations
From [Portfolio-project]..CovidDeaths dea
Join [Portfolio-project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2, 3

	-- Creating a common table expression to produce a view to see total people vaccinated per population

With PopulationVaccinated (Continent, Location, Date, Population, New_vaccinations, TotalPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as TotalVaccinations
From [Portfolio-project]..CovidDeaths dea
Join [Portfolio-project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null)
Select * From PopulationVaccinated
Order by 2, 3

	-- Using the table above to see the percentage of people vaccinated per population

With PopulationVaccinated (Continent, Location, Date, Population, New_vaccinations, TotalPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as TotalVaccinations
From [Portfolio-project]..CovidDeaths dea
Join [Portfolio-project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null)
Select *, (TotalPeopleVaccinated/population) * 100 as PercentVaccinated
From PopulationVaccinated
Order by 2, 3

	-- Creating a temporary table to run multiple queries to
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as TotalVaccinations
From [Portfolio-project]..CovidDeaths dea
Join [Portfolio-project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

Select *, (TotalPeopleVaccinated/Population)*100 as PercentageVaccinated
FROM #PercentPopulationVaccinated
ORDER By 2,3


-- Creating a view to store data for visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as TotalVaccinations
From [Portfolio-project]..CovidDeaths dea
Join [Portfolio-project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

	Select * from PercentPopulationVaccinated