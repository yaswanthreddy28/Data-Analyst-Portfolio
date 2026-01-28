/*Netflix Analytics Project
Database: PostgreSQL
Author: Yaswanth Reddy */

--Basic SQL Quries(SELECT, WHERE, ORDER BY, LIMIT, DISTINCT and etc...)

--List all movies with a rating greater than 8.
SELECT
	*
FROM movies
WHERE rating > 8;

--Find all actors who are female and born after 1990.
SELECT 
	* 
FROM actors
WHERE gender = 'F' and 
	extract(YEAR from birth_date) > 1990;


--Marketing wants a list of all actors whose names start with the letter 'S'. 
--They want the list to show the actor's name and their gender.

SELECT 
	actor_name,gender
from actors
WHERE actor_name like 'S%';

--What is the total number of movies in the movies table?
--What is the average rating of all those movies combined? (Round this to 1 decimal place).

SELECT 
	count(movie_id) as total_movies,round(avg(rating),1) as average_rating 
from movies;

--We want to find "Incomplete Profiles." 
--Write a query to find the names of all Directors who do not have a State associated with them.

Select 
	director_name
from directors 
where state_id is null;

--Write a query to find all movies that have a rating higher than the average rating of all movies in the database.

Select 
	movie_name,rating 
from movies
where rating > (Select avg(rating) from movies);

--Write a query to find all movies released in the last 5 years (from the current date).

SELECT 
	movie_name,release_date from movies
where release_date >= now() - Interval '5 Years'
order by release_date DESC;


--List movie_name and release_year for movies released after 2016 with rating ≥ 7.

Select 
	movie_name,extract(year from release_date) as year
from movies
where release_date >= '2016-01-01' and rating >=7;
