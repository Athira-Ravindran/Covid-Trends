Select*
From Portfolio_Project.dbo.CovidDeaths$
order by 3,4 

--Select*
--From Portfolio_Project.dbo.CovidVaccinations
--order by 3,4 

Select Location, Date, total_cases, new_cases, total_deaths, population
From Portfolio_Project.dbo.CovidDeaths$
order by 1,2 

--Looking at Total deaths vs total cases

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project.dbo.CovidDeaths$
Where Location like 'India'
order by 1,2 

--Looking at Total cases vs Population

Select Location, Date, total_cases, Population, (Total_cases/Population)*100 as PercentPopulationInfected
From Portfolio_Project.dbo.CovidDeaths$
--Where Location like 'India'
order by 1,2

--Looking at countries with highest infection rates compared to Population

Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((Total_cases/Population))*100 as PercentPopulationInfected
From Portfolio_Project..CovidDeaths$
--Where Location like 'India'
Group by Location, Population
order by PercentPopulationInfected desc


--Looking at countries with highest death count compared to Population

Select Location, Max(cast(total_deaths as int)) as HighestdeathCount
From Portfolio_Project..CovidDeaths$
--Where Location like 'India'
where continent is not null
Group by Location
Order by HighestDeathCount desc

Select Location, Max(cast(total_deaths as int)) as HighestdeathCount
From Portfolio_Project..CovidDeaths$
--Where Location like 'India'
where continent is null
Group by Location
Order by HighestDeathCount desc

--showing continents with highest death count per population
Select Location, Population,  Max(cast(total_deaths as int)) as HighestdeathCount
From Portfolio_Project..CovidDeaths$
--Where Location like 'India'
where continent is null
Group by Location, Population
Order by HighestDeathCount desc

--Global Numbers

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From Portfolio_Project.dbo.CovidDeaths$
where continent is not null
--Group by Date
order by 1,2 


--Looking at total populations vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_Project.dbo.Coviddeaths$ dea
Join Portfolio_Project.dbo.CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
order by 2,3 


--Use CTS


With PopvsVac (Continent, Location, date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_Project.dbo.Coviddeaths$ dea
Join Portfolio_Project.dbo.CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
)
Select*, (RollingPeopleVaccinated/Population)*100
From Popvsvac


--Temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated bigint
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths$ dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths$ dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select*
From PercentPopulationVaccinated