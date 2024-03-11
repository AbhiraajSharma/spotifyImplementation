-- Tables
CREATE TABLE IF NOT EXISTS "Songs" (
    "song_id" INTEGER PRIMARY KEY,
    "title" TEXT NOT NULL,
    "duration_hours" INTEGER NOT NULL CHECK("duration_hours" >= 0),
    "duration_minutes" INTEGER NOT NULL CHECK("duration_minutes" >= 0 AND "duration_minutes" < 60),
    "duration_seconds" INTEGER NOT NULL CHECK("duration_seconds" >= 0 AND "duration_seconds" < 60),
    "artist_id" INTEGER NOT NULL,
    "album_id" INTEGER,
    "genre" TEXT NOT NULL,
    "release_year" INTEGER NOT NULL CHECK("release_year" >= 1900),
    "content" TEXT NOT NULL CHECK("content" IN ('Explicit', 'Not Explicit')),
    "times_heard" INTEGER DEFAULT 0 CHECK("times_heard" >= 0),
    FOREIGN KEY ("album_id") REFERENCES "Albums"("album_id") ON DELETE CASCADE,
    FOREIGN KEY ("artist_id") REFERENCES "Artists"("artist_id") ON DELETE CASCADE,
    UNIQUE("song_id", "artist_id", "album_id")
);

CREATE TABLE IF NOT EXISTS "Artists" (
    "artist_id" INTEGER PRIMARY KEY,
    "name" TEXT NOT NULL,
    "monthly_listeners" INTEGER NOT NULL DEFAULT 0 CHECK("monthly_listeners" >= 0),
    "num_followers" INTEGER NOT NULL DEFAULT 0 CHECK("num_followers" >= 0),
    "verified" INTEGER NOT NULL CHECK ("verified" IN (0, 1))
);

CREATE TABLE IF NOT EXISTS "Albums" (
    "album_id" INTEGER PRIMARY KEY,
    "album_name" TEXT NOT NULL,
    "artist_id" INTEGER,
    "release_year" INTEGER NOT NULL CHECK("release_year" >= 1900),
    "no_of_songs" INTEGER NOT NULL CHECK("no_of_songs" >= 0),
    "duration_hours" INTEGER NOT NULL CHECK("duration_hours" >= 0),
    "duration_minutes" INTEGER NOT NULL CHECK("duration_minutes" >= 0 AND "duration_minutes" < 60),
    "duration_seconds" INTEGER NOT NULL CHECK("duration_seconds" >= 0 AND "duration_seconds" < 60),
    FOREIGN KEY ("artist_id") REFERENCES "Artists"("artist_id") ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS "Users" (
    "user_id" INTEGER PRIMARY KEY,
    "username" TEXT NOT NULL UNIQUE,
    "email" TEXT NOT NULL UNIQUE,
    "password" TEXT NOT NULL CHECK(length("password") >= 8),
    "phone_number" TEXT UNIQUE CHECK(length("phone_number") = 13 AND "phone_number" LIKE '+91__________'),
    "premium" INTEGER DEFAULT 0 CHECK("premium" IN (0, 1)),
    "num_following_artists" INTEGER DEFAULT 0 CHECK("num_following_artists" >= 0),
    "num_following_users" INTEGER DEFAULT 0 CHECK("num_following_users" >= 0),
    "num_followers" INTEGER DEFAULT 0 CHECK("num_followers" >= 0),
    "num_public_playlist" INTEGER DEFAULT 0 CHECK("num_public_playlist" >= 0),
    CONSTRAINT "email_valid" CHECK ("email" LIKE '%_@__%.__%')
);

CREATE TABLE IF NOT EXISTS "Following_User" (
    "follower_id" INTEGER,
    "following_id" INTEGER,
    FOREIGN KEY ("follower_id") REFERENCES "Users"("user_id") ON DELETE CASCADE,
    FOREIGN KEY ("following_id") REFERENCES "Users"("user_id") ON DELETE CASCADE,
    PRIMARY KEY ("follower_id", "following_id")
);

CREATE TABLE IF NOT EXISTS "Following_Artist" (
    "follower_id" INTEGER,
    "following_id" INTEGER,
    FOREIGN KEY ("follower_id") REFERENCES "Users"("user_id") ON DELETE CASCADE,
    FOREIGN KEY ("following_id") REFERENCES "Artists"("artist_id") ON DELETE CASCADE,
    PRIMARY KEY ("follower_id", "following_id")
);

CREATE TABLE IF NOT EXISTS "Playlists" (
    "playlist_id" INTEGER PRIMARY KEY,
    "name" TEXT NOT NULL,
    "num_of_songs" INTEGER NOT NULL CHECK("num_of_songs" >= 0),
    "user_id" INTEGER NOT NULL,
    "num_of_followers" INTEGER DEFAULT 0 CHECK("num_of_followers" >= 0),
    "duration_hours" INTEGER NOT NULL CHECK("duration_hours" >= 0),
    "duration_minutes" INTEGER NOT NULL CHECK("duration_minutes" >= 0 AND "duration_minutes" < 60),
    "duration_seconds" INTEGER NOT NULL CHECK("duration_seconds" >= 0 AND "duration_seconds" < 60),
    "is_public" INTEGER DEFAULT 0 CHECK("is_public" IN (0, 1)),
    FOREIGN KEY ("user_id") REFERENCES "Users"("user_id") ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS "PlaylistSongs" (
    "user_id" INTEGER NOT NULL,
    "playlist_song_id" INTEGER PRIMARY KEY,
    "playlist_id" INTEGER NOT NULL,
    "song_id" INTEGER NOT NULL,
    "date_added" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("playlist_id") REFERENCES "Playlists"("playlist_id") ON DELETE CASCADE,
    FOREIGN KEY ("song_id") REFERENCES "Songs"("song_id") ON DELETE CASCADE,
    FOREIGN KEY ("user_id") REFERENCES "Users"("user_id") ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS "Podcasts" (
    "podcast_id" INTEGER PRIMARY KEY,
    "name" TEXT NOT NULL,
    "publisher" TEXT NOT NULL,
    "num_of_episodes" INTEGER DEFAULT 0,
    "rating" REAL,
    "about" TEXT,
    "type" TEXT CHECK("type" IN ('arts&entertainment', 'business&technology', 'educational', 'games', 'lifestyle&health', 'news&politics', 'sports&recreation', 'true_crime'))
);

CREATE TABLE IF NOT EXISTS "Episodes" (
    "episode_id" INTEGER PRIMARY KEY,
    "description" TEXT,
    "name" TEXT NOT NULL,
    "duration" INTEGER NOT NULL,
    "explicit" TEXT CHECK("explicit" IN ('Explicit', 'Not Explicit')),
    "release_year" INTEGER NOT NULL,
    "podcast_id" INTEGER NOT NULL,
    FOREIGN KEY ("podcast_id") REFERENCES "Podcasts"("podcast_id") ON DELETE CASCADE
);
-- Triggers
-- Trigger - update the playlist table when a song is added to playlist_songs
CREATE TRIGGER IF NOT EXISTS "update_playlist_on_playlist_song_insert"
AFTER INSERT ON "PlaylistSongs"
BEGIN
    UPDATE "Playlists"
    SET
        "num_of_songs" = "num_of_songs" + 1,
        "duration_seconds" = (
            SELECT SUM("duration_hours") * 3600 + SUM("duration_minutes") * 60 + SUM("duration_seconds")
            FROM "Songs"
            INNER JOIN "PlaylistSongs" ON "Songs"."song_id" = "PlaylistSongs"."song_id"
            WHERE "PlaylistSongs"."playlist_id" = NEW."playlist_id"),
        "duration_hours" = "duration_seconds" / 3600,
        "duration_minutes" = ("duration_seconds" % 3600) / 60,
        "duration_seconds" = "duration_seconds" % 60
    WHERE "playlist_id" = NEW."playlist_id";
END;

-- Trigger - update the Podcasts table when an episode is added to Episodes
CREATE TRIGGER IF NOT EXISTS "update_podcast_on_episode_insert"
AFTER INSERT ON "Episodes"
BEGIN
    UPDATE "Podcasts"
    SET
        "num_of_episodes" = "num_of_episodes" + 1
    WHERE "podcast_id" = NEW."podcast_id";
END;

-- Trigger - update the Albums table when a song is deleted from the Songs table
CREATE TRIGGER IF NOT EXISTS "update_album_on_song_delete"
AFTER DELETE ON "Songs"
BEGIN
    UPDATE "Albums"
    SET
        "no_of_songs" = "no_of_songs" - 1,
        "duration_seconds" = (
            SELECT SUM("duration_hours") * 3600 + SUM("duration_minutes") * 60 + SUM("duration_seconds")
            FROM "Songs"
            WHERE "album_id" = OLD."album_id"),
        "duration_hours" = "duration_seconds" / 3600,
        "duration_minutes" = ("duration_seconds" % 3600) / 60,
        "duration_seconds" = "duration_seconds" % 60
    WHERE "album_id" = OLD."album_id";
END;

-- Trigger - update the Playlists table when a song is deleted from the Playlist Songs table
CREATE TRIGGER IF NOT EXISTS "update_playlist_on_playlist_song_delete"
AFTER DELETE ON "PlaylistSongs"
BEGIN
    UPDATE "Playlists"
    SET
        "num_of_songs" = "num_of_songs" - 1,
        "duration_seconds" = (
            SELECT SUM("duration_hours") * 3600 + SUM("duration_minutes") * 60 + SUM("duration_seconds")
            FROM "Songs"
            INNER JOIN "PlaylistSongs" ON "Songs"."song_id" = "PlaylistSongs"."song_id"
            WHERE "PlaylistSongs"."playlist_id" = OLD."playlist_id"),
        "duration_hours" = "duration_seconds" / 3600,
        "duration_minutes" = ("duration_seconds" % 3600) / 60,
        "duration_seconds" = "duration_seconds" % 60
    WHERE "playlist_id" = OLD."playlist_id";
END;

-- Trigger - update the Podcasts table when an episode is deleted from the Episodes table
CREATE TRIGGER IF NOT EXISTS "update_podcast_on_episode_delete"
AFTER DELETE ON "Episodes"
BEGIN
    UPDATE "Podcasts"
    SET
        "num_of_episodes" = "num_of_episodes" - 1
    WHERE "podcast_id" = OLD."podcast_id";
END;

-- Trigger to update num_following_users and num_followers when a new user is followed
CREATE TRIGGER IF NOT EXISTS "update_following_users_insert"
AFTER INSERT ON "Following_User"
BEGIN
    -- Update num_following_users for the follower
    UPDATE "Users"
    SET "num_following_users" = "num_following_users" + 1
    WHERE "user_id" = NEW."follower_id";

    -- Update num_followers for the user being followed
    UPDATE "Users"
    SET "num_followers" = "num_followers" + 1
    WHERE "user_id" = NEW."following_id";
END;

-- Trigger to update num_following_users and num_followers when a user is unfollowed
CREATE TRIGGER IF NOT EXISTS "update_following_users_delete"
AFTER DELETE ON "Following_User"
BEGIN
    -- Update num_following_users for the follower
    UPDATE "Users"
    SET "num_following_users" = "num_following_users" - 1
    WHERE "user_id" = OLD."follower_id";

    -- Update num_followers for the user being unfollowed
    UPDATE "Users"
    SET "num_followers" = "num_followers" - 1
    WHERE "user_id" = OLD."following_id";
END;

-- Trigger to update num_following_artists in Users and num_followers in Artists when a new artist is followed
CREATE TRIGGER IF NOT EXISTS "update_following_artists_insert"
AFTER INSERT ON "Following_Artist"
BEGIN
    -- Update num_following_artists for the follower
    UPDATE "Users"
    SET "num_following_artists" = "num_following_artists" + 1
    WHERE "user_id" = NEW."follower_id";

    -- Update num_followers for the artist being followed
    UPDATE "Artists"
    SET "num_followers" = "num_followers" + 1
    WHERE "artist_id" = NEW."following_id";
END;

-- Trigger to update num_following_artists in Users and num_followers in Artists when an artist is unfollowed
CREATE TRIGGER IF NOT EXISTS "update_following_artists_delete"
AFTER DELETE ON "Following_Artist"
BEGIN
    -- Update num_following_artists for the follower
    UPDATE "Users"
    SET "num_following_artists" = "num_following_artists" - 1
    WHERE "user_id" = OLD."follower_id";

    -- Update num_followers for the artist being unfollowed
    UPDATE "Artists"
    SET "num_followers" = "num_followers" - 1
    WHERE "artist_id" = OLD."following_id";
END;

--  INDEXES
CREATE INDEX IF NOT EXISTS "idx_podcasts_type" ON "Podcasts" ("type");
CREATE INDEX IF NOT EXISTS "idx_songs_genre" ON "Songs" ("genre");
CREATE INDEX IF NOT EXISTS "idx_albums_release_year" ON "Albums" ("release_year");
CREATE INDEX IF NOT EXISTS "idx_playlists_user_id" ON "Playlists" ("user_id");
CREATE INDEX IF NOT EXISTS "idx_podcasts_publisher" ON "Podcasts" ("publisher");
CREATE INDEX IF NOT EXISTS "idx_episodes_release_year" ON "Episodes" ("release_year");

-- Views
-- View - to list the top songs for each genre based on the number of times heard.
CREATE VIEW "Top_Songs_By_Genre" AS
SELECT s."title" AS "song_title", s."genre", s."times_heard"
FROM  "Songs" s
ORDER BY s."genre", s."times_heard" DESC;

-- View - to display all playlists created by a user and the number of songs and total duration.
CREATE VIEW User_Playlist AS
SELECT p."name" AS "playlist_name", COUNT(ps."song_id") AS "num_of_songs",
    SUM(s."duration_hours" * 3600 + s."duration_minutes" * 60 + s."duration_seconds") AS "total_duration_seconds"
FROM "Playlists" p
JOIN "PlaylistSongs" ps ON p."playlist_id" = ps."playlist_id"
JOIN "Songs" s ON ps."song_id" = s."song_id"
GROUP BY p."playlist_id";

-- View - to show all songs and episodes marked as explicit along with their details.
CREATE VIEW "Explicit_Content" AS
SELECT 'Song' AS "content_type", s."song_id", s."title", s."genre", s."release_year", s."content"
FROM "Songs" s
WHERE s."content" = 'Explicit'
UNION ALL
SELECT 'Episode' AS "content_type", e."episode_id", e."name", p."type" AS "genre", e."release_year", e."explicit"
FROM "Episodes" e
JOIN "Podcasts" p ON e."podcast_id" = p."podcast_id"
WHERE e."explicit" = 'Explicit';

-- View - to rank artists based on the number of monthly listeners and followers.
CREATE VIEW "Top_Artists" AS
SELECT a."artist_id", a."name" AS "artist_name", a."monthly_listeners", a."num_followers"
FROM "Artists" a
ORDER BY a."monthly_listeners" DESC, a."num_followers" DESC;
