SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4


SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4


--data we are going to use
SELECT location, date, total_cases, new_cases,total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--total cases vs total deaths
SELECT location, date, total_cases, total_deaths,
    CASE
        WHEN TRY_CONVERT(float, total_deaths) > 0 THEN (TRY_CONVERT(float, total_deaths) / TRY_CONVERT(float, total_cases))*100 
        ELSE 0  -- or another value or NULL, depending on your requirements
    END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'India'
ORDER BY 1,2

--Total cases vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 as PopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like 'India'
ORDER BY 1,2

--Countries with Highest Infection rate
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location,population
ORDER BY PopulationInfected desc

--Countries with Highest death count
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Continent with Highest death count
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc


	--GLOBAL NUMBERS
select date, sum(new_cases) as total_cases, sum(cast(total_deaths as int)) as total_deaths
,sum(nullif(cast(new_deaths as int),0))/sum(nullif(new_cases,0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2



--Total population vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as VaccinatedPeople
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location
where dea.location is not null
order by 2,3


--CTE
with PopVsVac (continent, location, date, population, New_Vaccinations, VaccinatedPeople)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
as VaccinatedPeople
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location
where dea.location is not null
)
select *,(VaccinatedPeople/population)*100
from PopVsVac


--Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
VaccinatedPeople numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
as VaccinatedPeople
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location
--where dea.location is not null

select *,(VaccinatedPeople/Population)*100
from #PercentPopulationVaccinated


--Creating view to store data for visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
as VaccinatedPeople
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location
where dea.location is not null

select * 
from PercentPopulationVaccinated










