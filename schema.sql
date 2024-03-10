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
    FOREIGN KEY ("artist_id") REFERENCES "Artists"("artist_id"),
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
    "num_albums" INTEGER NOT NULL DEFAULT 0 CHECK("num_albums" >= 0),
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
    "password" TEXT NOT NULL,
    "phone_number" TEXT UNIQUE CHECK(length("phone_number") = 10 AND "phone_number" LIKE '+91__________'),
    "premium" INTEGER DEFAULT 0 CHECK("premium" IN (0, 1)),
    "num_following_artists" INTEGER DEFAULT 0 CHECK("num_following_artists" >= 0),
    "num_following_users" INTEGER DEFAULT 0 CHECK("num_following_users" >= 0),
    "num_followers" INTEGER DEFAULT 0 CHECK("num_followers" >= 0),
    "num_public_playlist" INTEGER DEFAULT 0 CHECK("num_public_playlist" >= 0),
    CONSTRAINT "email_valid" CHECK ("email" LIKE '%_@__%.__%')
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
    FOREIGN KEY ("user_id") REFERENCES "Users"("user_id")
);

CREATE TABLE IF NOT EXISTS "PlaylistSongs" (
    "user_id" INTEGER NOT NULL,
    "playlist_song_id" INTEGER PRIMARY KEY,
    "playlist_id" INTEGER NOT NULL,
    "song_id" INTEGER NOT NULL,
    "date_added" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("playlist_id") REFERENCES "Playlists"("playlist_id"),
    FOREIGN KEY ("song_id") REFERENCES "Songs"("song_id") ON DELETE CASCADE,
    FOREIGN KEY ("user_id") REFERENCES "Users"("user_id"),
    CONSTRAINT "playlist_song_id" CHECK ("song_id" IN (SELECT "song_id" FROM "Songs"))
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

-- Trigger - update the Albums table when a song is added with an album name
CREATE TRIGGER IF NOT EXISTS "update_album_on_song_insert" 
AFTER INSERT ON "Songs"
BEGIN
    IF NEW."album_id" IS NOT NULL THEN
        DECLARE album_exists INTEGER;
        SELECT COUNT(*) INTO album_exists FROM "Albums" WHERE "album_id" = NEW."album_id";
        IF album_exists > 0 THEN
            UPDATE "Albums"
            SET 
                "num_songs" = "num_songs" + 1,
                "duration_hours" = "duration_hours" + NEW."duration_hours",
                "duration_minutes" = "duration_minutes" + NEW."duration_minutes",
                "duration_seconds" = "duration_seconds" + NEW."duration_seconds"
            WHERE "album_id" = NEW."album_id";
        ELSE
            INSERT INTO "Albums" ("album_name", "artist_id", "release_year", "num_songs", "duration_hours", "duration_minutes", "duration_seconds")
            VALUES (NEW."album", NEW."artist_id", NEW."release_year", 1, NEW."duration_hours", NEW."duration_minutes", NEW."duration_seconds");
        END IF;
    END IF;
END;

-- Trigger - update the playlist table when a song is added to playlist_songs
CREATE TRIGGER IF NOT EXISTS"update_playlist_on_playlist_song_insert"
AFTER INSERT ON "PlaylistSongs"
BEGIN
    UPDATE "Playlists"
    SET 
        "num_of_songs" = (
            SELECT COUNT(*) FROM "PlaylistSongs" 
            WHERE "playlist_id" = NEW."playlist_id"),
        "duration_hours" = (
            SELECT SUM("duration_hours") FROM "Songs" 
            INNER JOIN "PlaylistSongs" ON "Songs"."song_id" = "PlaylistSongs"."song_id" 
            WHERE "PlaylistSongs"."playlist_id" = NEW."playlist_id"),
        "duration_minutes" = (
            SELECT SUM("duration_minutes") FROM "Songs" 
            INNER JOIN "PlaylistSongs" ON "Songs"."song_id" = "PlaylistSongs"."song_id" 
            WHERE "PlaylistSongs"."playlist_id" = NEW."playlist_id"),
        "duration_seconds" = (
            SELECT SUM("duration_seconds") FROM "Songs" 
            INNER JOIN "PlaylistSongs" ON "Songs"."song_id" = "PlaylistSongs"."song_id" 
            WHERE "PlaylistSongs"."playlist_id" = NEW."playlist_id")
    WHERE "playlist_id" = NEW."playlist_id";
END;

-- Trigger - update the Podcasts table when an episode is added to Episodes
CREATE TRIGGER IS NOT EXISTS"update_podcast_on_episode_insert"
AFTER INSERT ON "Episodes"
BEGIN
    UPDATE "Podcasts"
    SET 
        "num_of_episodes" = (SELECT COUNT(*) FROM "Episodes" WHERE "podcast_id" = NEW."podcast_id"),
    WHERE "podcast_id" = NEW."podcast_id";
END;

-- Trigger - update the Albums table when a song is deleted from the Songs table
CREATE TRIGGER IF NOT EXISTS"update_album_on_song_delete"
AFTER DELETE ON "Songs"
BEGIN
    UPDATE "Albums"
    SET 
        "no_of_songs" = (
            SELECT COUNT(*) FROM "Songs" 
            WHERE "album_id" = OLD."album_id"),
        "duration_hours" = (
            SELECT SUM("duration_hours") FROM "Songs" 
            WHERE "album_id" = OLD."album_id"),
        "duration_minutes" = (
            SELECT SUM("duration_minutes") FROM "Songs" 
            WHERE "album_id" = OLD."album_id"),
        "duration_seconds" = (
            SELECT SUM("duration_seconds") FROM "Songs" 
            WHERE "album_id" = OLD."album_id")
    WHERE "album_id" = OLD."album_id";
END;

-- Trigger - update the Playlists table when a song is deleted from the Songs table:
CREATE TRIGGER IF NOT EXISTS"update_playlist_on_song_delete"
AFTER DELETE ON "Songs"
BEGIN
    DELETE FROM "PlaylistSongs" WHERE "song_id" = OLD."song_id";
    UPDATE "Playlists"
    SET 
        "num_of_songs" = (
            SELECT COUNT(*) 
            FROM "PlaylistSongs" 
            WHERE "playlist_id" = OLD."playlist_id"),
        "duration_hours" = (
            SELECT SUM("duration_hours") 
            FROM "Songs" 
            INNER JOIN "PlaylistSongs" ON "Songs"."song_id" = "PlaylistSongs"."song_id" 
            WHERE "PlaylistSongs"."playlist_id" = OLD."playlist_id"),
        "duration_minutes" = (
            SELECT SUM("duration_minutes") 
            FROM "Songs" 
            INNER JOIN "PlaylistSongs" ON "Songs"."song_id" = "PlaylistSongs"."song_id" 
            WHERE "PlaylistSongs"."playlist_id" = OLD."playlist_id"),
        "duration_seconds" = (
            SELECT SUM("duration_seconds") 
            FROM "Songs" 
            INNER JOIN "PlaylistSongs" ON "Songs"."song_id" = "PlaylistSongs"."song_id" 
            WHERE "PlaylistSongs"."playlist_id" = OLD."playlist_id")
    WHERE "playlist_id" = OLD."playlist_id";
END;

-- Trigger - update the Podcasts table when an episode is deleted from the Episodes table
CREATE TRIGGER IF NOT EXISTS"update_podcast_on_episode_delete"
AFTER DELETE ON "Episodes"
BEGIN
    UPDATE "Podcasts"
    SET 
        "num_of_episodes" = (
            SELECT COUNT(*) FROM "Episodes" 
            WHERE "podcast_id" = OLD."podcast_id")
    WHERE "podcast_id" = OLD."podcast_id";
END;

-- Trigger - update Artists table if a new album name is added in albums for the same artist id
CREATE TRIGGER IF NOT EXISTS "update_artist_num_albums_insert"
AFTER INSERT ON "Albums"
FOR EACH ROW
BEGIN
    UPDATE "Artists"
    SET "num_albums" = "num_albums" + 1
    WHERE "artist_id" = NEW."artist_id";
END;

-- Trigger - update the Artists table if an album is deleted in albums for the same artist id 
CREATE TRIGGER IF NOT EXISTS "update_artist_num_albums_delete"
AFTER DELETE ON "Albums"
FOR EACH ROW
BEGIN
    UPDATE "Artists"
    SET "num_albums" = "num_albums" - 1
    WHERE "artist_id" = OLD."artist_id";
END;

