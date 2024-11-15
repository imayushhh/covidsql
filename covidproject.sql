
--Covid-19 data



-- Selecting data where the continent is not null 

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeaths$
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, 
CASE WHEN total_cases = 0 THEN NULL 
      ELSE (total_deaths / total_cases) * 100 
    END AS DeathPercentage
FROM Portfolio..CovidDeaths$
WHERE location LIKE '%Canada%' 
AND continent IS NOT NULL 
ORDER BY 1, 2;



-- Total Cases vs Population

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From Portfolio..CovidDeaths$
Where location like '%Canada%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths$
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc





--contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths$
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio..CovidDeaths$
where continent is not null 
--Group By date
order by 1,2

--a 7-day rolling average for new cases and new deaths for each location

SELECT 
    Location,
    Date,
    New_Cases,
    New_Deaths,
    AVG(New_Cases) OVER (PARTITION BY Location ORDER BY Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS Rolling7DayNewCases,
    AVG(New_Deaths) OVER (PARTITION BY Location ORDER BY Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS Rolling7DayNewDeaths
FROM Portfolio..CovidDeaths$
WHERE continent IS NOT NULL 
ORDER BY Location, Date;




--Creating View 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

