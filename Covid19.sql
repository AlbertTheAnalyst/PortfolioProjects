select location, date,total_cases, new_cases, total_deaths, population from 
covid_death order by 1,2;

--looking at total cases vs total deaths
select location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from covid_death where location like '%States%' order by 1,2;
-- looking the total case  vs population 
-- show what percentage of population got coivd
select location, date,total_cases,population, (total_cases/population)*100 as percentPopulationInfected 
from covid_death where location like 'Japan' order by 1,2;

--looking at countries with highest infection rate compared to population 
select location, population, Max(total_cases)as highestInfestionCount, Max((total_cases/population))*100 as percentPopulationInfected
from covid_death 
Group by Location, population
order by percentPopulationInfected desc;

--showing countries with highest death count per population
select location, Max(total_cases)as TotalDeathCount
from covid_death 
where continent is not null
Group by Location
order by TotalDeathCount desc;
-- breaking donw by continent
select continent, Max(cast(total_cases as int))as TotalDeathCount
from covid_death 
where continent is not null
Group by continent  
order by TotalDeathCount desc;
--Global numbers
--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
Sum(cast( vac.new_vaccinations as int)) Over 
(Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVacinated
from covid_death dea 
Join covid_vaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3 ;

--Use CTE
with popvsvac(Continent, location, Date,Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
Sum(cast( vac.new_vaccinations as int)) Over 
(Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVacinated
from covid_death dea 
Join covid_vaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
	)
	
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac;


--temp table 
Drop table if exists #PercentPopulationVaccinated;
Create Table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date date,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric, 
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
Sum(cast( vac.new_vaccinations as int)) Over 
(Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVacinated
from covid_death dea 
Join covid_vaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null ;

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinatedg ;


--creating View to store data for later visualizations
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
Sum(cast( vac.new_vaccinations as int)) Over 
(Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVacinated
from covid_death dea 
Join covid_vaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null ;
























