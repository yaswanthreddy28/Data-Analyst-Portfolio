/* Netflix Analytics
Database: PostgreSQL
Author: Yaswanth Reddy*/

--Window FUNCTIONS


/*For every director in your database, 
find the one genre they have directed the most. If there is a tie, either one is fine.*/

with Movie_count AS(
	Select m.director_id,g.genre_name,count(m.movie_id) as movie_cnt
	FROM movies m 
	join movie_genres mg on m.movie_id = mg.movie_id
	join genres g on g.genre_id = mg.genre_id
	group by m.director_id,g.genre_name
),
rankedrows as (
	select 
		director_id,genre_name,movie_count,movie_cnt,
		row_number() OVER(partition by director_id order by movie_count,genre_name desc) as rnk
	FROM movie_count
)
SELECT 
	r.director_id,d.director_name,r.genre_name,r.movie_cnt AS Movie_count
from rankedrows r
join directors d ON d.director_id = r.director_id
where r.rnk = 1
order by r.movie_cnt desc;


--For each director, find their highest-grossing movie title and the revenue of that movie, but exclude any directors who have only directed one movie in total.

With dir_movie_count as (
	select director_id,count(movie_id) as movie_count
	FROM movies 
	group by director_id
	HAVING count(movie_id) > 1
),
movie_finance AS (
	select 
		m.director_id,m.movie_name,coalesce(sum(mf.tickets_sold* mf.ticket_price),0) as total_revenue,
		rank() over(partition by m.director_id ORDER BY coalesce(sum(mf.tickets_sold* mf.ticket_price),0) DESC) as rnk
	FROM movies m
	left join movie_financials mf on m.movie_id = mf.movie_id
	GROUP by m.director_id,m.movie_id
)
SELECT d.director_name,mfc.movie_name,concat(round(mfc.total_revenue/10000000,0),' Crores') as total_revenue
FROM movie_finance mfc 
join dir_movie_count dmc ON mfc.director_id = dmc.director_id
JOIN directors d on d.director_id = dmc.director_id
where mfc.rnk =1;


--Find the top 2 highest-grossing movies for every director.

With highest_gross_movies AS(
	Select 
		m.director_id,m.movie_name,coalesce(sum(mf.tickets_sold*mf.ticket_price),0) as Gross,
		dense_rank() over(partition by m.director_id order by coalesce(sum(mf.tickets_sold*mf.ticket_price),0) Desc) as rnk
	FROM movies m
	left join movie_financials mf on m.movie_id = mf.movie_id
	GROUP by m.director_id,m.movie_name
)
SELECT d.director_name,hgm.movie_name,hgm.gross
from directors d 
left join highest_gross_movies hgm on d.director_id = hgm.director_id
where hgm.rnk <=2;

--Lead & Lag 

/*how how a director's profit changes from movie to movie.
The Strategy:
CTE: Calculate the profit for every movie (revenue - cost).
Main Query: Use LAG() to pull the profit from the previous movie for that specific director.
The "Analyst Touch": Add a CASE statement to label the trend.*/

WITH DirectorProgress AS (
    SELECT 
        d.director_name,
        m.movie_name,
        m.release_date,
        (mf.tickets_sold * mf.ticket_price) - mf.cost_to_make AS Profit,
        LAG((mf.tickets_sold * mf.ticket_price) - mf.cost_to_make) 
            OVER (PARTITION BY d.director_id ORDER BY m.release_date) AS Previous_Profit
    FROM directors d
    JOIN movies m ON d.director_id = m.director_id
    JOIN movie_financials mf ON m.movie_id = mf.movie_id
)
SELECT 
    director_name,
    movie_name,
    CONCAT(ROUND(Profit / 10000000, 0), ' Crores') AS profit,
    Case
		WHEN round(previous_profit/10000000,0) is Null then '1st Movie'
		ELSE concat(round(previous_profit/10000000,0),' ','Crores')
	END AS Previous_Profit,
    CASE 
        WHEN Profit > previous_Profit THEN 'Increase'
        WHEN Profit < previous_Profit THEN 'Decrease'
        WHEN Profit = Previous_Profit THEN 'No Change'
        ELSE '1st Movie'
    END AS profit_trend
FROM DirectorProgress
ORDER BY director_name, release_date;

--Identify movies where the Revenue was higher than the previous movie directed by the same person.

SELECT 
	d.director_name,m.movie_name,coalesce(Round((mf.tickets_sold*mf.ticket_price)/10000000,0),0) as revenue_in_crores,
	coalesce(round(lag(tickets_sold*mf.ticket_price) OVER(partition by m.director_id ORDER by release_date asc)/10000000,0)::"text",'1st movie') as Prev_Revenue_in_crores,
	Case
		WHEN coalesce(mf.tickets_sold*mf.ticket_price,0) > lag(tickets_sold*mf.ticket_price) OVER(partition by m.director_id ORDER by release_date asc) THEN 'Increase'
		WHEN coalesce(mf.tickets_sold*mf.ticket_price,0) < lag(tickets_sold*mf.ticket_price) OVER(partition by m.director_id ORDER by release_date asc) THEN 'Decrease'
		when coalesce(mf.tickets_sold*mf.ticket_price,0) = lag(tickets_sold*mf.ticket_price) OVER(partition by m.director_id ORDER by release_date asc) THEN 'No change'
		Else '1st Movie'
	End as Revenue_trend
FROM movies m
left join movie_financials mf on m.movie_id = mf.movie_id
left join directors d on m.director_id = d.director_id