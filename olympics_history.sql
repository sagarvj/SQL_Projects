/* 

Performing SQL queries on a comprehensive dataset sourced from Kaggle, 
encompassing 120 years of Olympic History.

*/


--Create Table

DROP TABLE IF EXISTS OLYMPICS_HISTORY;
CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY
(id INT, name VARCHAR, sex VARCHAR, age VARCHAR, height VARCHAR, weight	VARCHAR, team VARCHAR, noc VARCHAR, 
 games VARCHAR, year INT, season VARCHAR, city VARCHAR, sport VARCHAR, event	VARCHAR,medal 	VARCHAR);

DROP TABLE IF EXISTS OLYMPICS_HISTORY_NOC_REGIONS;
CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY_NOC_REGIONS
(noc VARCHAR, region VARCHAR, notes VARCHAR);


--reference query
SELECT * FROM OLYMPICS_HISTORY
SELECT * FROM OLYMPICS_HISTORY_NOC_REGIONS



--1. How many olympics games have been held?
SELECT COUNT(DISTINCT games) as total_olympic_games
FROM OLYMPICS_HISTORY


--2. List down all Olympics games held so far.
SELECT DISTINCT year, season, city
FROM OLYMPICS_HISTORY
ORDER BY 1


--3. Mention the total no of nations who participated in each olympics game?
SELECT games, COUNT(DISTINCT noc) as total_olympic_games
FROM OLYMPICS_HISTORY
GROUP BY games
ORDER BY games


--4. Which year saw the highest and lowest no of countries participating in olympics?
WITH countries_count AS(	
	SELECT
        games,
        COUNT(DISTINCT nr.region) AS total_countries
    FROM
        olympics_history oh
        JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
    GROUP BY
        games
)
SELECT
    CONCAT(MIN(games) || ' - ' || MIN(total_countries)) AS Lowest_Countries,
    CONCAT(MAX(games) || ' - ' || MAX(total_countries)) AS Highest_Countries
FROM
    countries_count;


--5. Which nation has participated in all of the olympic games?
WITH countries_participated AS (
		SELECT nr.region as country, COUNT(DISTINCT oh.games) as total_participated_games
		FROM olympics_history oh
		JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
		GROUP BY 1
	),
	total_games AS (
		SELECT COUNT(DISTINCT games) AS total_games
		FROM OLYMPICS_HISTORY
	)
SELECT country, total_participated_games
FROM countries_participated
CROSS JOIN total_games
WHERE total_games = total_participated_games
ORDER BY country


--6. Identify the sport which was played in all summer olympics.
WITH total_games AS (
		SELECT COUNT(DISTINCT games) as total_games
		FROM OLYMPICS_HISTORY
		WHERE season = 'Summer'
		),
	no_of_games AS(
		SELECT sport, COUNT(DISTINCT games) as no_of_games
		FROM OLYMPICS_HISTORY
		GROUP BY sport
		)
SELECT sport, total_games, no_of_games
FROM total_games 
CROSS JOIN  no_of_games 
WHERE total_games = no_of_games
ORDER BY sport
	

--7. Which Sports were just played only once in the olympics?
WITH sports AS (
		SELECT sport, COUNT(DISTINCT games) as no_of_games
		FROM OLYMPICS_HISTORY
		GROUP BY sport
	),
	games AS(
		SELECT sport, games 
		FROM OLYMPICS_HISTORY
		GROUP BY sport, games
	)
SELECT g.sport, s.no_of_games, games
FROM sports s
JOIN games g
ON s.sport = g.sport
WHERE s.no_of_games = 1


--8. Fetch the total no of sports played in each olympic games.
--total no of sports in each game
SELECT DISTINCT games, COUNT( DISTINCT sport) as no_of_sports 
FROM OLYMPICS_HISTORY
GROUP BY games
ORDER BY no_of_sports


--9. Fetch details of the oldest athletes to win a gold medal.
WITH temp AS (
		SELECT name, sex, CAST(CASE WHEN age = 'NA' THEN '0' ELSE age end as int) AS AGE,
			   team, games,	city, sport, event, medal
		FROM OLYMPICS_HISTORY
		),
	 ranking AS 
		(SELECT *, RANK() OVER(ORDER BY age DESC) as rnk
		FROM temp 
		WHERE medal = 'Gold'
		)
SELECT * 
FROM ranking
WHERE rnk = 1


--10. Find the Ratio of male and female athletes participated in all olympic games.
WITH ratio AS(
	SELECT COUNT(*) as total,
	SUM(CASE WHEN sex = 'M' THEN 1 ELSE 0 END) AS male,
	SUM(CASE WHEN sex = 'F' THEN 1 ELSE 0 END) AS female
	FROM OLYMPICS_HISTORY
	)
SELECT 
	CONCAT('1:', ROUND(1.0 * male/female, 2)) as ratio
FROM ratio


--11. Fetch the top 5 athletes who have won the most gold medals.
WITH athlete AS (
	SELECT name, team, COUNT(medal) as total_gold_medals,
		   DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) as rnk
	FROM OLYMPICS_HISTORY
	WHERE medal = 'Gold'
	GROUP BY name, team
	ORDER BY 3 DESC
	)
SELECT name, team, total_gold_medals 
FROM athlete 
WHERE rnk <= 5


--12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
WITH athlete AS (
	SELECT name, team, COUNT(medal) as total_gold_medals,
		   DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) as rnk
	FROM OLYMPICS_HISTORY
	WHERE medal IN ('Gold','Silver','Bronze')
	GROUP BY name, team
	ORDER BY 3 DESC
	)
SELECT name, team, total_gold_medals 
FROM athlete 
WHERE rnk <= 5


--13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
WITH medals AS (
		SELECT nr.region, 
		SUM(CASE WHEN medal IN ('Gold','Silver','Bronze') THEN 1 ELSE 0 END) AS total_medal
		FROM OLYMPICS_HISTORY oh
		JOIN OLYMPICS_HISTORY_NOC_REGIONS nr
		ON oh.noc = nr.noc
		GROUP BY nr.region
		ORDER BY total_medal DESC),
	rnk AS (
		SELECT *, RANK() OVER(ORDER BY total_medal DESC) AS rnk
		FROM medals
		)
SELECT *
FROM rnk
WHERE rnk <= 5


--14. List down total gold, silver and broze medals won by each country.
SELECT nr.region AS country, 
	SUM(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) AS gold,
	SUM(CASE WHEN medal = 'Silver' THEN 1 ELSE 0 END) AS silver,
	SUM(CASE WHEN medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze
FROM OLYMPICS_HISTORY oh
JOIN OLYMPICS_HISTORY_NOC_REGIONS nr 
	ON oh.noc = nr.noc
GROUP BY nr.region
HAVING SUM(CASE WHEN medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) > 0
ORDER BY 2 DESC, 3 DESC, 4 DESC


--15. List down total gold, silver and broze medals won by each country corresponding to each olympic games.
SELECT oh.games, nr.region AS country, 
	SUM(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) AS gold,	
	SUM(CASE WHEN medal = 'Silver' THEN 1 ELSE 0 END) AS silver,
	SUM(CASE WHEN medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze
FROM OLYMPICS_HISTORY oh
JOIN OLYMPICS_HISTORY_NOC_REGIONS nr
	ON oh.noc = nr.noc
GROUP BY oh. games, nr.region
HAVING SUM(CASE WHEN medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) > 0
ORDER BY 1,2



--16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.
WITH temp AS (
    SELECT 
        SUBSTRING(games, 1, POSITION(' - ' IN games) - 1) AS games,
        SUBSTRING(games, POSITION(' - ' IN games) + 3) AS country,
        SUM(CASE WHEN medal = 'Gold' THEN total_medals ELSE 0 END) AS gold,
        SUM(CASE WHEN medal = 'Silver' THEN total_medals ELSE 0 END) AS silver,
        SUM(CASE WHEN medal = 'Bronze' THEN total_medals ELSE 0 END) AS bronze
    FROM 
        (
            SELECT 
                CONCAT(games, ' - ', nr.region) AS games,
                medal,
                COUNT(1) AS total_medals
            FROM olympics_history oh
            JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
            WHERE medal <> 'NA'
            GROUP BY games, nr.region, medal
        ) AS medals
    GROUP BY 
        games, country
			 )
SELECT 
    DISTINCT games,
    CONCAT(FIRST_VALUE(country) OVER (PARTITION BY games ORDER BY gold DESC), ' - ', FIRST_VALUE(gold) OVER (PARTITION BY games ORDER BY gold DESC)) AS Max_Gold,
    CONCAT(FIRST_VALUE(country) OVER (PARTITION BY games ORDER BY silver DESC), ' - ', FIRST_VALUE(silver) OVER (PARTITION BY games ORDER BY silver DESC)) AS Max_Silver,
    CONCAT(FIRST_VALUE(country) OVER (PARTITION BY games ORDER BY bronze DESC), ' - ', FIRST_VALUE(bronze) OVER (PARTITION BY games ORDER BY bronze DESC)) AS Max_Bronze
FROM 
    temp
ORDER BY 
    games;



--17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
WITH temp AS (
    SELECT 
        SUBSTRING(games, 1, POSITION(' - ' IN games) - 1) AS games,
        SUBSTRING(games, POSITION(' - ' IN games) + 3) AS country,
        SUM(CASE WHEN medal = 'Gold' THEN total_medals ELSE 0 END) AS gold,
        SUM(CASE WHEN medal = 'Silver' THEN total_medals ELSE 0 END) AS silver,
        SUM(CASE WHEN medal = 'Bronze' THEN total_medals ELSE 0 END) AS bronze
    FROM 
        (
            SELECT 
                CONCAT(games, ' - ', nr.region) AS games,
                medal,
                COUNT(1) AS total_medals
            FROM olympics_history oh
            JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
            WHERE medal <> 'NA'
            GROUP BY games, nr.region, medal        
		) AS medals
    GROUP BY 
        games, country	
			),
	tot_medals AS(	
			SELECT 
                 DISTINCT games,
               	nr.region as country, 
                COUNT(1) AS total_medals
            FROM olympics_history oh
            JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
            WHERE medal IN ('Gold','Silver','Bronze')
            GROUP BY country, medal, games
			ORDER BY 1,2
				)
SELECT 
     DISTINCT tm.games,
    CONCAT(FIRST_VALUE(t.country) OVER (PARTITION BY t.games ORDER BY gold DESC), ' - ', FIRST_VALUE(t.gold) OVER (PARTITION BY t.games ORDER BY gold DESC)) AS Max_Gold,
    CONCAT(FIRST_VALUE(t.country) OVER (PARTITION BY t.games ORDER BY silver DESC), ' - ', FIRST_VALUE(t.silver) OVER (PARTITION BY t.games ORDER BY silver DESC)) AS Max_Silver,
	CONCAT(FIRST_VALUE(t.country) OVER (PARTITION BY t.games ORDER BY bronze DESC), ' - ', FIRST_VALUE(t.bronze) OVER (PARTITION BY t.games ORDER BY bronze DESC)) AS Max_Bronze,
    CONCAT(FIRST_VALUE(tm.country) OVER (PARTITION BY tm.games ORDER BY total_medals DESC NULLS LAST), ' - ', FIRST_VALUE(tm.total_medals) OVER (PARTITION BY tm.games ORDER BY total_medals DESC NULLS LAST)) AS total_medals
FROM 
    temp AS t
JOIN tot_medals AS tm 
	ON tm.games = t.games AND tm.country = t.country
ORDER BY 
    games;


--18. Which countries have never won gold medal but have won silver/bronze medals?
WITH medal AS(		
		SELECT nr.region AS country, 
			SUM(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) AS gold,
			SUM(CASE WHEN medal = 'Silver' THEN 1 ELSE 0 END) AS silver,
			SUM(CASE WHEN medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze
		FROM OLYMPICS_HISTORY oh
		JOIN OLYMPICS_HISTORY_NOC_REGIONS nr
		ON oh.noc = nr.noc
		GROUP BY nr.region
		ORDER BY 2 DESC, 3 DESC, 4 DESC
		    )
SELECT country, gold, silver, bronze 
FROM medal
WHERE gold = 0 AND (silver > 0 OR bronze > 0)


--19. In which Sport/event, India has won highest medals.
WITH t1 AS(
	SELECT sport as sport,
		   COUNT(sport) as total_medals
	FROM OLYMPICS_HISTORY 
	WHERE medal <> 'NA' AND team = 'India'
	GROUP BY sport
	ORDER BY total_medals DESC
	     ),
	t2 AS(
		SELECT *, RANK() OVER(ORDER BY total_medals DESC) AS rnk
		FROM t1
		 )
SELECT sport, total_medals
FROM t2
WHERE rnk = 1


--20. Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.
SELECT team, sport, games, 
	COUNT(sport) as total_medals
FROM OLYMPICS_HISTORY 
WHERE medal <> 'NA' AND 
	team = 'India'
GROUP BY team, sport, games
ORDER BY total_medals DESC
	
