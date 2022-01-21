/*
Covid EDA - Skills applyed: joins, temp tables, CTE's, agregate functions, creating views, converting data types
*/



Select*
From PortifolioProject..CovidDeaths$
Where continent is not null
order by 3,4



--Select the Data we are going to be using

select  location, date, total_cases, new_cases, total_deaths, population
From PortifolioProject..CovidDeaths$
Where continent is not null
order by 1,2



-- Loking at the total cases vs total deaths ( deaths / cases)
-- Shows  the likelihood of dying if you contract covid in your country: ex Brazil 2.78 vs usa 1.78)

select  location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortifolioProject..CovidDeaths$
Where location like '%Brazil%'
and continent is not null
order by 1,2

--Loking at Total Cases vs population
--Shows what percentage of population got Covid

select  location, date, population, total_cases,  (total_cases /population)*100 as PercentPopulationInfected
From PortifolioProject..CovidDeaths$
--Where location like '%Brazil%'
Where continent is not null
order by 1,2


--Loking at countries with highest infection rate compared to population
--desc of highest percentage of the population that got infected per country 

select  location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases /population))*100 as PercentPopulationInfected
From PortifolioProject..CovidDeaths$
--Where location like '%Brazil%'
Group by location, Population
order by PercentPopulationInfected desc



--Showing the countries with highes Death Count per Population
--Has to be casted by integer (data type)

Select  location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortifolioProject..CovidDeaths$
--Where location like '%Brazil%'
Where continent is not null
Group by location
order by TotalDeathCount desc


-- Breaking down by continent


--Showing continents with the highest death count per population

Select  continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortifolioProject..CovidDeaths$
--Where location like '%Brazil%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS
--will give us total death around the world


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortifolioProject..CovidDeaths$
--Where location like '%Brazil%'
Where continent is not null
--Group by date
order by 1,2

-- total cases= 236144031	total deaths= 4817597	percentage deaths = 2.04010958041112




--Loking at Total Population vs Vaccination
--Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location
,dea.date) as RolingPeopleVaccinated
--, (RolingPeopleVaccinated/population)*100
From PortifolioProject..CovidDeaths$ dea
Join PortifolioProject..CovidVaccination$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Using CTE for calculation on partition by on previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as

(
Select dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location
,dea.date) as RollingPeopleVaccinated
--, (RolingPeopleVaccinated/population)*100
From PortifolioProject..CovidDeaths$ dea
Join PortifolioProject..CovidVaccination$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select* , (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

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

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location
,dea.date) as RollingPeopleVaccinated
--, (RolingPeopleVaccinated/population)*100
From PortifolioProject..CovidDeaths$ dea
Join PortifolioProject..CovidVaccination$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select* , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating a View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location
,dea.date) as RollingPeopleVaccinated
--, (RolingPeopleVaccinated/population)*100
From PortifolioProject..CovidDeaths$ dea
Join PortifolioProject..CovidVaccination$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated




