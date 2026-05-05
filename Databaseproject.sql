CREATE DATABASE MovieDB;
USE MovieDB;

CREATE TABLE Genres (
    GenreID INT IDENTITY(1,1) PRIMARY KEY,
    GenreName VARCHAR(50) UNIQUE
);
GO

INSERT INTO Genres (GenreName)
VALUES 
('Action'),('Comedy'),('Drama'),('Horror'),('Sci-Fi'),
('Romance'),('Thriller'),('Adventure'),('Animation'),('Fantasy'),
('Crime'),('Mystery'),('War'),('History'),('Biography'),
('Music'),('Sport'),('Family'),('Documentary'),('Western');
GO

CREATE TABLE Movies (
    MovieID INT IDENTITY(1,1) PRIMARY KEY,
    Title VARCHAR(255),
    GenreID INT,
    ReleaseYear INT,
    Rating DECIMAL(3,1),
    Views INT DEFAULT 0,
    Description VARCHAR(MAX),
    FOREIGN KEY (GenreID) REFERENCES Genres(GenreID)
);
GO

CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username VARCHAR(50) UNIQUE,
    Password VARCHAR(50)
);
GO


CREATE TABLE WatchHistory (
    WatchID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT,
    MovieID INT,
    WatchDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (MovieID) REFERENCES Movies(MovieID)
);
GO

CREATE TABLE Reviews (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT,
    MovieID INT,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comment VARCHAR(MAX),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (MovieID) REFERENCES Movies(MovieID)
);
GO


CREATE TABLE Recommendation_Backup (
    BackupID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT,
    MovieID INT,
    RecommendedOn DATETIME DEFAULT GETDATE()
);
GO

CREATE TRIGGER trg_UpdateViews
ON WatchHistory
AFTER INSERT
AS
BEGIN
    UPDATE Movies
    SET Views = Views + 1
    WHERE MovieID IN (SELECT MovieID FROM inserted);
END;
GO

CREATE TRIGGER trg_BackupRecommendation
ON Reviews
AFTER INSERT
AS
BEGIN
    INSERT INTO Recommendation_Backup (UserID, MovieID)
    SELECT UserID, MovieID FROM inserted;
END;
GO


CREATE PROCEDURE SearchMovie
    @Keyword VARCHAR(100)
AS
BEGIN
    SELECT * 
    FROM Movies
    WHERE Title LIKE '%' + @Keyword + '%'
       OR Description LIKE '%' + @Keyword + '%';
END;
GO



CREATE PROCEDURE GetMoviesByGenre
    @GenreID INT
AS
BEGIN
    SELECT * FROM Movies
    WHERE GenreID = @GenreID;
END;
GO


CREATE PROCEDURE GetTopMovies
AS
BEGIN
    SELECT TOP 10 * 
    FROM Movies
    ORDER BY Rating DESC, Views DESC;
END;
GO



CREATE PROCEDURE RecommendMovies
    @UserID INT
AS
BEGIN
    SELECT TOP 5 M.*
    FROM Movies M
    JOIN WatchHistory W ON M.GenreID = 
        (SELECT TOP 1 GenreID 
         FROM Movies 
         WHERE MovieID = W.MovieID)
    WHERE W.UserID = @UserID
    ORDER BY M.Rating DESC;
END;
GO



CREATE FUNCTION GetAverageRating (@MovieID INT)
RETURNS DECIMAL(3,2)
AS
BEGIN
    DECLARE @AvgRating DECIMAL(3,2);

    SELECT @AvgRating = AVG(CAST(Rating AS DECIMAL))
    FROM Reviews
    WHERE MovieID = @MovieID;

    RETURN ISNULL(@AvgRating,0);
END;
GO



CREATE VIEW TopViewedMovies AS
SELECT Title, Views
FROM Movies;
GO

CREATE VIEW GenreAnalysis AS
SELECT G.GenreName, COUNT(M.MovieID) AS TotalMovies
FROM Genres G
LEFT JOIN Movies M ON G.GenreID = M.GenreID
GROUP BY G.GenreName;
GO


CREATE VIEW MovieRatings AS
SELECT Title, dbo.GetAverageRating(MovieID) AS AvgRating
FROM Movies;
GO


INSERT INTO Movies (Title, GenreID, ReleaseYear, Rating, Description)
VALUES
('Shadow Strike', 1, 2022, 7.3, 'A rogue agent must stop a global cyberattack before it triggers world war.'),
('Whispering Canyon', 2, 2019, 8.1, 'Two brothers raft down an uncharted river and uncover ancient secrets.'),
('Dream Weaver', 3, 2021, 8.7, 'An animated journey of a young tailor who sews dreams into reality.'),
('Office Annihilation', 4, 2020, 6.9, 'Bored employees turn their cubicle farm into a chaotic battleground.'),
('Midnight Confession', 5, 2018, 7.5, 'A hitman seeks absolution from a priest who knows too much.'),
('Plastic Ocean', 6, 2023, 8.4, 'Documentary exposing the hidden plastic crisis in our oceans.'),
('Fences of Iron', 7, 2016, 8.9, 'A steelworker''s family struggles through the 1980s recession.'),
('Paws & Claws', 8, 2015, 7.2, 'A talking cat and dog team up to save their owner''s bakery.'),
('The Last Griffin', 9, 2020, 8.0, 'In a world without magic, a girl finds the last mythical beast.'),
('Basement 13', 10, 2022, 6.8, 'Teens unlock a door in a condemned basement and unleash a curse.'),
('Clockwork Alibi', 11, 2019, 7.7, 'A detective must solve a murder that happened two hours before the victim died.'),
('Lavender Skies', 12, 2021, 8.3, 'Two strangers meet nightly on a rooftop and fall in love without speaking.'),
('Quantum Drift', 13, 2023, 8.5, 'A pilot crash-lands on a planet where time moves sideways.'),
('Blind Witness', 14, 2017, 7.9, 'A blind woman overhears a kidnapping and must outrun the kidnappers.'),
('Dust and Lead', 15, 2016, 7.4, 'A retired gunslinger defends a ghost town from railroad bandits.'),
('Neon Reckoning', 1, 2024, 7.1, 'A futuristic biker gang races to stop a mind-control chip rollout.'),
('The Silk Road Heist', 2, 2018, 8.2, 'A treasure hunter tracks a lost caravan through the Gobi Desert.'),
('Starlight Express', 3, 2020, 8.6, 'A paperboy''s drawings come alive in a magical subway train.'),
('Divorce Party', 4, 2019, 6.5, 'Three friends throw a wild party to celebrate a divorce.'),
('The Accountant''s Lie', 5, 2021, 7.6, 'A forensic accountant fakes his death to escape a cartel.'),
('Notes from Chernobyl', 6, 2022, 8.9, 'Harrowing documentary about the liquidators of the nuclear disaster.'),
('The Bicycle Thief''s Son', 7, 2017, 8.0, 'A boy in post-war Italy tries to redeem his family''s honor.'),
('Grandma''s Robot', 8, 2016, 7.0, 'A grandma builds a clumsy robot to help her win a bake-off.'),
('Goblin Market', 9, 2022, 7.8, 'A girl must trade memories for fruit in a mystical bazaar.'),
('The Hollowing', 10, 2019, 7.3, 'A family''s farmhouse slowly consumes their souls room by room.'),
('Three Keys', 11, 2020, 7.9, 'A lockmaker inherits three keys that open impossible doors.'),
('Raincheck in Tokyo', 12, 2018, 8.1, 'A chance umbrella swap leads to a year-long romance.'),
('Echo in the Void', 13, 2022, 8.4, 'An astronaut hears her dead daughter''s voice from a black hole.'),
('The Second Floor', 14, 2021, 7.5, 'A security guard finds a hidden floor that predicts deaths.'),
('High Chaparral Showdown', 15, 2019, 7.2, 'A sheriff must choose between the law and his outlaw brother.'),
('Redline Rivals', 1, 2020, 7.4, 'Underground street racers gamble their lives for a billion-dollar prize.'),
('Forgotten Island', 2, 2017, 8.0, 'A biologist discovers a island where evolution ran wild.'),
('The Lost Brush', 3, 2023, 8.8, 'An animator''s brush paints worlds that fight back against erasure.'),
('Bad Wedding', 4, 2018, 6.7, 'A bridezilla accidentally marries the caterer instead of the groom.'),
('The Safe', 5, 2022, 7.8, 'Four thieves crack a safe that contains only a single photograph.'),
('My Octopus Teacher 2', 6, 2024, 8.6, 'Follow-up documentary on ocean intelligence and empathy.'),
('Oranges for Christmas', 7, 2015, 7.9, 'A Depression-era family scrapes together gifts for their sick mother.'),
('The Magic Sneakers', 8, 2019, 6.9, 'A shy kid''s sneakers let him run through any wall.'),
('Frostheart', 9, 2021, 8.2, 'A boy and his talking wolf seek the last ember of summer.'),
('The Nursery Rhyme', 10, 2020, 7.1, 'A nanny''s lullaby summons creatures from the walls.'),
('The Vanishing of Vera', 11, 2022, 7.6, 'A journalist vanishes – her blog posts keep updating.'),
('Postcards from Prague', 12, 2017, 8.4, 'A deaf painter and a musician fall in love across a bridge.'),
('Silicon God', 13, 2024, 8.7, 'An AI that runs a city asks to be worshipped.'),
('The Night Courier', 14, 2019, 7.9, 'A bike messenger carries packages that could start a war.'),
('Six Bullets for Judas', 15, 2018, 7.5, 'A preacher turned bounty hunter tracks his own son.'),
('Fists of Silicon', 1, 2021, 7.2, 'Cyborg boxers fight for freedom in an underground league.'),
('The Map of Bones', 2, 2020, 8.3, 'A cartographer finds a map that leads to the land of the dead.'),
('Cuckoo Clock', 3, 2019, 8.0, 'A cuckoo bird leaves its clock and explores a human house.'),
('Therapy Dogs', 4, 2022, 6.8, 'Two failed actors become therapy dogs to pay rent.'),
('The Last Bribe', 5, 2018, 7.7, 'A corrupt mayor''s final payoff goes horribly wrong.'),
('Inside the Whale', 6, 2023, 8.5, 'Documentary on a marine biologist living inside a whale replica.'),
('The Shoemaker''s Tears', 7, 2016, 8.1, 'A cobbler repairs shoes for ghosts who forgot to die.'),
('My Alien Best Friend', 8, 2017, 7.1, 'A boy hides a tiny alien from his overbearing mom.'),
('The Unicorn''s Debt', 9, 2020, 7.9, 'A unicorn must repay a loan shark with magical favors.'),
('The Latchkey', 10, 2021, 7.4, 'A child''s key opens a door that should have stayed shut.'),
('The Enigma of Room 304', 11, 2019, 8.0, 'Every guest who stays in room 304 forgets their past.'),
('A Thousand Paper Cranes', 12, 2022, 8.6, 'A terminally ill girl folds cranes that grant wishes for others.'),
('The Gravity Well', 13, 2020, 8.3, 'A scientist falls into a gravity anomaly and meets her double.'),
('The Seventh Witness', 14, 2018, 7.8, 'Six witnesses saw nothing – the seventh saw everything.'),
('The Hangman''s Daughter', 15, 2020, 7.6, 'A young woman takes over her father''s executioner duties.'),
('Velocity', 1, 2023, 7.5, 'A paramedic discovers her ambulance is rigged to explode.'),
('The Sapphire Crown', 2, 2016, 8.2, 'A thief steals a crown that curses her with truth-telling.'),
('The Paper Orchestra', 3, 2022, 8.9, 'Animated short about a boy who makes instruments from trash.'),
('Weekend at Barney''s', 4, 2019, 6.4, 'Two guys drag a dead boss around a resort to cash his paycheck.'),
('The Silent Partner', 5, 2021, 7.9, 'A lawyer''s silent partner is a ghost who knows all the secrets.'),
('Dust to Dust', 6, 2018, 8.3, 'Documentary on the last remaining village of traditional potters.'),
('The Lemon Tree', 7, 2019, 8.0, 'A Palestinian and an Israeli woman argue over a lemon tree.'),
('Super Diaper Baby', 8, 2015, 6.5, 'A baby with super strength fights a villainous pacifier.'),
('The Clockmaker''s Curse', 9, 2021, 7.7, 'A clock that stops time also stops hearts.'),
('The Well', 10, 2017, 7.2, 'A wish-granting well gives you what you fear most.'),
('The Dead Pianist', 11, 2020, 7.9, 'A piano plays itself every night – the notes reveal a murder.'),
('Letters from a War', 12, 2018, 8.5, 'Two lovers exchange letters during a war that never ends.'),
('The Memory Thief', 13, 2022, 8.1, 'A device steals memories – but the thief forgets who he is.'),
('The Blue Hour', 14, 2021, 7.6, 'A cop''s only witness to a crime is a blind child.'),
('Boot Hill Requiem', 15, 2017, 7.8, 'A dying outlaw hires a musician to play at his own funeral.'),
('Nitro Circus', 1, 2020, 7.0, 'A stuntman must deliver a heart across town in 60 minutes.'),
('The Lost Compass', 2, 2023, 8.4, 'A compass that points to what you truly want – not north.'),
('The Stuffed Animal Rebellion', 3, 2021, 8.2, 'Toys come alive to stop a factory from shredding them.'),
('The Wrong Funeral', 4, 2020, 6.6, 'A man attends the wrong funeral and inherits a fortune.'),
('The Smuggler''s Confession', 5, 2019, 7.4, 'A smuggler confesses to a priest – who is an undercover agent.'),
('The Last Roll of Kodachrome', 6, 2024, 8.8, 'Documentary about the last roll of color film shot on Earth.'),
('The Glass Harmonica', 7, 2018, 8.2, 'A musician who plays glass harmonica hears the world''s pain.'),
('The Secret of Uncle Bob', 8, 2016, 7.0, 'A nephew discovers his boring uncle was a superhero.'),
('The Pumpkin Knight', 9, 2019, 7.9, 'A scarecrow comes to life to defend a harvest festival.'),
('The Red Envelope', 10, 2022, 7.3, 'An envelope of money brings a curse that kills greedily.'),
('The Whispering Statues', 11, 2021, 7.8, 'Statues in a park whisper clues to a 100-year-old murder.'),
('The Umbrella Maker', 12, 2020, 8.3, 'An umbrella that opens only when true love is near.'),
('The Eternal Algorithm', 13, 2023, 8.6, 'A coder discovers the universe is a simulation – and her code fixes it.'),
('The Listener', 14, 2019, 7.7, 'A 911 operator receives a call from a future murder victim.'),
('The Orphan Train', 15, 2018, 7.5, 'A boy on an orphan train outruns a posse that wants him dead.'),
('The Last Gladiator', 1, 2021, 7.4, 'A genetically engineered gladiator rebels against his creators.'),
('The River of Stars', 2, 2017, 8.3, 'A girl follows a glowing river to the edge of the world.'),
('The Button Box', 3, 2020, 8.1, 'A grandmother''s buttons each contain a lost memory.'),
('The Accidental Time Traveler', 4, 2019, 6.9, 'A slacker travels to the Middle Ages and invents pizza.'),
('The Diamond Chip', 5, 2022, 7.6, 'A casino heist goes wrong when the chip is a tracking device.'),
('The Beekeeper of Aleppo', 6, 2021, 8.7, 'Documentary of a beekeeper who rebuilds hives in war zones.'),
('The Last Library', 7, 2020, 8.4, 'A librarian guards the only remaining books after a digital apocalypse.'),
('The Flying Bed', 8, 2018, 7.2, 'A child''s bed flies around the world to deliver dreams.'),
('The Mirror of Souls', 9, 2023, 8.5, 'A mirror shows not your reflection but your other self.'),
('The Harvest Moon', 10, 2018, 7.0, 'A werewolf curse spreads through a small town every harvest.'),
('The Silent Choir', 11, 2022, 7.9, 'A church choir that cannot speak solves mysteries through song.'),
('The Love Equation', 12, 2019, 8.2, 'A mathematician calculates the formula for love – then tests it.'),
('The Android''s Lament', 13, 2024, 8.8, 'An android dreams of being human – and wakes up as one.'),
('The Thirteenth Step', 14, 2020, 7.9, 'An addiction counselor''s patients keep dying – on purpose.'),
('The Coyote''s Revenge', 15, 2019, 7.6, 'A Native American tracker hunts the men who stole his land.');
INSERT INTO Movies (Title, GenreID, ReleaseYear, Rating, Description)
VALUES
('pk', 15, 2019, 7.6, 'A Native American tracker hunts the men who stole his land.');

GO

-- Search
EXEC SearchMovie 'Fast';

-- Genre search
EXEC GetMoviesByGenre 1;

-- Top movies
EXEC GetTopMovies;

-- Recommendation
EXEC RecommendMovies 1;

-- Views
SELECT * FROM TopViewedMovies;

-- Analysis
SELECT * FROM GenreAnalysis;

-- Ratings
SELECT * FROM MovieRatings;

-- Function
SELECT dbo.GetAverageRating(1);

