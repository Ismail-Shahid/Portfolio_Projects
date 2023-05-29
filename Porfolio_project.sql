select *
from portfolio_project..covid_Deaths
where continent is not null
order by 3, 4

select *
from portfolio_project..covid_vaccinations
where continent is not null
order by 3, 4


-- Data that are going to be used

select Location, date, total_cases, new_cases, total_deaths, population
from portfolio_project..covid_Deaths
where continent is not null
order by 1,2


-- Looking at total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from portfolio_project..covid_Deaths
where location like '%india%'
and continent is not null
order by 1,2


--Looking at Total Cases vs Population
--Shows what Percentage of Population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from portfolio_project..covid_Deaths
order by 1,2


--Looking at Countries with Highest Infected Rate compared to Population

select Location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from portfolio_project..covid_Deaths
Group by location, population, date
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per population

Select Location, sum(cast(total_deaths as int)) as TotalDeathCount
From portfolio_project..covid_Deaths
Where continent is null
and location not in ('world', 'european union', 'international')
Group by location
Order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT


--Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolio_project..covid_Deaths
where continent is not null
Group by continent
Order by TotalDeathCount desc


--Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From portfolio_project..covid_Deaths
Where continent is not null
Order by 1,2


--Looking at Total population vs Vaccinations

Select dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From portfolio_project..covid_Deaths dea
Join portfolio_project..covid_vaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--Use CTE

With PopvsVac(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From portfolio_project..covid_Deaths dea
Join portfolio_project..covid_vaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

DROP Table if exists #percentpopulationvaccinated
Create Table #percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
New_vaccinations numeric,
percentpopulationvaccinated numeric
)

Insert into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From portfolio_project..covid_Deaths dea
Join portfolio_project..covid_vaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #RollingPeopleVaccinated


--Create View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From portfolio_project..covid_Deaths dea
Join portfolio_project..covid_vaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated




