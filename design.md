## Scope

The Spotify database is designed to handle various entities and their interactions on a music streaming platform. This database`s scope includes:

- Artists and their music in the form of albums and songs
- Users and their interactions with the platform such as following artists and creating playlists
- Podcasts and their compositions as episodes
- The relationship between playlists and songs via playlist entries

Out of scope are elements like financial transactions, premium subscription details, and artist royalty calculations.

## Functional Requirements

This database will support:

- CRUD operations for artists, users, and songs
- Associating songs with albums and artists
- Users following artists and other users, and making playlists
- Creating podcasts with a list of episodes
- Adding songs to playlists

## Representation

Entities are captured in SQLite tables with the following schema.

### Entities

The database includes the following entities:

#### Artists

- `Artists` table stores the identifying information of musical artists.
- It includes:

* `artist_id`, which specifies the unique ID for the artist as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied
* `name`, name of the artist, as `TEXT`
* `monthly_listeners`, number of monthly listeners of the artist, as an `INTEGER` >=0
* `num_followers`, number of followers of the artist, as an `INTEGER` >=0
* `verified`, indicates whether the artist is verified or not (0,1)

#### Albums

- `Albums` table captures all albums released by artists, including a reference to the artist who released it.
- It includes:

* `album_id`, which specifies the unique ID for the album as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied
* `album_name`, the name of the album, as `TEXT`
* `artist_id`, unique identifier for the artist who released the album as `INTEGER`, taken as a `FOREIGN KEY` referencing the `Artists` table.
* `release_year`, the year in which the album was released, an `INTEGER` (>=1900)
* `no_of_songs`, the number of songs present in the album, an `INTEGER` (>=0)
* `duration_hours`, floor value of the number of hours that album lasts(For duration 6h 54m 12s, this would hold value 6), an `INTEGER`
* `duration_minutes`, duration of the album in minutes (For duration 6h 54m 12s, this would hold value 54), an `INTEGER`
* `duration_seconds`, remaining duration in seconds (For duration 6h 54m 12s, this would hold value 12), an `INTEGER`

#### Songs

- `Songs` table lists individual songs, including references to the album they are part of.
- It includes:

* `song_id` which specifies the unique ID for each song as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `title`, title of the song, as `TEXT`
* `duration_hours`, floor value of the number of hours that song lasts(For duration 6h 54m 12s, this would hold value 6), an `INTEGER`
* `duration_minutes`, duration of the song in minutes (For duration 6h 54m 12s, this would hold value 54), an `INTEGER`
* `duration_seconds`remaining duration in seconds (For duration 6h 54m 12s, this would hold value 12), an `INTEGER`
* `artist_id`, identifier for the artist of the song, a `FOREIGN KEY` referencing the `Artists` table
* `album_id`, identifier for the album the song belongs to, a `FOREIGN KEY` referencing the `Artists` table
* `genre`, genre of the song, as `TEXT`
* `release_year`, the year in which the song was released, as an `INTEGER` which must be greater than 1900.
* `content`, explicit or not explicit, as `TEXT` values
* `times_heard`, number of times the song has been listened to, an `INTEGER` (>=0)

#### Users

- `Users` table includes information about users of the platform.
- It includes:

* `user_id`, specifies the unique ID for each song as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `username`, username of the user, as `TEXT`
* `email`, email address of the user, as `TEXT`
* `password`, password of the user in a cipher, as `TEXT`
* `phone_number`, phone number of the user, as `TEXT` (must be 10 characters long)
* `premium`, indicates whether the user is a premium member or not, as an `INTEGER` with a constraint that values can only be 0 or 1.
* `num_following_users`, number of users the user is following, as an `INTEGER`, (>=0)
* `num_following_artists`, number of artists the user is following, , as an `INTEGER`, (>=0)
* `num_followers`, number of followers the user has, as an `INTEGER`, (>=0)
* `num_ public_playlist`, number of public playlists created by the user, as an `INTEGER`, (>=0)

#### Playlists

- `Playlists` table holds data about user-created playlists.
- It includes

* `playlist_id`, specifies the unique ID for each song as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied
* `name`, name of the playlist, as `TEXT`
* `num_of_songs`, number of songs in the playlist, as an `INTEGER`, (>=0)
* `user_id`, unique identifier for the user who created the playlist, as a `FOREIGN KEY` referencing the `Users` table.
* `num_of_followers`, number of followers of the playlist, as an `INTEGER`, (>=0)
* `duration_hours`, total duration of the playlist in hours (For duration 6h 54m 12s, this would hold value 6), an `INTEGER`
* `duration_minutes`, total duration of the playlist in minutes (For duration 6h 54m 12s, this would hold value 54), an `INTEGER`
* `duration_seconds`, total duration of the playlist in seconds (For duration 6h 54m 12s, this would hold value 12), an `INTEGER`
* `is_public`, indicates whether the playlist is public or private with a constraint of values - (0 or 1)

#### Playlist_Songs

- `Playlist_Songs` table relates playlists to the songs they contain, including the order of songs.
- It includes:

* `user_id`, specifies the id of the user who added a particular song, an `INTEGER`. It references the `Users` table as a `FOREIGN_KEY`.  
* `playlist_song_id`, specifies the unique ID for each song in the playlist as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `playlist_id`, refers to the playlist for which the songs are entered, thus has a `FOREIGN KEY` constraint applied, referencing the `Playlists` table.
* `song_id` refers to the id of each song in the songs database, thus has a `FOREIGN KEY` constraint applied, referencing the `Songs` table.
* `date_added`, the date on which a song was added, as a `CURRENT_TIMESTAMP`.

#### Podcasts

- `Podcasts` table includes data about the podcasts available on the platform.
- It includes:

* `podcast_id`, specifies the unique ID for each podcast as an`INTEGER`. This column thus has the `PRIMARY KEY` constraint applied
* `name`, name of the podcast, as `TEXT`
* `publisher`, publisher of the podcast, as `TEXT`
* `num_of_episodes`, number of episodes in the podcast, as an `INTEGER`
* `rating`, rating of the podcast, as `REAL`
* `about`, description or information about the podcast, as `TEXT`
* `type`, type or genre of the podcast, as `TEXT` which can only be of the following types: 
`arts&entertainment`, `business&technology`, `educational`, `games`, `lifestyle&health`, `news&politics`, `sports&recreation`, and `true_crime`

#### Episodes


- `Episodes` table lists individual podcast episodes and relates them to their respective podcasts.
- It includes:

* `episode_id`, gives us the unique ID for each podcast as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied
* `description`, description of the episode, as `TEXT`
* `name`, name of the episode, as `TEXT`
* `duration`, duration of the episode, as an `INTEGER`
* `explicit`, indicates whether the episode contains explicit content, as `TEXT`, with entries 'Explicit' or 'Not Explicit'
* `release_year`, the year in which the episode was released, as an `INTEGER`, greater than 1900
* `podcast_id`, identifier for the podcast the episode belongs to, an `INTEGER` and `FOREIGN KEY`, referencing the `Podcasts` table.

### Relationships

- Artists release Albums, and compose Songs.
- Albums contain Songs.
- Users follow Artists, listen to Podcasts and Songs, and make Playlists.
- Playlists contain Playlist Songs.
- Podcasts comprise Episodes.
- Playlist Songs are a subset of Songs

### Diagram
![image](https://github.com/AbhiraajSharma/spotifyImplementation/assets/115367305/5f4d8029-28de-4ae3-a58f-2022c53615e1)


## Optimizations

Indexes created to index:
* Podcasts by type
* Podcasts by publisher
* Songs by genre
* Albums by release year
* Playlists by user_id
* Podcast Episodes by release_year
* Playlist Songs by playlist_id

## Limitations

The schema currently does not account for features like album or song popularity metrics, user recommendations, or detailed podcast listener statistics. Modifications and extensions would be needed to support these features.
The schema does not provide for a blend playlist which updates daily with song choices of 2+ users.
You don't get precurated playlists like 'On Repeat' 'Chill Mix'
Not focused on login security.

## Assumptions
Assuming that users can only make one account for every phone number

## Future Scope
To add a liked songs list for each user
To add the snake game implementation
Keeping track of popularity metrics like number of monthly listeners for artists, etc.
