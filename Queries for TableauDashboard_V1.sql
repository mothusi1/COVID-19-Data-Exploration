/*

Queries used for Tableau Visualization 

*/

-- 1. Total global numbers for COVID-19 


Select SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths, SUM(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%' --IN THE USA
where continent is not null
order by 1,2

-- 2. 
--Showing the CONTINENTS with the  death count 

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--Select continent , SUM(cast(new_deaths as int)) AS TotalDeathCount
--From CovidDeaths
--Where location like '%states%' --IN THE USA
--where continent is  NOT null
--GROUP BY continent
--order by TotalDeathCount desc 

-- 3. 
-- Looking at Countries with Highest Infection Rate compared to Population

Select Location ,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPopulation
From CovidDeaths
--Where location like '%states%' --IN THE USA
where continent is not null
GROUP BY Location, population
order by InfectedPopulation desc --for example andorra has an infection rate of 17% compared to the population. Meaning 17% of population had COVID

-- 4. 

-- shows what percentage of population got COVID
Select Location, date,population, MAX(total_cases), MAX(total_cases/population)*100 AS InfectedPopulation
From CovidDeaths
--Where location like '%states%' --IN THE USA
where continent is not null
GROUP BY Location, population, date 
order by InfectedPopulation desc