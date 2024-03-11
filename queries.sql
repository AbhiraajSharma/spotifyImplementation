/*[1] Query to find all playlists that contain songs from more than 3 different artists*/
SELECT 
    "p"."name" AS "Playlist"
FROM "Playlists" "p"
JOIN "PlaylistSongs" "ps" ON "p"."playlist_id" = "ps"."playlist_id"
JOIN "Songs" "s" ON "ps"."song_id" = "s"."song_id"
GROUP BY "p"."playlist_id"
HAVING COUNT(DISTINCT "s"."artist_id") > 3;

--[3] Query to find all albums released in 2020 with more than 10 songs:
SELECT "album_name", "release_year", "no_of_songs"
FROM "Albums"
WHERE "release_year" = 2020 AND "no_of_songs" > 10;

--[4] Query to find the top 10 artists with the most followers:
SELECT "name" AS "Artist", "num_followers" AS "Followers"
FROM "Artists"
ORDER BY "num_followers" DESC
LIMIT 10;

/*[5] Query to find the top 10 most popular songs based on the number of times heard, 
along with their artists and albums, released after 2010 and belonging to the 'Pop' genre*/
SELECT 
    "s"."title" AS "Song", 
    "a"."name" AS "Artist", 
    "alb"."album_name" AS "Album", 
    "s"."times_heard" AS "Times_Heard"
FROM "Songs" "s"
JOIN "Artists" "a" ON "s"."artist_id" = "a"."artist_id"
JOIN "Albums" "alb" ON "s"."album_id" = "alb"."album_id"
WHERE "s"."genre" = 'Pop' AND "s"."release_year" > 2010
ORDER BY "s"."times_heard" DESC
LIMIT 10;

/*[6]
Query to find the top 3 longest podcasts by total duration in the 'educational' type,
including their average rating and total number of episodes*/
SELECT 
    "p"."name" AS "Podcast", 
    SUM("e"."duration") AS "Total_Duration", 
    AVG("p"."rating") AS "Average_Rating", 
    COUNT("e"."episode_id") AS "Num_Episodes"
FROM "Podcasts" "p"
JOIN "Episodes" "e" ON "p"."podcast_id" = "e"."podcast_id"
WHERE "p"."type" = 'educational'
GROUP BY "p"."podcast_id"
ORDER BY "Total_Duration" DESC
LIMIT 3;

-- [7] Genres with an average song duration of more than 3 minutes
WITH "GenreAverageDuration" AS (
    SELECT 
        "genre", 
        AVG(("duration_hours" * 3600) + ("duration_minutes" * 60) + "duration_seconds") AS "avg_duration_seconds"
    FROM "Songs"
    GROUP BY "genre"
)
SELECT *
FROM "GenreAverageDuration"
WHERE "avg_duration_seconds" > 180;

-- [8] Select 5 random 'Pop' songs
SELECT "title"
FROM "Songs"
WHERE "genre" = 'Pop'
ORDER BY RANDOM()
LIMIT 5;
