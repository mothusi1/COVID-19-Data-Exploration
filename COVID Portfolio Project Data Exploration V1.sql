
select *
from PortfolioProjectDB..CovidDeaths
where continent is not null   -- we do this because after exploring the data we see that when continent is null it is in the locations column e.g Asia 
order by 3,4;


/*
select Data that we are going to be using
*/

Select Location, date, total_cases, new_cases,total_deaths,population
From PortfolioProjectDB..CovidDeaths
order by 1,2  --order by location and date

------------------------------------------------

--Looking at Total Cases vs Total Deaths (whats the percentage of people who died out of everyone who had it)
-- Shows the likelihood of dying [deathrate] if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathRate
From PortfolioProjectDB..CovidDeaths
Where location like '%states%' --IN THE USA
and continent is not null
order by 1,2 

----------------------------------------------------------

--Looking at Total Cases Vs Population
-- shows what percentage of population got COVID
Select Location, date,population, total_cases, (total_cases/population)*100 AS InfectedPopulation
From PortfolioProjectDB..CovidDeaths
--Where location like '%states%' --IN THE USA
where continent is not null
order by 1,2 

---------------------------------------------------------

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location ,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPopulation
From PortfolioProjectDB..CovidDeaths
--Where location like '%states%' --IN THE USA
where continent is not null
GROUP BY Location, population
order by InfectedPopulation desc --for example andorra has an infection rate of 17% compared to the population. Meaning 17% of population had COVID

----------------------------------------------------------

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the CONTINENTS with the highest death count per population

Select continent , MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProjectDB..CovidDeaths
--Where location like '%states%' --IN THE USA
where continent is not null
GROUP BY continent
order by TotalDeathCount desc 

---------------------------------------------------------------------

-- Showing COUNTRIES with the highest DeathCount per Population

Select Location, MAX(CONVERT(int,total_deaths)) AS TotalDeathCount
From PortfolioProjectDB..CovidDeaths
--Where location like '%states%' --IN THE USA
where continent is not null
GROUP BY Location
order by TotalDeathCount desc 

--------------------------------------------------------------------

--GLOBAL NUMBERS
--sum of all new cases adds up to all cases
-- here we are summing by date not location/country since we want global numbers per day
Select date, sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as DeathPercentage
From PortfolioProjectDB..CovidDeaths
--Where location like '%states%' --IN THE USA
where continent is not null
group by date
order by 1,2

--total numbers completely

Select sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as DeathPercentage
From PortfolioProjectDB..CovidDeaths
--Where location like '%states%' --IN THE USA
where continent is not null
order by 1,2

--------------------------------------------------------------------------

-- looking at Total population vs vaccination (rolling)
-- we could use total_vaccinations but we will use new_vaccinations perday and do a rolling count += each day entry

With PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopeVaccinated)
as 
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations --perday
, sum(vac.new_vaccinations) OVER 
(partition by /*break it up by*/ dea.Location order by dea.location, dea.date) as RollingPeopeVaccinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--and vac.new_vaccinations is not null
--order by 2,3 
)
Select *,(RollingPeopeVaccinated/Population) *100 from PopVsVac

-- everytime we get to a new location we want the start to start over
-- date will seperate it out for us

--if u use CTE then number of columns MUST be the same

--USE CTE (Common Table Expression)

-- OR TEMP TABLE


DROP TABLE IF exists #PercentPopulationVaccinated /* in case we do some alterations */
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated NUMERIC
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations --perday
, sum(vac.new_vaccinations) OVER 
(partition by /*break it up by*/ dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
--order by 2,3 

Select *,(RollingPeopleVaccinated/Population) *100 from #PercentPopulationVaccinated

----- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations --perday
, sum(vac.new_vaccinations) OVER 
(partition by /*break it up by*/ dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
--order by 2,3 