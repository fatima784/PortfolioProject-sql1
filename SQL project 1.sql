select * from PortfolioProject..CovidDeaths1
where continent is not null
order by 3,4


select * from PortfolioProject..CovidVaccination1
order by 3,4

--select data that we use
select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths1
where continent is not null
order by 1,2

--looking at total cases vs total deaths

select Location,date,Population,total_cases,(total_cases/Population)*100 as 
DeathPercentage from PortfolioProject..CovidDeaths1
WHERE location like '%states'
and continent is not null
order by 1,2

--looking at countries with highest infection rate compared to population

select Location,population,max(total_cases)as HighestInfectionCount,max(total_cases/Population)*100 as 
PercentPopulationInfected from PortfolioProject..CovidDeaths1
--WHERE location like '%states'
Group by location,population
order by PercentPopulationInfected desc

--JUST use of max()
select max(total_cases) as HighestInfectionCount from PortfolioProject..CovidDeaths1

--showing counteries with Highest death count per population

select location,max(cast(Total_deaths as int)) as TotalDeathCount from PortfolioProject..CovidDeaths1
--WHERE location like '%states'
where continent is not null
Group by location
order by  TotalDeathCount desc


--lets break things down by continent

--showing continents with highest death count per continent

select continent,max(cast(Total_deaths as int)) as TotalDeathCount from PortfolioProject..CovidDeaths1
--WHERE location like '%states'
where continent is   not null
Group by continent
order by  TotalDeathCount desc

--Global numbers

select date,sum(new_cases)as total_cases, sum(cast(new_deaths as int))as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100
as DeathPercentage
from PortfolioProject..CovidDeaths1
--WHERE location like '%states'
where continent is not null
group by date
order by 1,2

-- if we want total numbers without date

select sum(new_cases)as total_cases, sum(cast(new_deaths as int))as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100
as DeathPercentage
from PortfolioProject..CovidDeaths1
--WHERE location like '%states'
where continent is not null
--group by date
order by 1,2


--join two data sets

select * 
from PortfolioProject..CovidDeaths1 dea
join PortfolioProject..CovidVaccination1 vac
    on dea.location= vac.location 
	and dea.date = vac.date

	--looking at total population vs vaccinations

	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths1 dea
join PortfolioProject..CovidVaccination1 vac
    on dea.location= vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100  :- cant use will give error, so put everything in CTE(common table expresion)

from PortfolioProject..CovidDeaths1 dea
join PortfolioProject..CovidVaccination1 vac
    on dea.location= vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE

with PopvsVac (continent, location,date, Population, New_vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths1 dea
join PortfolioProject..CovidVaccination1 vac
    on dea.location= vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population) *100
from PopvsVac

--TEMP table
drop table if exists #PercentPopulationVaccinated

create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths1 dea
join PortfolioProject..CovidVaccination1 vac
    on dea.location= vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population) *100
from #PercentPopulationVaccinated

--creating view to store data for later visualization

drop view if exists PercentPopulationVaccinated

USE PortfolioProject
GO
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths1 dea
join PortfolioProject..CovidVaccination1 vac
    on dea.location= vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated










