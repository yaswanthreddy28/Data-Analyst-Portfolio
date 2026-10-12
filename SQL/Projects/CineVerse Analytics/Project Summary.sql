--Scale of the data

SELECT
  (SELECT COUNT(*) FROM movies)    AS movies,
  (SELECT COUNT(*) FROM directors) AS directors,
  (SELECT COUNT(*) FROM actors)    AS actors;

--Profit trend
WITH dp AS (
  SELECT
    d.director_id,
    (mf.tickets_sold * mf.ticket_price) - mf.cost_to_make AS profit,
    LAG((mf.tickets_sold * mf.ticket_price) - mf.cost_to_make)
      OVER (PARTITION BY d.director_id ORDER BY m.release_date) AS prev_profit
  FROM directors d
  JOIN movies m ON m.director_id = d.director_id
  JOIN movie_financials mf ON mf.movie_id = m.movie_id
)
SELECT
  COUNT(*) FILTER (WHERE prev_profit IS NOT NULL) AS comparisons,
  COUNT(*) FILTER (WHERE profit > prev_profit)    AS increases,
  COUNT(*) FILTER (WHERE profit < prev_profit)    AS decreases
FROM dp;

--Top genres by revenue

SELECT g.genre_name,
       SUM(mf.tickets_sold * mf.ticket_price) AS revenue
FROM genres g
JOIN movie_genres mg ON mg.genre_id = g.genre_id
JOIN movie_financials mf ON mf.movie_id = mg.movie_id
GROUP BY g.genre_name
ORDER BY revenue DESC
LIMIT 3;
