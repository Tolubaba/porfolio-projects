select * from [dbo].['covid deaths$']

select location, date, total_cases ,new_cases,total_deaths, population
from  [dbo].['covid deaths$']
order by 1,2
select  location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from [dbo].['covid deaths$']
where location like'%states%' 
order by 1,2

select location , population ,max(total_cases) as highestinfectioncount ,max((total_cases/population))*100 as percentpopulationinfected
from [dbo].['covid deaths$']
group by location,population
order by 4 desc
  
  -- showing the countries with the higest death count per population
 select location  ,max(cast(total_deaths as int ) )  totaldeathscount 
from [dbo].['covid deaths$']
where continent is not null
group by location

order by  totaldeathscount desc

-- to break down total deaths count by continent
select continent  ,max(cast(total_deaths as int ) ) as totaldeathscount 
from [dbo].['covid deaths$']
where continent is null
group by continent
order by  totaldeathscount desc
  

  -- to break down total deaths count by continent
select continent  ,max(cast(total_deaths as int ) ) as totaldeathscount 
from [dbo].['covid deaths$']
where continent is not  null
group by continent
order by  totaldeathscount desc

-- global numbers
select date, sum(new_cases) as sumcases,sum(cast(new_deaths as int)) as sumnewdeaths, (sum(cast(new_deaths as int))/sum(new_cases)) *100 as deathpercentage
--(total_deaths/total_cases)*100 as deathpercentage
from [dbo].['covid deaths$']
where continent is not null 
group by date
order by 1,2

select  sum(new_cases) as sumcases,sum(cast(new_deaths as int)) as sumnewdeaths, (sum(cast(new_deaths as int))/sum(new_cases)) *100 as deathpercentage
--(total_deaths/total_cases)*100 as deathpercentage
from [dbo].['covid deaths$']
where continent is not null 
--group by date
order by 1,2


select * 
from covidvaccination


-- looking at total population vs vaccinations

 select de.continent,de.location,de.date,de.population,vac.new_vaccinations
 from ['covid deaths$'] de
 join covidvaccination vac
 on de.location =vac.location
 and de.date=vac.date
 where de.continent is not null
 order by 2,3

 select de.continent,de.location,de.date,de.population,vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by de.location,de.date)
 from ['covid deaths$'] de
 join covidvaccination vac
 on de.location =vac.location
 and de.date=vac.date
 where de.continent is not null
 order by 2,3


 ---use of CTE
 with popsvac( continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)

 as
 (
 select de.continent,de.location,de.date,de.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by de.location,de.date) as rollingpeoplevaccinated
 from ['covid deaths$'] de
 join covidvaccination vac
 on de.location =vac.location
 and de.date=vac.date
 where de.continent is not null

 )

 select *, (rollingpeoplevaccinated/population)*100 as percentageofrolllingpoeplevaccinated
 from popsvac


 --temptable

 create table #percentpopulationvaccinated


 (
 continent nvarchar(255),
 laction nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rollingpeoplevaccinated numeric
 )
  insert into #percentpopulationvaccinated 

   select de.continent,de.location,de.date,de.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by de.location,de.date) as rollingpeoplevaccinated
 from ['covid deaths$'] de
 join covidvaccination vac
 on de.location =vac.location
 and de.date=vac.date
 where de.continent is not null

 select *, (rollingpeoplevaccinated/population)*100 as percentageofrolllingpoeplevaccinated
 from #percentpopulationvaccinated

 -- view #vwpercentpopulationvaccinated

create view vwpercentpopulationvaccinated
as 
 select de.continent,de.location,de.date,de.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by de.location,de.date) as rollingpeoplevaccinated
 from ['covid deaths$'] de
 join covidvaccination vac
 on de.location =vac.location
 and de.date=vac.date
 where de.continent is not null


  


  

  



 
 



  

 
 