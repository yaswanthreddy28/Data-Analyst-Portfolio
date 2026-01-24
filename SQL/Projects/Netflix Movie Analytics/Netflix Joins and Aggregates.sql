/*Netflix Analytics Project
Database: PostgreSQL
Author: Yaswanth Reddy */

--Joins and Aggregations. (Left Join, Right Join, Inner Join, Full Join) & (Count, Min, Max, Sum, Avg etc....)

--Show all movies released after 2015 along with their director names.

SELECT 
	m.movie_name,d.director_name,m.release_date
FROM movies m
JOIN directors d ON d.director_id = m.director_id
WHERE extract(year from release_date) >2015;

--Show movie_name and director_name for all movies (include movies without directors).

SELECT 
	m.movie_name,d.director_name
FROM movies m	
LEFT JOIN directors d ON d.director_id = m.director_id;


--Find the most expensive movie to make.

SELECT 
	m.movie_name,mf.cost_to_make 
from movies m
join movie_financials mf on mf.movie_id = m.movie_id
GROUP by m.movie_name,mf.cost_to_make
order by mf.cost_to_make desc
limit 1;


--Multi Table Joins

--Write a query to find the movie_name and the genre_name for every movie in your database.

select
	m.movie_name,string_agg(g.genre_name,', ')
from movies m
left join movie_genres mg ON mg.movie_id = m.movie_id
left join genres g on mg.genre_id = g.genre_id
GROUP by m.movie_id,m.movie_name;

--Retrieve all directors from a specific country (e.g., India).

SELECT 
	d.director_name,c.country_name 
from directors d
JOIN states s ON s.state_id=d.state_id
JOIN countries c ON c.country_id = s.country_id 
WHERE c.country_name = 'India';


--Find all movies along with their actors and role_type.

SELECT 
	m.movie_name, a.actor_name,ma.role_type
FROM movies m 
Join movie_actors ma ON ma.movie_id = m.movie_id
JOIN actors a on a.actor_id = ma.actor_id;


--Show all movies with their genres (include movies with multiple genres).

SELECT m.movie_name,string_agg(g.genre_name,' , ') AS Genres
FROM movies m 
JOIN movie_genres mg ON mg.movie_id = m.movie_id
JOIN genres g ON g.genre_id = mg.genre_id
GROUP by m.movie_name;

--Calculate the Total Revenue for every movie genre.
--Requirement: Only show genres where the total_revenue is greater than 50,000,000.
--Revenue formula: tickets_sold *times ticket_price

SELECT 
	g.genre_name, sum(mf.tickets_sold*mf.ticket_price) as total_revenue
FROM genres g 
JOIN movie_genres mg ON mg.genre_id = g.genre_id
JOIN movies m on m.movie_id = mg.movie_id
JOIN movie_financials mf ON mf.movie_id = mg.movie_id
GROUP by g.genre_name
having sum(mf.tickets_sold*mf.ticket_price) > 50000000


--Aggregations with Joins

--country_name and the count of movies produced by that country. 
--Only include countries that have produced more than 5 movies.

SELECT 
	c.country_name,count(m.movie_id) as total_movies
from countries c
join movies m on m.country_id = c.country_id
GROUP BY c.country_id,c.country_name
having count(movie_id) > 5
ORDER BY total_movies DESC;

--Find the Average Movie Rating for every actor, but only for actors who have appeared in more than 2 movies.

SELECT 
	a.actor_name, round(avg(m.rating),2) as average_rating
from actors a
JOIN movie_actors ma ON ma.actor_id = a.actor_id
JOIN movies m on m.movie_id = ma.movie_id
GROUP By actor_name
HAVING count(m.movie_id) > 2;

--Find the average rating of movies for each director.

SELECT 
	d.director_name,count(movie_id) AS movies_directed,round(avg(m.rating),2) as avg_rating 
FROM directors d 
left join movies m on m.director_id = d.director_id
GROUP by d.director_name;


--Calculate the total box office (tickets_sold × ticket_price) for each movie.
SELECT 
	m.movie_name, concat('₹ ',round((mf.tickets_sold*mf.ticket_price)/10000000,0),' Crores') as Box_office
FROM movies m 
left join movie_financials mf on mf.movie_id = m.movie_id
ORDER BY round((mf.tickets_sold*mf.ticket_price)/10000000,0) DESC;


--Count the number of movies in each genre.
select 
	g.genre_name, count(m.movie_id) as movies_count
from movies m 
left join movie_genres mg on mg.movie_id = m.movie_id
JOIN genres g on g.genre_id = mg.genre_id
GROUP by g.genre_name;


--Write a query to find the Director Name and the Movie Name for the movie that earned the highest profit in the entire database.

SELECT 
	d.director_name,m.movie_name,(mf.tickets_sold*mf.ticket_price)-mf.cost_to_make AS profit
from directors d 
JOIN movies m on d.director_id = m.director_id
join movie_financials mf ON m.movie_id = mf.movie_id
WHERE (mf.tickets_sold*mf.ticket_price)-mf.cost_to_make = (Select max((tickets_sold*ticket_price)-cost_to_make) as profit from movie_financials);


--Get a list of Directors and the total number of unique Actors they have worked with.

SELECT 
	d.director_name, count(distinct ma.actor_id)
FROM directors d
left join movies m on m.director_id = d.director_id
LEFT join movie_actors ma on ma.movie_id = m.movie_id
GROUP by d.director_id,d.director_name;

--Find movies whose box office was higher than the average box office.
--Box Office refers to revenue which is tickets_sold * ticket_Price

select 
	m.movie_name,
	concat(round(avg(mf.tickets_sold*mf.ticket_price)/10000000,2),' Crores') as box_office 
from movies m 
left join movie_financials mf on m.movie_id = mf.movie_id
group by m.movie_name
having avg(mf.tickets_sold*mf.ticket_price) > (select avg(mf.tickets_sold*mf.ticket_price) from movie_financials mf);

--Retrieve the names of all directors who have directed at least one "Action" movie, sorted alphabetically.

SELECT 
	d.director_name,count(m.movie_id) as total_movies
FROM movies m
JOIN directors d ON d.director_id = m.director_id
JOIN movie_genres mg on mg.movie_id = m.movie_id
JOIN genres g on g.genre_id = mg.genre_id
WHERE g.genre_name = 'Action'
group by d.director_name;
