select * 
from Project_SQL.dbo.CovidDeaths
Where Continent is not null
order by 3,4

select * 
from Project_SQL.dbo.CovidVaccinations
order by 3,4

--Select DATA that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from Project_SQL.dbo.CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows Likelihood of Dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Project_SQL.dbo.CovidDeaths
Where location like '%INDIA%'
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
from Project_SQL.dbo.CovidDeaths
Where location like '%INDIA%'
order by 1,2

--Looking at countrie with Highest Infection Rate Compared to Population

select location, population, MAX(total_cases)as Highest_Infection_Count, MAX((total_cases/population)*100) as Percentage_Population_Infected
from Project_SQL.dbo.CovidDeaths
--Where location like '%INDIA%'
group by location, population
order by Percentage_Population_Infected Desc


--Showing Countries with Highest Death Count per Population
select location, MAX(cast(Total_Deaths as int)) as Total_Death_Count
from Project_SQL.dbo.CovidDeaths
--Where location like '%INDIA%'
Where Continent is not null
group by location
order by Total_Death_Count Desc

--LETS BREAK THINGS DOWN BY CONTINENT
--Showing Continents with the Highest Death Count per population

select continent, MAX(cast(Total_Deaths as int)) as Total_Death_Count
from Project_SQL.dbo.CovidDeaths
--Where location like '%INDIA%'
Where Continent is not null
group by continent
order by Total_Death_Count Desc

--GLOBAL NUMBERS
select --date, 
SUM(new_cases) Total_new_cases, SUM(new_Deaths) Total_new_deaths, SUM(new_deaths)/SUM(new_Cases)* 100 as Death_Percentage 
from Project_SQL.dbo.CovidDeaths
--Where location like '%INDIA%'
Where Continent is not null
--group by date
order by 1,2

--Joining the Death and Vaccination Table
select *
from Project_SQL.dbo.CovidDeaths dea
join Project_SQL.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


--Looking at Total Population vs Vaccinations
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
from Project_SQL.dbo.CovidDeaths dea
join Project_SQL.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 1,2,3


--Using CTE Because we cant use a table column name which we just created.
With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
from Project_SQL.dbo.CovidDeaths dea
join Project_SQL.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 1,2,3
)

select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac

--Using TEMP TABLE
Drop Table if Exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
from Project_SQL.dbo.CovidDeaths dea
join Project_SQL.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 1,2,3


select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


 -- Creating View to Store data for Later Visualisations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
from Project_SQL.dbo.CovidDeaths dea
join Project_SQL.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 1,2,3

select *
from PercentPopulationVaccinated