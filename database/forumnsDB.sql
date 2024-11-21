DROP DATABASE IF EXISTS Forums;
CREATE DATABASE Forums;
USE Forums;

CREATE TABLE User(
    userID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    firstName VARCHAR(30) NOT NULL,
    lastName VARCHAR(30) NOT NULL,
    email VARCHAR(50) NOT NULL,
    password VARCHAR(50) NOT NULL,
    displayName VARCHAR(50),
    accType ENUM('user', 'admin', 'moderator') NOT NULL DEFAULT 'user',
    addressLine1 VARCHAR(50),
    addressLine2 VARCHAR(50),
    city VARCHAR(30),
    state VARCHAR(15),
    zipcode int,
    lastActivity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inactive VARCHAR(1) DEFAULT '0',
    referralCode VARCHAR(10) DEFAULT '0000000',
    referredBy INT,
    rating DOUBLE DEFAULT 0.0,
    signupComplete BOOLEAN DEFAULT FALSE
);

CREATE TABLE Forum(
    forumID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    parentID INT NOT NULL,
    name VARCHAR(30) NOT NULL,
    description LONGTEXT NOT NULL,
    isCategory BOOLEAN DEFAULT FALSE,
    order INT,
    isLocked BOOLEAN DEFAULT FALSE,
    numberOfPosts INT DEFAULT 0,
    numberOfThreads INT DEFAULT 0,
    FOREIGN KEY (parentID) REFERENCES Forum(forumID),
);

CREATE TABLE Prefix(
    prefixID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20)
);

CREATE TABLE Thread(
    threadID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    prefixID INT,
    forumID INT NOT NULL,
    postedOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    numberOfReplies INT DEFAULT 0,
    userID INT NOT NULL,
    isLocked BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (prefixID) REFERENCES Prefix(prefixID),
    FOREIGN KEY (forumID) REFERENCES Forum(forumID),
    FOREIGN KEY (userID) REFERENCES User(userID),
);

CREATE TABLE Post(
    postID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    parentPostID INT NOT NULL,
    threadID INT NOT NULL,
    authorID INT NOT NULL,
    forumID INT NOT NULL,
    createdOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    editedOn TIMESTAMP DEFAULT NULL,
    editedByID INT,
    content LONGTEXT NOT NULL,
    FOREIGN KEY (parentPostID) REFERENCES Post(postID),
    FOREIGN KEY (threadID) REFERENCES Thread(threadID),
    FOREIGN KEY (authorID) REFERENCES User(userID),
    FOREIGN KEY (forumID) REFERENCES Forum(forumID),
    FOREIGN KEY (editedByID) REFERENCES User(userID)
);

CREATE TABLE threadSubscription(
    subscriptionID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    threadID INT NOT NULL,
    userID INT NOT NULL,
    whenSubscribed TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (threadID) REFERENCES Thread(threadID),
    FOREIGN KEY (userID) REFERENCES User(userID)
);

CREATE TABLE threadRead(
    readID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    threadID INT NOT NULL,
    userID INT NOT NULL,
    whenRead TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (threadID) REFERENCES Thread(threadID),
    FOREIGN KEY (userID) REFERENCES User(userID)
);

CREATE TABLE Moderator(
    moderatorID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    forumID INT NOT NULL,
    userID INT NOT NULL,
    modPermissions LONGTEXT,
    FOREIGN KEY (forumID) REFERENCES Forum(forumID),
    FOREIGN KEY (userID) REFERENCES User(userID)
);

CREATE TABLE ForumLinkPrefix(
    ForumLinkPrefixID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    prefixID INT NOT NULL,
    forumID INT NOT NULL,
    FOREIGN KEY (prefixID) REFERENCES Prefix(prefixID),
    FOREIGN KEY (forumID) REFERENCES Forum(forumID)
);

CREATE TABLE wordFilter(
    wordFilterID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    badWord VARCHAR(15) NOT NULL,
    replacement VARCHAR(15) DEFAULT "******"
);

CREATE TABLE Listing(
    listingID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    userID INT NOT NULL,
    name VARCHAR(40) NOT NULL,
    description LONGTEXT,
    attributes LONGTEXT,
    quantity INT DEFAULT 1,
    latitude FLOAT NOT NULL,
    longitude FLOAT NOT NULL,
    inactive VARCHAR(1) DEFAULT '0',
    zipcode VARCHAR(10) NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (userID) REFERENCES User(userID)
);

CREATE TABLE Reports(
    reportID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    reporterID INT NOT NULL,
    respondentID INT NOT NULL,
    listingID INT,
    postID INT,
    reportedOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason LONGTEXT,
    reportType ENUM("Post", "Listing", "Profile") NOT NULL,
    FOREIGN KEY (reporterID) REFERENCES User(userID),
    FOREIGN KEY (respondentID) REFERENCES User(userID),
    FOREIGN KEY (listingID) REFERENCES Listing(listingID),
    FOREIGN KEY (postID) REFERENCES Post(postID)
);

CREATE TABLE suspendedUser(
    suspendedUserID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    userID INT NOT NULL,
    suspendedByID INT NOT NULL,
    suspendedON TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    suspensionEnd TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason LONGTEXT,
    FOREIGN KEY (userID) REFERENCES User(userID),
    FOREIGN KEY (suspendedByID) REFERENCES User(userID)
);



INSERT INTO User (firstName, lastName, email, password, displayName, accType, addressLine1, city, state, zipcode, rating, signupComplete)
VALUES
('John', 'Doe', 'john.doe@example.com', 'password123', 'jdoe', 'user', '123 Main St', 'Springfield', 'IL', 62704, 4.5, TRUE),
('Jane', 'Smith', 'jane.smith@example.com', 'securepass', 'jsmith', 'admin', '456 Oak Ave', 'Bloomington', 'IL', 61701, 5.0, TRUE),
('Alice', 'Johnson', 'alice.j@example.com', 'mypassword', 'alicej', 'moderator', '789 Pine Rd', 'Champaign', 'IL', 61820, 3.8, FALSE),
('Bob', 'Brown', 'bob.b@example.com', 'passw0rd', 'bobb', 'user', '101 Maple Dr', 'Peoria', 'IL', 61602, 2.7, FALSE);

INSERT INTO Forum (parentID, name, description, isCategory, order, isLocked)
VALUES
(0, 'General Discussion', 'A place for general conversation.', TRUE, 1, FALSE),
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
(0, 1, 2, 1, 'Welcome everyone! Feel free to introduce yourself.'),
(1, 2, 1, 2, 'Python and JavaScript are great choices for beginners!'),
(0, 3, 4, 3, 'Check out these games: Elden Ring, Baldur’s Gate 3, and Cyberpunk 2077.'),
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

INSERT INTO Reports (reporterID, respondentID, listingID, postID, reason, reportType)
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
    User.displayName AS "Username"
FROM 
    Thread
    INNER JOIN Prefix USING(prefixID)
    INNER JOIN User USING(userID)
WHERE 
    Thread.forumID = 1
LIMIT 
    25;

-- Create a new post. 



