DROP DATABASE IF EXISTS Forums;
CREATE DATABASE Forums;

CREATE TYPE accountType AS ENUM ('user', 'admin', 'moderator');
CREATE TYPE reportType AS ENUM ('Post', 'Listing', 'Profile');


DROP TABLE IF EXISTS suspendedUser, Reports, Listing, wordFilter, ForumLinkPrefix,
    Moderator, threadRead, threadSubscription, Post, Thread, Prefix, Forum, "User" CASCADE;

-- Create tables
CREATE TABLE "User" (
    userID SERIAL PRIMARY KEY,
    firstName VARCHAR(30) NOT NULL,
    lastName VARCHAR(30) NOT NULL,
    email VARCHAR(50) NOT NULL,
    password VARCHAR(50) NOT NULL,
    displayName VARCHAR(50),
    accType accountType DEFAULT 'user',
    lastActivity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inactive VARCHAR(1) DEFAULT '0',
    referralCode VARCHAR(10) DEFAULT '0000000',
    referredBy INT,
    rating DECIMAL DEFAULT 0.0,
    signupComplete BOOLEAN DEFAULT FALSE
);

CREATE TABLE Forum (
    forumID SERIAL PRIMARY KEY,
    parentID INT,
    name VARCHAR(30) NOT NULL,
    description TEXT NOT NULL,
    isCategory BOOLEAN DEFAULT FALSE,
    forum_order INT,
    isLocked BOOLEAN DEFAULT FALSE,
    numberOfPosts INT DEFAULT 0,
    numberOfThreads INT DEFAULT 0,
    FOREIGN KEY (parentID) REFERENCES Forum(forumID) ON DELETE SET NULL
);

CREATE TABLE Prefix (
    prefixID SERIAL PRIMARY KEY,
    name VARCHAR(20)
);

CREATE TABLE Thread (
    threadID SERIAL PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    prefixID INT,
    forumID INT NOT NULL,
    postedOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    numberOfReplies INT DEFAULT 0,
    userID INT NOT NULL,
    isLocked BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (prefixID) REFERENCES Prefix(prefixID),
    FOREIGN KEY (forumID) REFERENCES Forum(forumID),
    FOREIGN KEY (userID) REFERENCES "User"(userID)
);

CREATE TABLE Post (
    postID SERIAL PRIMARY KEY,
    parentPostID INT,
    threadID INT NOT NULL,
    authorID INT NOT NULL,
    forumID INT NOT NULL,
    createdOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    editedOn TIMESTAMP DEFAULT NULL,
    editedByID INT,
    content TEXT NOT NULL,
    FOREIGN KEY (parentPostID) REFERENCES Post(postID) ON DELETE SET NULL,
    FOREIGN KEY (threadID) REFERENCES Thread(threadID),
    FOREIGN KEY (authorID) REFERENCES "User"(userID),
    FOREIGN KEY (forumID) REFERENCES Forum(forumID),
    FOREIGN KEY (editedByID) REFERENCES "User"(userID)
);

CREATE TABLE threadSubscription (
    subscriptionID SERIAL PRIMARY KEY,
    threadID INT NOT NULL,
    userID INT NOT NULL,
    whenSubscribed TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (threadID) REFERENCES Thread(threadID),
    FOREIGN KEY (userID) REFERENCES "User"(userID)
);

CREATE TABLE threadRead (
    readID SERIAL PRIMARY KEY,
    threadID INT NOT NULL,
    userID INT NOT NULL,
    whenRead TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (threadID) REFERENCES Thread(threadID),
    FOREIGN KEY (userID) REFERENCES "User"(userID)
);

CREATE TABLE Moderator (
    moderatorID SERIAL PRIMARY KEY,
    forumID INT NOT NULL,
    userID INT NOT NULL,
    modPermissions TEXT,
    FOREIGN KEY (forumID) REFERENCES Forum(forumID),
    FOREIGN KEY (userID) REFERENCES "User"(userID)
);

CREATE TABLE ForumLinkPrefix (
    ForumLinkPrefixID SERIAL PRIMARY KEY,
    prefixID INT NOT NULL,
    forumID INT NOT NULL,
    FOREIGN KEY (prefixID) REFERENCES Prefix(prefixID),
    FOREIGN KEY (forumID) REFERENCES Forum(forumID)
);

CREATE TABLE wordFilter (
    wordFilterID SERIAL PRIMARY KEY,
    badWord VARCHAR(15) NOT NULL,
    replacement VARCHAR(15) DEFAULT '******'
);

CREATE TABLE Listing (
    listingID SERIAL PRIMARY KEY,
    userID INT NOT NULL,
    name VARCHAR(40) NOT NULL,
    description TEXT,
    attributes TEXT,
    quantity INT DEFAULT 1,
    latitude FLOAT NOT NULL,
    longitude FLOAT NOT NULL,
    inactive VARCHAR(1) DEFAULT '0',
    zipcode VARCHAR(10) NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (userID) REFERENCES "User"(userID)
);

CREATE TABLE Reports (
    reportID SERIAL PRIMARY KEY,
    reporterID INT NOT NULL,
    respondentID INT NOT NULL,
    listingID INT,
    postID INT,
    reportedOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT,
    repType reportType DEFAULT 'Post',
    FOREIGN KEY (reporterID) REFERENCES "User"(userID),
    FOREIGN KEY (respondentID) REFERENCES "User"(userID),
    FOREIGN KEY (listingID) REFERENCES Listing(listingID),
    FOREIGN KEY (postID) REFERENCES Post(postID)
);

CREATE TABLE suspendedUser (
    suspendedUserID SERIAL PRIMARY KEY,
    userID INT NOT NULL,
    suspendedByID INT NOT NULL,
    suspendedON TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    suspensionEnd TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT,
    FOREIGN KEY (userID) REFERENCES "User"(userID),
    FOREIGN KEY (suspendedByID) REFERENCES "User"(userID)
);

INSERT INTO "User" (firstName, lastName, email, password, displayName, accType, rating, signupComplete)
VALUES
('John', 'Doe', 'john.doe@example.com', 'password123', 'jdoe', 'user', 4.5, TRUE),
('Jane', 'Smith', 'jane.smith@example.com', 'securepass', 'jsmith', 'admin', 5.0, TRUE),
('Alice', 'Johnson', 'alice.j@example.com', 'mypassword', 'alicej', 'moderator', 3.8, FALSE),
('Bob', 'Brown', 'bob.b@example.com', 'passw0rd', 'bobb', 'user', 2.7, FALSE);

INSERT INTO Forum (parentID, name, description, isCategory, forum_order, isLocked)
VALUES
(1, 'General Discussion', 'A place for general conversation.', TRUE, 1, FALSE),
(1, 'Technology', 'Discussions about tech trends and gadgets.', FALSE, 2, FALSE),
(1, 'Gaming', 'A forum dedicated to gaming enthusiasts.', FALSE, 3, FALSE),
(1, 'Announcements', 'Official announcements from admins.', FALSE, 4, TRUE);

INSERT INTO Prefix (name)
VALUES
('Discussion'),
('Help'),
('News'),
('Opinion');

INSERT INTO Thread (title, prefixID, forumID, userID, isLocked)
VALUES
('Welcome to the forums!', 3, 1, 2, FALSE),
('Best programming languages of 2024?', 1, 2, 1, FALSE),
('Top 10 games to try this year!', 4, 3, 4, FALSE),
('Forum rules and guidelines', 2, 4, 2, TRUE);

INSERT INTO Post (parentPostID, threadID, authorID, forumID, content)
VALUES
(1, 1, 2, 1, 'Welcome everyone! Feel free to introduce yourself.'),
(1, 2, 1, 2, 'Python and JavaScript are great choices for beginners!'),
(1, 3, 4, 3, 'Check out these games: Elden Ring, Baldurs Gate 3, and Cyberpunk 2077.'),
(3, 4, 2, 4, 'Please read these rules carefully before posting.');

INSERT INTO threadSubscription (threadID, userID)
VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4);

INSERT INTO threadRead (threadID, userID)
VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4);

INSERT INTO Moderator (forumID, userID, modPermissions)
VALUES
(1, 2, 'Edit threads, delete posts'),
(2, 3, 'Edit threads, lock forums'),
(3, 4, 'Delete posts'),
(4, 2, 'Full permissions');

INSERT INTO ForumLinkPrefix (prefixID, forumID)
VALUES
(1, 2),
(2, 4),
(3, 1),
(4, 3);

INSERT INTO wordFilter (badWord, replacement)
VALUES
('badword1', '******'),
('badword2', '******'),
('offensive1', '******'),
('offensive2', '******');

INSERT INTO Listing (userID, name, description, attributes, quantity, latitude, longitude, zipcode)
VALUES
(1, 'Laptop for Sale', 'A slightly used laptop in great condition.', '{"brand":"Dell", "RAM":"16GB"}', 1, 40.7128, -74.0060, '10001'),
(2, 'Gaming Console', 'Latest-gen console, barely used.', '{"brand":"Sony", "model":"PS5"}', 2, 34.0522, -118.2437, '90001'),
(3, 'Smartphone', 'Brand new smartphone, unopened.', '{"brand":"Apple", "storage":"256GB"}', 1, 41.8781, -87.6298, '60601'),
(4, 'Office Chair', 'Ergonomic office chair.', '{"color":"Black", "material":"Leather"}', 5, 37.7749, -122.4194, '94103');

INSERT INTO Reports (reporterID, respondentID, listingID, postID, reason, repType)
VALUES
(1, 2, 1, NULL, 'Listing has misleading information.', 'Listing'),
(2, 3, NULL, 2, 'Post contains inappropriate language.', 'Post'),
(3, 4, NULL, 3, 'Post is spam.', 'Post'),
(4, 1, 2, NULL, 'Listing is duplicate.', 'Listing');

INSERT INTO suspendedUser (userID, suspendedByID, suspensionEnd, reason)
VALUES
(1, 2, '2024-12-01 00:00:00', 'Violation of forum rules.'),
(3, 2, '2024-11-30 00:00:00', 'Spam posting.'),
(4, 3, '2024-12-15 00:00:00', 'Repeated warnings ignored.'),
(2, 4, '2024-12-10 00:00:00', 'Inappropriate behavior.');



-- Get all threads from a specific subforum. 
-- Does not currently sort in chronological order by most active. 
-- Does not currently indicate if the thread has been read or not. 
-- Does not currently show a preview of most recent message in the discussion.
-- order by posts timestamp distinct
SELECT 
    Thread.threadID,
    Thread.title,
    Thread.postedOn,
    Thread.numberOfReplies,
    Thread.isLocked,
    Prefix.name AS "Prefix Name",
    "User".displayName AS "Username"
FROM 
    Thread
    INNER JOIN Prefix USING(prefixID)
    INNER JOIN "User" USING(userID)
WHERE 
    Thread.forumID = 1
LIMIT 
    25;

-- Create a new post. 



