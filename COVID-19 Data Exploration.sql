/*

SQL Project
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



--1. Select Data that is going to be explored

-- Selecting relevant columns from the CovidDeaths table
-- Filtering out records where continent is null
-- Sorting the result by Location and Date
Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2


--2. Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

-- Calculating death percentage based on total cases and total deaths
-- Filtering records for locations containing 'states'
-- Filtering out records where continent is null
-- Sorting the result by Location and Date
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


--3. Total Cases vs Population
-- Calculating percentage of population infected based on total cases and population
-- Sorting the result by Location and Date
Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
order by 1,2


--4. Finding countries with the highest infection count and percentage of population infected
-- Grouping by Location and Population
-- Sorting the result by percentage of population infected in descending order
Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


--5. Finding countries with the highest total death count per population
-- Grouping by Location
-- Sorting the result by total death count in descending order
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



--6. BREAKING THINGS DOWN BY CONTINENT


-- Finding continents with the highest total death count per population
-- Grouping by Continent
-- Sorting the result by total death count in descending order
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



--7. GLOBAL NUMBERS

-- Calculating global total cases, total deaths, and death percentage
-- Filtering out records where continent is null
-- Sorting the result by total cases and total deaths
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



--8. Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine

-- Joining CovidDeaths and CovidVaccinations tables
-- Calculating rolling people vaccinated based on new vaccinations
-- Sorting the result by Location and Date
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--9. Using CTE to perform Calculation on Partition By in the previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--10. Using Temp Table to perform Calculation on Partition By in the previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




--11. Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null 
