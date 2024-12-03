select * from CovidVaccinations
select * from cd

-- 1. total_cases vs total_deaths
select location,cast(total_cases as int) as total_cases,cast(total_deaths as int) as total_deaths ,
(total_deaths/total_cases)*100 as percent_of_deaths from cd
order by 3

--2. The percent of deaths across the gobel
select sum(new_cases) as total_cases , 
       sum(cast(new_deaths as int)) as total_deaths, 
      (sum(cast(new_deaths as int))/sum(new_cases ))*100 as perecent_of_deaths_gobel 
from cd

--3. Total deaths with respect to continent
select location , sum(cast(total_deaths as int)) as total_deaths from cd
where continent is null 
and 
location not in ('World', 'European Union','International')
group by location 
order by 1,2

--4 How much the percent the population was affected
select location, population,max(total_cases) as highest_cases ,max((total_cases/population)*100) as percent_of_infected_population
from cd
group by location, population
order by percent_of_infected_population desc

--5 The percent the population death
select location, population,max(total_deaths) as highest_deaths ,max((total_deaths/population)*100) as percent_of_deaths_population
from cd
group by location, population
order by percent_of_deaths_population desc



SELECT location,
       SUM(CAST(total_cases AS bigint)) AS total_cases,
       SUM(CAST(total_deaths AS bigint)) AS total_deaths
      FROM cd
where continent is null and 
location not in ('World', 'European Union','International')
group by location 
ORDER BY 1, 2 DESC



 

select * from cd 
join cv on cd.date=cv.date

with popvsvacc(continent,location,date,population,new_vaccination,total_vaccins) 
as
(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations, 
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as total_vaccins 
from cd join cv 
on cd.date=cv.date
and cd.location=cv.location		
where cd.continent is not null
) 
select *,(total_vaccins/population)*100 as percent_of_popvsvacc from popvsvacc

drop table if exists  #population_vs_vaccination
create table #population_vs_vaccination(
continent varchar(255),
location varchar(255),
date date,
population numeric,
new_vaccination numeric,
total_vaccins numeric)

insert into #population_vs_vaccination
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations, 
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as total_vaccins 
from cd join cv 
on cd.date=cv.date
and cd.location=cv.location		


select *,(total_vaccins/population)*100 as percent_of_popvsvacc from #population_vs_vaccination

create view population_vs_vaccination 
as 
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations, 
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as total_vaccins 
from cd join cv 
on cd.date=cv.date
and cd.location=cv.location	

select * from population_vs_vaccination

select location , sum(cast(total_deaths as int)) as total_deaths from cd
where continent is null 
and 
location not in ('World', 'European Union','International')
group by location 
order by 1,2