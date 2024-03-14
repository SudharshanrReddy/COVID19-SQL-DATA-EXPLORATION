/* Covid 19 DATA EXPLORATION
   Skills used : Aggregate funtctions, Converiting Data Types,
                 Joins, CTE's, Window Fuctions, Creating Views  */

---Display CovidDeaths Table

Select * from Projects..CovidDeaths
where continent is not null
order by 3,4 ;

---Selecting Columns that we are going to work with from CovidDeaths

Select  location, date, total_cases, new_cases, total_deaths, new_deaths, population
from Projects..CovidDeaths
where continent is not null
order by 1,2 ;

---Shows how many people died in your respected country due to covid

select location, date,total_deaths, total_cases, (Cast(total_deaths as int)/total_cases)*100 as deathpercentage
from Projects..CovidDeaths
where location like '%india%'
and continent is not null
order by 1,2 ;

---Shows what percent of population infected with covid

select location, date, total_cases, population, (total_cases/population)*100 as percentpopulationinfected
from Projects..CovidDeaths
where continent is not null
order by 1,2;

---Countries with highest infection rate compared to population

select location, population,   MAX(total_cases) as highestinfectioncount ,MAX(total_cases/population)*100 as percentpopulationinfected
from Projects..CovidDeaths
where continent is not null
Group by location, population 
order by 4 desc;

---countries with highest death count

select location, MAX(convert(int, total_deaths))as totaldeathcount
from Projects..CovidDeaths
where continent is not null
Group by location
order by 2 desc;

---Continents with highest death count

select continent, MAX(convert(int, total_deaths))as totaldeathcount
from Projects..CovidDeaths
where continent is not null
Group by continent
order by 2 desc;

---GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(convert(int, new_deaths)) as total_deaths, SUM(convert(int,new_deaths))/SUM(new_cases)*100 as deathpercentage
from Projects..CovidDeaths
where continent is not null
order by 1,2;

---select everything from CovidVaccinations

select * from
Projects..CovidVaccinations
where continent is not null
order by 2,3;

---shows percentage of people vaccinated

select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,
SUM(convert(bigint, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from Projects..CovidDeaths as dea
join Projects..CovidVaccinations as vac
on dea.date = vac.date 
and dea.location = vac.location
where dea.continent is not null
order by 2,3;

---Using CTE to perform calculation on partition by in previous query

with popvac( continent, date, location, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,
SUM(convert(bigint, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from Projects..CovidDeaths as dea
join Projects..CovidVaccinations as vac
on dea.date = vac.date 
and dea.location = vac.location
where dea.continent is not null
)
select*, (rollingpeoplevaccinated/population)*100 as vaccinationpercentage
from popvac;

---Creating view to store data for later visualizations

create view percentpeoplevaccinated as
select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,
SUM(convert(bigint, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from Projects..CovidDeaths as dea
join Projects..CovidVaccinations as vac
on dea.date = vac.date 
and dea.location = vac.location
where dea.continent is not null


