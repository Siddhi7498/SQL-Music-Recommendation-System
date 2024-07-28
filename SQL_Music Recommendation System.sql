CREATE DATABASE MusicSystem;
USE MusicSystem;

-- Create Users Table
CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    gender VARCHAR(10)
);
-- Insert Users
INSERT INTO Users (user_id, name, age, gender) VALUES
(1, 'siddhi', 30, 'Female'),
(2, 'ritesh', 25, 'Male'),
(3, 'priyansh', 35, 'Male');

-- Create Songs Table
CREATE TABLE Songs (
    song_id INT PRIMARY KEY,
    title VARCHAR(100),
    artist VARCHAR(100),
    genre VARCHAR(50)
);
-- Insert Songs
INSERT INTO Songs (song_id, title, artist, genre) VALUES
(1, 'Song A', 'Artist 1', 'Pop'),
(2, 'Song B', 'Artist 2', 'Rock'),
(3, 'Song C', 'Artist 3', 'Pop'),
(4, 'Song D', 'Artist 1', 'Jazz'),
(5, 'Song E', 'Artist 2', 'Rock');

-- Create Listening History Table
CREATE TABLE Listening_History (
    history_id INT PRIMARY KEY,
    user_id INT,
    song_id INT,
    timestamp DATETIME,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (song_id) REFERENCES Songs(song_id)
);
-- Insert Listening History
INSERT INTO Listening_History (history_id, user_id, song_id, timestamp) VALUES
(1, 1, 1, '2024-07-25 08:00:00'),
(2, 1, 3, '2024-07-26 09:00:00'),
(3, 2, 2, '2024-07-26 10:00:00'),
(4, 2, 5, '2024-07-27 11:00:00'),
(5, 3, 1, '2024-07-25 14:00:00'),
(6, 3, 4, '2024-07-27 15:00:00');

-- Create Ratings Table
CREATE TABLE Ratings (
    rating_id INT PRIMARY KEY,
    user_id INT,
    song_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (song_id) REFERENCES Songs(song_id)
);
-- Insert Ratings
INSERT INTO Ratings (rating_id, user_id, song_id, rating) VALUES
(1, 1, 1, 5),
(2, 1, 3, 4),
(3, 2, 2, 3),
(4, 2, 5, 4),
(5, 3, 1, 2),
(6, 3, 4, 5);

-- Get top 10 most listened to songs
SELECT Songs.song_id, Songs.title, Songs.artist, COUNT(*) AS listen_count
FROM Listening_History
JOIN Songs ON Listening_History.song_id = Songs.song_id
GROUP BY Songs.song_id, Songs.title, Songs.artist
ORDER BY listen_count DESC
LIMIT 10;

-- Find users with similar listening history
WITH UserPreferences AS (
    SELECT user_id, song_id, COUNT(*) AS listen_count
    FROM Listening_History
    GROUP BY user_id, song_id
)
SELECT A.user_id AS user_a, B.user_id AS user_b, COUNT(*) AS common_songs
FROM UserPreferences A
JOIN UserPreferences B ON A.song_id = B.song_id AND A.user_id <> B.user_id
GROUP BY A.user_id, B.user_id
ORDER BY common_songs DESC;

-- Recommend songs liked by similar users
WITH SimilarUsers AS (
    SELECT A.user_id AS user_a, B.user_id AS user_b, COUNT(*) AS common_songs
    FROM Listening_History A
    JOIN Listening_History B ON A.song_id = B.song_id AND A.user_id <> B.user_id
    GROUP BY A.user_id, B.user_id
)
SELECT Songs.song_id, Songs.title, Songs.artist, COUNT(*) AS recommendation_score
FROM SimilarUsers
JOIN Listening_History ON SimilarUsers.user_b = Listening_History.user_id
JOIN Songs ON Listening_History.song_id = Songs.song_id
WHERE SimilarUsers.user_a = 1  -- Replace with the target user ID
GROUP BY Songs.song_id, Songs.title, Songs.artist
ORDER BY recommendation_score DESC
LIMIT 10;

-- Recommend songs based on user's favorite genres
WITH FavoriteGenres AS (
    SELECT user_id, genre, COUNT(*) AS genre_count
    FROM Listening_History
    JOIN Songs ON Listening_History.song_id = Songs.song_id
    GROUP BY user_id, genre
)
SELECT Songs.song_id, Songs.title, Songs.artist, Songs.genre
FROM FavoriteGenres
JOIN Songs ON FavoriteGenres.genre = Songs.genre
WHERE FavoriteGenres.user_id = 2  -- Replace with the target user ID
ORDER BY Songs.genre DESC
LIMIT 10;