/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
select *
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4

-- Select Data that we are going to be starting with


select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows Likelihood Of Dying If you contract covid in your Country

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 AS Deathpercentage
from [Portfolio Project]..covidDeaths
where location like '%States%'
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select continent, date, Population, total_cases, (Total_Cases/population) *100 as PercentOfPopulationInfected
from [Portfolio Project]..covidDeaths
--where location like '%States%'
order by 1,2

-- Looking At Country with highest infection rate compared to population

Select continent, Population, max(total_cases) AS HighestInfectionCount, max((Total_Cases/population))*100 as PercentOfPopulationInfected
from [Portfolio Project]..covidDeaths
--where location like '%States%'
Group by Population, continent
order by PercentOfPopulationInfected desc

--Showing Countries With Highest Death Count Per Population

Select continent, max(cast(Total_Deaths as int)) as TotalDeathCount
from [Portfolio Project]..covidDeaths
--where location like '%States%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Lets Break This Down By Continent
-- This Is showing the continents with highest death count

Select Continent, sum(cast(Total_Deaths as int)) as TotalDeathCount
from [Portfolio Project]..covidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

Select sum(new_cases)as total_cases, Sum(new_deaths) as total_deaths, sum(new_deaths)/nullif(sum(new_cases),0)*100 AS DeathPercentage
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2


-- Total Population VS Vacinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVac
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVacinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
With PopsVsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVac)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVac
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVacinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
	)
	Select *, (RollingPeopleVac/population)*100
	From PopsVsVac




-- Using Temp Table to perform Calculation on Partition By in previous queryDrop Table if exists #PercentPopulationVac
Create Table #PercentPopulationVac
(
Continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
New_Vacinations numeric,
RollingPeopleVac Numeric,
)

insert into #PercentPopulationVac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVac
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVacinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

Select *, (RollingPeopleVac/population)*100
	From #PercentPopulationVac


-- Creating View To store date later visalization

Create View PercentPopulationVac as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVac
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVacinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

Create View GlobalDeathPercentage as
Select sum(new_cases)as total_cases, Sum(new_deaths) as total_deaths, sum(new_deaths)/nullif(sum(new_cases),0)*100 AS DeathPercentage
from [Portfolio Project]..CovidDeaths
where continent is not null

CREATE View TotalDeathCount as
Select Continent, sum(cast(Total_Deaths as int)) as TotalDeathCount
from [Portfolio Project]..covidDeaths
where continent is not null
Group by continent














