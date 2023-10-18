-- lets check if the data got uploaded successfully
select * 
from PortfolioProject..CovidDeaths

select * from PortfolioProject..CovidVaccinations
order by 3,4


--Lets Select we want to use
select Location,date,total_cases,new_cases,total_deaths,population 
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Total cases vs total deaths
-- likelihood of dying in India
create view IndianStats as 
select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'In%' and continent is not null
--order by 1,2

-- query to change the datatype of the columns when necessary
alter table CovidVaccinations
alter column new_vaccinations float null

-- total cases vs population
-- what perc of population got COVID
create view PositivityRate as 
select Location,date,population ,total_cases,(total_cases/population)*100 as PositivePercentage
from PortfolioProject..CovidDeaths
where location like 'In%' and continent is not null
--order by 1,2;

-- Countries with highest infection rate compared to population
create view HighestInfectionRate as 
select Location,population ,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as InfectedPercent
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
order by InfectedPercent desc;

-- Countries with the highest death count per population
create view HighestDeathRate as
select Location ,max(total_deaths) as MaxDeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by MaxDeaths desc;

-- seeing the data according to continent
create view ContinentData as 
select continent, max(total_deaths) as MaxDeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by MaxDeaths desc;

-- north America is showing the data only for the USA

select location, max(total_deaths) as MaxDeaths
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by MaxDeaths desc;

-- I'm getting rows such as High income,Low Income under locations so lets remove them

-- This query is being used to remove the unwanted row entries which are related to the income status of tyhe population
delete from CovidDeaths
where location in ('High income','Upper middle income','Lower middle income','Low income')

-- Global numbers
-- Lets gather the information about the global death percentage
select sum(new_cases) as TotalCases,sum(new_deaths) as DeathCount,
(sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null and new_cases <> 0
--group by date
order by 1,2;
-- 0.896 perc of total death perc globally


-- Looking at the information present in our Vaccination dataset
select * from 
PortfolioProject..CovidVaccinations

-- Lets look at the Total population vs Vaccination stats for every location present in our dataset
create view TotalVaccination as 
select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) 
over (partition by dea.location order by dea.location ,dea.date)
as ToatalVaccinations
from PortfolioProject..CovidDeaths dea join 
PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
order by 1,2,3


-- Now in order to get the percentage of total vaccinated population we can create temp tables or use CTE's as we won't be able
-- to perform operations on the new colummn created in the above section

-- lets create a temp table for the purpse as we can perform various actions using that temp table 
drop table if exists #VaccinationData
create table #VaccinationData
(
Continent nvarchar(50),
Location nvarchar(50),
Date datetime,
Population numeric,
New_vaccinations numeric,
VaccinationUpdates numeric,

);
insert into #VaccinationData
select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) 
over (partition by dea.location order by dea.location ,dea.date)
as VaccinationUpdates
from PortfolioProject..CovidDeaths dea join 
PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null 
--order by 1,2,3

select *, ((VaccinationUpdates/population)*100) as VaccinatedPercentage
from #VaccinationData
order by 1,2,3