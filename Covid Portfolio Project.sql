--Select *
--From [Portfolio Project]..CovidVaccinations
--order by 3,4

Select *
From [Portfolio Project]..Coviddeaths
Where continent is not null
order by 3,4

--- We are going to select the data that we will be using.

select location, date, total_cases, new_cases,total_deaths,population
from [Portfolio Project]..Coviddeaths
Where continent is not null
order by 1,2

--- Looking at total_cases vs total_deaths
--- Likelihood of dieing if you contract Covid-19 in Ghana.

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..Coviddeaths
Where location like '%Ghana%'
order by 1,2 desc


--- Looking at the total_cases vs population.
--- Shows what population has got the Covid-19 virus

select location, date, total_cases,population, (total_cases/population)*100 as InfectionPercentage
from [Portfolio Project]..Coviddeaths
Where continent is not null
--Where location like '%Ghana%'
order by 1,2


--- What country had the highest infection rate compared to their population

select continent, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as InfectionPercentage
from [Portfolio Project]..Coviddeaths
Group by continent,population
order by InfectionPercentage desc


---Showing with Countries with highest death count per population

select continent, MAX(cast (total_deaths as int)) as TotalDeathCounts
from [Portfolio Project]..Coviddeaths
Where continent is not null
Group by continent
order by TotalDeathCounts desc


---Let us analyze the data by Continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCounts
from [Portfolio Project]..Coviddeaths
Where continent is not null
Group by continent
order by TotalDeathCounts desc


---Showint the continent with the highest death counts per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCounts
from [Portfolio Project]..Coviddeaths
Where continent is not null
Group by continent
order by TotalDeathCounts desc


---GLobal Numbers

select SUM(total_cases) as Totalcases, SUM(Cast(new_deaths as int)) as Totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Portfolio Project]..Coviddeaths
Where continent is not null
--Group by date
order by 1,2 


---Paying around with another table (covidVaccinations)
--- Looking at total population vs vaccination


Select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
OVER(Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
From [Portfolio Project]..Coviddeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location  = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 1, 2,3 


--from the previous query, we going to USE CTE

With PopvsVac (Continent,location, date, Population, new_vaccinations,RollingVaccinations)
as
(

Select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
OVER(Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
-- (RollingVaccinations/population)*100
From [Portfolio Project]..Coviddeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location  = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 1, 2,3 
)
Select *,(RollingVaccinations/population)*100
From PopvsVac



---TEMP Table

Drop table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinations numeric
)

insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
OVER(Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
-- (RollingVaccinations/population)*100
From [Portfolio Project]..Coviddeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location  = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 1, 2,3 


Select *,(RollingVaccinations/population)*100
From #PercentPopulationVaccinated


-- Creating a view to store data for later visualization 

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
OVER(Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
-- (RollingVaccinations/population)*100
From [Portfolio Project]..Coviddeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location  = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 1, 2,3



---Analyzing the created table

select *
From PercentPopulationVaccinated