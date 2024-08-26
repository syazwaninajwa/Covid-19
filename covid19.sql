


--- 1)
--- Total Cases vs Total Deaths
--- shows likely hood of dying if you contract covid in your country

--- Globally
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS  death_percentage
From [portfolio project 3].[dbo].[CovidDeaths]
Order by 1,2;

---In Asia
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS  death_percentage
From [portfolio project 3].[dbo].[CovidDeaths]
Where continent like '%asia%'
Order by 1,2;


--- 2)
--- Total Cases vs Population
--- Percentage population got covid

--- Globally
Select location, date, population, total_cases, (total_cases/population)*100 AS  PercentPopulationInfected
From [portfolio project 3].[dbo].[CovidDeaths]
Order by 1,2;


--- In Asia
Select location, date, population, total_cases, (total_cases/population)*100 AS  PercentPopulationInfected
From [portfolio project 3].[dbo].[CovidDeaths]
Where continent like '%asia%'
Order by 1,2;


--- 3)
--- Total Cases over Population
--- Highest infection rate compare to population

--- Globally
Select location, population, MAX(total_cases) AS Highest_Infection, MAX((total_cases/population)*100) AS Highest_Percent_Population_Infected
From [portfolio project 3].[dbo].[CovidDeaths]
Group by location, population
Order by 4 desc;

--- In asia 
Select location, population, MAX(total_cases) AS Highest_Infection, MAX(total_cases/population)*100 AS Highest_Percent_Population_Infected
From [portfolio project 3].[dbo].[CovidDeaths]
Where continent like '%asia%'
Group by location, population
Order by 4 desc;

--- Add by date

Select location, date, population, MAX(total_cases) AS Highest_Infection, MAX(total_cases/population)*100 AS Highest_Percent_Population_Infected
From [portfolio project 3].[dbo].[CovidDeaths]
Where continent like '%asia%'
Group by location,date, population
Order by 4 desc;


--- 4) 
--- Highest death count by location

--- Globally
Select location, MAX(total_deaths) AS MaxTotalDeath
From [portfolio project 3].[dbo].[CovidDeaths]
Where continent is not null ---to get rid of 'World' location
Group by location
Order by 2 desc;

--- In asia
Select location, MAX(total_deaths) AS MaxTotalDeath
From [portfolio project 3].[dbo].[CovidDeaths]
Where continent is not null and continent like '%asia%' ---to get rid of 'World' location
Group by location
Order by 2 desc;


---If you want to chage the data type

/*
Select location, MAX(cast(total_deaths as int)) AS MaxTotalDeath
From CovidDeaths
Group by location
Order by 2 desc;
*/


--- 5)
--- Highest death count by continent

Select continent, MAX(total_deaths) AS MaxTotalDeath
From [portfolio project 3].[dbo].[CovidDeaths]
Where continent is not null 
Group by continent
Order by 2 desc;


--- 6)
--- Total new death over new cases

--- Globally
Select SUM(new_cases) AS SumNewCase, SUM(new_deaths) AS SumNewDeath, 
SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
From [portfolio project 3].[dbo].[CovidDeaths]
Where continent is not null
Order by 3 desc;

--- By continent
Select continent, SUM(new_cases) AS SumNewCase, SUM(new_deaths) AS SumNewDeath, 
SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
From [portfolio project 3].[dbo].[CovidDeaths]
Where continent is not null
Group by continent
Order by 3 desc;

--- In Asia 
Select continent, SUM(new_cases) AS SumNewCase, SUM(new_deaths) AS SumNewDeath, 
SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
From [portfolio project 3].[dbo].[CovidDeaths]
Where continent like '%asia%' and continent is not null
Group by continent
Order by 3 desc;


--- 7)
--- Total population vs vaccination


Select * 
FROM [portfolio project 3].[dbo].[CovidVaccinations] AS dea
Join [portfolio project 3].[dbo].[CovidVaccinations] AS vac
	On dea.location = vac.location
	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
FROM [portfolio project 3].[dbo].[CovidDeaths] AS dea
Join [portfolio project 3].[dbo].[CovidVaccinations] AS vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 1,2,3


--- 8)
--- New vaccination per day, rolling count---
--- The result "RollingPeopleVaccinated" is added up value for new_vaccination for previous day and today

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 Sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location,dea.date) AS RollingPeopleVaccinated
FROM [portfolio project 3].[dbo].[CovidDeaths] AS dea
Join [portfolio project 3].[dbo].[CovidVaccinations] AS vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3;



--- 9)
--- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,Sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location,dea.date) AS RollingPeopleVaccinated
---,(RollingPeopleVaccinated/population)*100
FROM [portfolio project 3].[dbo].[CovidDeaths] AS dea
Join [portfolio project 3].[dbo].[CovidVaccinations] AS vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100 AS RollVsPopulation
FROM PopvsVac

--- 10)
--- TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,Sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location,dea.date) AS RollingPeopleVaccinated
---,(RollingPeopleVaccinated/population)*100
FROM [portfolio project 3].[dbo].[CovidDeaths] AS dea
Join [portfolio project 3].[dbo].[CovidVaccinations] AS vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 AS RollVsPopulation
FROM #PercentPopulationVaccinated


--- 11) 
--- We take these out as they are not inluded in the above queries and want to stay consistent
--- European Union is part of Europe

Select location, SUM(new_deaths) as TotalDeathCount
From [portfolio project 3].[dbo].[CovidDeaths]
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--- 12)
--- Max total Vaccination


Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as MaxPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio project 3].[dbo].[CovidDeaths] dea
Join [portfolio project 3].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3




--- )

--- Create view to store data for later visualization
--- ALREADY DONE

/* Create View PercentPopulationVaccinated AS

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,Sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location,dea.date) AS RollingPeopleVaccinated
---,(RollingPeopleVaccinated/population)*100
FROM [portfolio project 3].[dbo].[CovidDeaths] AS dea
Join [portfolio project 3].[dbo].[CovidVaccinations] AS vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null */


--- 

Select * FROM PercentPopulationVaccinated;

