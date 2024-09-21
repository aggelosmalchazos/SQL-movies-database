
#1
SELECT m.title as Title
FROM movie m, role r, actor a, movie_has_genre mg, genre g
WHERE m.movie_id = r.movie_id
AND r.actor_id = a.actor_id
AND m.movie_id = mg.movie_id
AND mg.genre_id = g.genre_id
AND a.last_name = "ALLEN"
AND g.genre_name = "COMEDY";

#2
SELECT d.last_name, m.title
FROM director d, movie m, movie_has_director md
WHERE d.director_id=md.director_id
AND m.movie_id=md.movie_id
AND d.director_id IN (
	SELECT md.director_id
	FROM movie_has_genre mg, movie_has_director md
	WHERE md.movie_id=mg.movie_id
	GROUP BY md.director_id
	HAVING COUNT(mg.genre_id) >= 2
	)
AND m.movie_id IN (
	SELECT r.movie_id
	FROM role r, actor a
	WHERE r.actor_id=a.actor_id
	AND a.last_name="Allen"
);

#3
SELECT DISTINCT a.last_name 
FROM actor a, role r, movie_has_director md, director d, movie_has_genre mg
WHERE  a.last_name = d.last_name
AND a.actor_id = r.actor_id
AND r.movie_id = md.movie_id
AND d.director_id = md.director_id
AND mg.movie_id = md.movie_id
AND a.actor_id IN (
    SELECT DISTINCT a2.actor_id 
    FROM actor a2, role r2, movie_has_director md2, movie_has_genre mg2
    WHERE a2.actor_id = r2.actor_id
    AND r2.movie_id = md2.movie_id
    AND md2.director_id <> md.director_id
    AND md2.movie_id IN (
        SELECT md3.movie_id 
        FROM movie_has_director md3, movie_has_genre mg3, actor a3, role r3
        WHERE md3.director_id = d.director_id
        AND mg3.genre_id = mg2.genre_id
        AND md3.movie_id = mg3.movie_id
        AND r3.movie_id=md3.movie_id
        AND a3.actor_id<>r3.actor_id
    )
);

#4
SELECT 'Yes' AS Drama_Shot_In_1995
WHERE EXISTS (
    SELECT 1
    FROM movie m, movie_has_genre mg, genre g
    WHERE g.genre_name = 'Drama' AND m.year = '1995'
    AND m.movie_id=mg.movie_id
    AND mg.genre_id=g.genre_id
)
UNION
SELECT 'No' AS Drama_Shot_In_1995
WHERE NOT EXISTS (
    SELECT 1
	FROM movie m, movie_has_genre mg, genre g
    WHERE g.genre_name = 'Drama' AND m.year = '1995'
    AND m.movie_id=mg.movie_id
    AND mg.genre_id=g.genre_id
);

#5
SELECT d1.last_name AS Director_1, d2.last_name AS Director_2
FROM director d1, director d2, movie_has_director md1, movie_has_director md2, movie m
WHERE m.movie_id IN (
	SELECT m1.movie_id
    FROM movie m1, movie_has_genre mg1
    WHERE m1.movie_id = mg1.movie_id
    GROUP BY m1.movie_id
    HAVING COUNT(DISTINCT mg1.genre_id) >= 6
    )
AND m.year >='2000' AND  m.year<='2006'
AND d1.director_id < d2.director_id
AND md1.movie_id = m.movie_id
AND md2.movie_id = m.movie_id
AND md1.director_id = d1.director_id
AND md2.director_id = d2.director_id;

#6
SELECT a.first_name AS actor_name , a.last_name AS actor_surname, 
COUNT(DISTINCT md.director_id) AS num_directors
FROM actor a, role r, movie m, movie_has_director md
WHERE a.actor_id = r.actor_id
    AND r.movie_id = m.movie_id
    AND m.movie_id = md.movie_id
GROUP BY a.actor_id
HAVING COUNT(DISTINCT m.movie_id) = 3;

#7
SELECT  g.genre_id AS Genre_id, COUNT(DISTINCT md.director_id) AS num_directors
FROM movie m, genre g, movie_has_genre mg,movie_has_director md
WHERE m.movie_id = mg.movie_id
AND mg.genre_id = g.genre_id
AND m.movie_id IN (
	SELECT m2.movie_id
	FROM movie m2,movie_has_genre mg2
	WHERE m2.movie_id = mg2.movie_id
	GROUP BY m2.movie_id
	HAVING COUNT(mg2.movie_id) = 1
    )
AND md.director_id IN (
	SELECT md2.director_id 
	FROM movie_has_director md2, movie_has_genre mg2
	WHERE mg2.genre_id=mg.genre_id
	AND md2.movie_id=mg2.movie_id
    )
GROUP BY g.genre_id, g.genre_name;

#8
SELECT DISTINCT actor_id
FROM role
WHERE actor_id IN (
    SELECT DISTINCT r.actor_id
    FROM role r, movie_has_genre mg, genre g
    WHERE r.movie_id = mg.movie_id
    AND mg.genre_id = g.genre_id
    GROUP BY r.actor_id
    HAVING COUNT(DISTINCT g.genre_id) = (SELECT COUNT(*) FROM genre)
);

#9
SELECT mg1.genre_id AS genre_id_1, mg2.genre_id AS genre_id_2, COUNT(DISTINCT md1.director_id) as Number_of_Directors
FROM movie_has_director md1,movie_has_genre mg2 , movie_has_genre mg1, movie_has_director md2
WHERE  md1.movie_id=mg1.movie_id
AND md2.movie_id=mg2.movie_id
AND mg1.genre_id<mg2.genre_id
AND md1.director_id=md2.director_id
GROUP BY mg1.genre_id, mg2.genre_id;

#10
SELECT g.genre_id AS genre, a.actor_id AS actor, COUNT(DISTINCT m.movie_id) AS count
FROM director d, movie m, movie_has_genre mg,genre g,actor a, role r
WHERE a.actor_id=r.actor_id
AND r.movie_id=m.movie_id
AND mg.movie_id=m.movie_id
AND mg.genre_id=g.genre_id
AND NOT EXISTS (
	SELECT 1
	FROM movie_has_genre mg2, movie_has_director md
	WHERE md.movie_id=mg2.movie_id
	AND md.movie_id = m.movie_id
	AND md.director_id IN (
		SELECT md2.director_id 
		FROM movie_has_genre mg3,movie_has_director md2
		WHERE mg3.movie_id=md2.movie_id
		AND md2.director_id=md.director_id
		GROUP BY md2.director_id
		HAVING COUNT(DISTINCT mg3.genre_id)>1 
        )
)
GROUP BY g.genre_id, a.actor_id;
