/*Netflix Analytics Project
Database: PostgreSQL
Author: Yaswanth Reddy */

--Advanced Queries(CTEs, CASE and Subqueries)


--CTEs

--List directors,movies along with the average rating of their director’s movies.

WITH director_avg_rating as (
	select m.director_id,d.director_name,round(avg(rating),2) as avg_rating 
	from  movies m
	JOIN directors d ON d.director_id = m.director_id
	GROUP by m.director_id, d.director_name
)
SELECT dar.director_name,m.movie_name,dar.avg_rating 
from director_avg_rating dar
join movies m on dar.director_id = m.director_id;


--Find directors who have directed movies in every genre present in the database.

WITH director_genres AS (
    SELECT DISTINCT
        m.director_id,
        mg.genre_id
    FROM movies m
    JOIN movie_genres mg ON mg.movie_id = m.movie_id
),
genre_count AS (
    SELECT COUNT(*) AS total_genres
    FROM genres
)
SELECT d.director_name
FROM directors d
JOIN director_genres dg ON d.director_id = dg.director_id
GROUP BY d.director_id, d.director_name
HAVING COUNT(DISTINCT dg.genre_id) = (SELECT total_genres FROM genre_count);


/*Write a query to show the actor_name and their Total Revenue 
Revenue = tickets sold * ticket Price
Requirements:Actors appeared atleast 3 movies and display Revenue in crores*/

With actors_movie_count as (
	Select a.actor_id,a.actor_name,count(movie_id) as movie_count from actors a
	JOIN movie_actors ma ON ma.actor_id = a.actor_id
	group by a.actor_id,a.actor_name
),
actor_revenue AS(
	Select ma.actor_id,concat(round((sum(mf.tickets_sold * mf.ticket_price))/10000000,0),' Crores') as revenue
	FROM movie_actors ma 
	JOIN movie_financials mf on mf.movie_id = ma.movie_id
	GROUP BY ma.actor_id
)
SELECT 
	amc.actor_name,amc.movie_count,ar.revenue 
FROM actors_movie_count amc
JOIN actor_revenue ar ON ar.actor_id = amc.actor_id
WHERE amc.movie_count >=3
order by ar.revenue DESC;

--Find the "Revenue Contribution" of each movie towards its director's total career revenue 
--(i.e., (Movie Revenue / Director's Total Revenue) * 100).
--Display the director's name, movie name, and the percentage rounded to 2 decimal places.

with director_finance AS(
	select 
		m.director_id,coalesce(sum(mf.tickets_sold* mf.ticket_price),0) as director_revenue
	FROM movies m
	left join movie_financials mf on m.movie_id = mf.movie_id
	GROUP by m.director_id
),
movie_financials as (
	Select m.director_id,m.movie_name,coalesce(sum(mf.tickets_sold* mf.ticket_price),0) as movie_revenue
	FROM movie_financials mf
	join movies m on m.movie_id = mf.movie_id
	GROUP by m.director_id,m.movie_name
)
SELECT d.director_name,mf.movie_name,concat(round((mf.movie_revenue/df.director_revenue)*100,2),'%') as revenue_contribution
from directors d 
join director_finance df on d.director_id = df.director_id
join movie_financials mf on mf.director_id = d.director_id
GROUP by d.director_id,d.director_name,mf.movie_name,mf.movie_revenue,df.director_revenue
ORDER by d.director_name,revenue_contribution;


-- Queries with CASE

/*Generate a report that labels movies based on their rating. 
I want to see the movie_name, rating, and a third column called performance_category based on these rules:
Rating 8.5 or higher: 'Blockbuster'
Rating between 7.0 and 8.4: 'Hit'
Rating below 7.0: 'Average'*/

SELECT 
	movie_name,rating, 
	case
		when rating >= 8.5 THEN 'Blockbuster'
		when rating BETWEEN '7.0' and '8.4' THEN 'Hit'
		when rating < '7.0' THEN 'Average'
		Else 'Rating not specified'
	END as Performace_category
from movies;

/*List all movies with their financial info: cost_to_make, tickets_sold, ticket_price, revenue, profit and Categorize them.
Revenue = Tickets_sold * Ticket_price
Profit = Revenue - Cost_to_make
Categories: Blockbuster = Cost < Profit, Flop = cost > Profit, Average = Cost and Profit are same.
Note: Display everything in Crores.*/


SELECT 
	m.movie_name,concat(round(mf.cost_to_make/10000000,2),' Crores') as Cost_to_make,
	round(mf.tickets_sold,0) as Tickets_sold,
	mf.ticket_price,
	concat(round((mf.ticket_price * mf.tickets_sold)/10000000,2),' Crores') as Revenue,
	concat(round(((mf.ticket_price * mf.tickets_sold) - mf.cost_to_make)/10000000,2),' Crores') as Profit,
	case
		WHEN round(mf.cost_to_make/10000000,2) < round(((mf.ticket_price * mf.tickets_sold) - mf.cost_to_make)/10000000,2) THEN 'Blockbuster'
		WHEN round(mf.cost_to_make/10000000,2) > round(((mf.ticket_price * mf.tickets_sold) - mf.cost_to_make)/10000000,2) THEN 'Flop'
		WHEN round(mf.cost_to_make/10000000,2) = round(((mf.ticket_price * mf.tickets_sold) - mf.cost_to_make)/10000000,2) THEN 'Average'
		ELSE 'No Data'
	End as Movie_category
FROM movies m
join movie_financials mf on mf.movie_id = m.movie_id;



--Subqueries

--Find movies whose box office was higher than the average box office.

select m.movie_name,concat(round(avg(mf.tickets_sold*mf.ticket_price)/10000000,2),' Crores') as box_office 
from movies m 
left join movie_financials mf on m.movie_id = mf.movie_id
group by m.movie_name
having avg(mf.tickets_sold*mf.ticket_price) > (select avg(mf.tickets_sold*mf.ticket_price) from movie_financials mf);


--Find all movies where the director has directed more than 5 movies.
SELECT movie_name,director_name
from movies m
left join directors d on m.director_id = d.director_id
where d.director_id in(select d.director_id 
						from directors d 
						left join movies m on m.director_id = d.director_id
						group by d.director_id 
						HAVING count(m.movie_id)>5 )


--List actors who have worked in movies of a specific genre (e.g., Action).
select distinct actor_name 
from actors 
where actor_id in(select ma.actor_id 
				from movie_actors ma 
				join movie_genres mg on ma.movie_id=mg.movie_id
				join genres g on g.genre_id = mg.genre_id
				where g.genre_name = 'Action'
				group by ma.actor_id)


--Find all actors who have worked with a director from Maharashtra.

SELECT distinct actor_name from actors a 
left join movie_actors ma on a.actor_id = ma.actor_id
left join movies m on ma.movie_id = m.movie_id
WHERE m.director_id in(select director_id from directors d
						JOIN states s on s.state_id = d.state_id
						WHERE s.state_name = 'Maharashtra');

--Find directors whose movies have never earned more than 1 crore in box office.
SELECT d.director_name
FROM directors d
WHERE NOT EXISTS (
  SELECT 1
  FROM movies m
  JOIN movie_financials mf ON m.movie_id = mf.movie_id
  WHERE m.director_id = d.director_id
    AND mf.tickets_sold*mf.ticket_price > 10000000
);

--Find directors who have directed BOTH:
--at least one movie with rating ≥ 8
--and at least one movie with rating ≤ 4

SELECT d.director_name
FROM directors d
WHERE EXISTS (
    SELECT 1
    FROM movies m
    WHERE m.director_id = d.director_id
      AND m.rating <= 4
)
and exists(
	SELECT 1
    FROM movies m
    WHERE m.director_id = d.director_id
      AND m.rating >=8
);
