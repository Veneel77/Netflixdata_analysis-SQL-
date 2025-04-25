create database Netflixdataanalysis;

create table netflix (
	show_id varchar(7),
	type varchar (10),
    title varchar (50),
    director varchar (215),
    cast	varchar (1500),
    country	varchar (170),
    date_added	varchar (15),
    release_year	int,
    rating	varchar(25),
    duration varchar	(10),
    listed_in	varchar (75),
    description varchar (280)
    );
use  netflixdataanalysis;
    
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/netflix_titles.csv'
INTO TABLE netflix
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

describe netflix;

use  table netflix;
ALTER TABLE netflix MODIFY listed_in VARCHAR(250);

select distinct type from netflix;

SHOW TABLES IN netflixdataanalysis;

##15 business questions
#1.Count the number of movies vs Tv shows

select type, count(*) as total_content from netflix group by type

#2.find the most common ratings in movies and tv shows
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
)
SELECT *
FROM RatingCounts;
order by rating_count desc;
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

##3.List All Movies Released in a Specific Year (e.g., 2019)

SELECT * 
FROM netflix
WHERE release_year = 2019;

## 4. Find the Top 5 Countries with the Most Content on Netflix

WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 10
),
split_countries AS (
    SELECT 
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', n), ',', -1)) AS country
    FROM 
        netflix, numbers
    WHERE 
        n <= 1 + LENGTH(country) - LENGTH(REPLACE(country, ',', ''))
)
SELECT 
    country,
    COUNT(*) AS total_content
FROM 
    split_countries
WHERE 
    country IS NOT NULL AND country != ''
GROUP BY 
    country
ORDER BY 
    total_content DESC
LIMIT 5;

##5. Identify the Longest Movie
SELECT 
    *
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC;

##6. Find Content Added in the Last 5 Years
SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;

##7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT *
FROM netflix
WHERE FIND_IN_SET('Rajiv Chilaka', director) > 0;

##8. List All TV Shows with More Than 5 Seasons
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;


##9. Count the Number of Content Items in Each Genre
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n <= 10
),
split_genres AS (
    SELECT 
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n), ',', -1)) AS genre
    FROM netflix, numbers
    WHERE n <= 1 + LENGTH(listed_in) - LENGTH(REPLACE(listed_in, ',', ''))
)
SELECT 
    genre,
    COUNT(*) AS total_content
FROM split_genres
WHERE genre IS NOT NULL AND genre != ''
GROUP BY genre
ORDER BY total_content DESC;

##10.Find each year and the average numbers of content release in India on netflix.
##return top 5 year with highest avg content release!

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id) / 
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India') * 100, 
        2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

##11. List All Movies that are Documentaries
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

##13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT * 
FROM netflix
WHERE cast LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
  
  ##14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n <= 10
),

##15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
    WHERE description IS NOT NULL
) AS categorized_content
GROUP BY category;









