DROP DATABASE IF EXISTS WheelChairRepair;
CREATE DATABASE WheelChairRepair;
-- USE WheelChairRepair;
CREATE TYPE accountType AS ENUM ('user', 'admin', 'moderator');
CREATE TYPE listingState AS ENUM ('Active', 'Inactive', 'Complete', 'Archived');
CREATE TYPE orderStatus AS ENUM ('Initiated', 'Pending', 'Fulfilled', 'Voided');
CREATE TYPE requestStatus AS ENUM ('Pending', 'Accepted', 'Denied');
CREATE TYPE inviteType AS ENUM ('Organization', 'Site');

CREATE TABLE Inventory(
    inventoryID SERIAL PRIMARY KEY,
    parentInventoryID INT,
    organizationID INT,
    Name VARCHAR(40) NOT NULL,
    description VARCHAR(4000),
    location VARCHAR(100),
    FOREIGN KEY (parentInventoryID) REFERENCES Inventory(inventoryID)
);

CREATE TABLE "User"(
    userID SERIAL PRIMARY KEY,
    organizationID INT NOT NULL,
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

CREATE TABLE Organization(
    organizationID SERIAL PRIMARY KEY,
    inventoryID INT NOT NULL,
    userID INT NOT NULL,
    Name VARCHAR(40) NOT NULL,
    lastActivity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inactive VARCHAR(1) DEFAULT '0',
    services VARCHAR(4000),
    rating DECIMAL DEFAULT 0.0,
    addressLine1 VARCHAR(50),
    addressLine2 VARCHAR(50),
    city VARCHAR(30),
    state VARCHAR(15),
    zipcode INT,
    phoneNumber VARCHAR(15),
    FOREIGN KEY (inventoryID) REFERENCES Inventory(inventoryID)
);

-- Add invite expiration date to be dateSent + 14 days
CREATE TABLE Invite(
    inviteID SERIAL PRIMARY KEY,
    senderID INT NOT NULL,
    organizationID INT NOT NULL,
    recieverEmail VARCHAR(40) NOT NULL,
    description VARCHAR(4000),
    invType inviteType NOT NULL, 
    sentOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expiresOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    acceptedOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (senderID) REFERENCES "User"(userID),
    FOREIGN KEY (organizationID) REFERENCES Organization(organizationID)
);

CREATE TABLE Connections(
    connectionID SERIAL PRIMARY KEY,
    user1ID INT NOT NULL,
    user2ID INT NOT NULL,
    FOREIGN KEY (user1ID) REFERENCES "User"(userID),
    FOREIGN KEY (user2ID) REFERENCES "User"(userID)
);

CREATE TABLE Manufacturer(
    manufacturerID SERIAL PRIMARY KEY,
    name VARCHAR(30)
);

CREATE TABLE modelType(
    modelTypeID SERIAL PRIMARY KEY,
    typeName VARCHAR(30) NOT NULL
);

CREATE TABLE Model(
    modelID SERIAL PRIMARY KEY,
    manufacturerID INT NOT NULL,
    name VARCHAR(30) NOT NULL,
    year INT NOT NULL,
    FOREIGN KEY (manufacturerID) REFERENCES Manufacturer(manufacturerID)
);

CREATE TABLE modelLinkModelType(
    modelLinkModelTypeID SERIAL PRIMARY KEY,
    modelID INT NOT NULL,
    modelTypeID INT NOT NULL,
    FOREIGN KEY (modelID) REFERENCES Model(modelID),
    FOREIGN KEY (modelTypeID) REFERENCES modelType(modelTypeID)
);

CREATE TABLE partType(
    partTypeID SERIAL PRIMARY KEY,
    typeName VARCHAR(20) NOT NULL
);

CREATE TABLE Part(
    partID SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(4000),
    modelID INT NOT NULL,
    partNumber VARCHAR(30),
    FOREIGN KEY (modelID) REFERENCES Model(modelID)
);

CREATE TABLE partLinkPartType(
    partLinkPartTypeID SERIAL PRIMARY KEY,
    partID INT NOT NULL,
    partTypeID INT NOT NULL,
    FOREIGN KEY (partID) REFERENCES Part(partID),
    FOREIGN KEY (partTypeID) REFERENCES partType(partTypeID)
);

CREATE TABLE inventoryItem(
    inventoryItemID SERIAL PRIMARY KEY,
    partID INT NOT NULL,
    modelID INT NOT NULL,
    inventoryID INT NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    publicCount INT DEFAULT 0,
    notes VARCHAR(4000),
    attributes VARCHAR(4000),
    FOREIGN KEY (partID) REFERENCES Part(partID),
    FOREIGN KEY (modelID) REFERENCES Model(modelID),
    FOREIGN KEY (inventoryID) REFERENCES Inventory(inventoryID)
);

CREATE TABLE Listing(
    listingID SERIAL PRIMARY KEY,
    inventoryItemID INT NOT NULL,
    userID INT NOT NULL,
    name VARCHAR(40) NOT NULL,
    description VARCHAR(4000),
    attributes VARCHAR(4000),
    quantity INT DEFAULT 1,
    latitude FLOAT NOT NULL,
    longitude FLOAT NOT NULL,
    inactive VARCHAR(1) DEFAULT '0',
    zipcode VARCHAR(10) NOT NULL,
    state listingState DEFAULT 'Active',
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (inventoryItemID) REFERENCES inventoryItem(inventoryItemID),
    FOREIGN KEY (userID) REFERENCES "User"(userID)
);

CREATE TABLE "Order"(
    orderID SERIAL PRIMARY KEY,
    listingID INT NOT NULL,
    owner INT NOT NULL,
    recipient INT NOT NULL,
    quantity INT NOT NULL,
    status orderStatus,
    dateCreated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dateCompleted TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (listingID) REFERENCES Listing(listingID),
    FOREIGN KEY (owner) REFERENCES "User"(userID),
    FOREIGN KEY (recipient) REFERENCES "User"(userID)
);

CREATE TABLE Bookmark(
    bookmarkID INT NOT NULL,
    userID INT NOT NULL,
    listingID INT NOT NULL,
    FOREIGN KEY (userID) REFERENCES "User"(userID),
    FOREIGN KEY (listingID) REFERENCES Listing(listingID)
);

CREATE TABLE Conversation(
    conversationID SERIAL PRIMARY KEY,
    listingID INT DEFAULT NULL,
    participent1ID INT NOT NULL,
    participent2ID INT NOT NULL,
    FOREIGN KEY (listingID) REFERENCES Listing(listingID),
    FOREIGN KEY (participent1ID) REFERENCES "User"(userID),
    FOREIGN KEY (participent2ID) REFERENCES "User"(userID)
);

CREATE TABLE Message(
    messageID SERIAL PRIMARY KEY,
    senderID INT NOT NULL,
    conversationID INT NOT NULL,
    messageContent VARCHAR(4000),
    readStatus TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (senderID) REFERENCES "User"(userID),
    FOREIGN KEY (conversationID) REFERENCES Conversation(conversationID)
);

CREATE TABLE Tag(
    tagID SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE inventoryItemLinkTag(
    inventoryItemLinkTagID SERIAL PRIMARY KEY,
    inventoryItemID INT NOT NULL,
    tagID INT NOT NULL,
    FOREIGN KEY (inventoryItemID) REFERENCES inventoryItem(inventoryItemID),
    FOREIGN KEY (tagID) REFERENCES Tag(tagID)
);

CREATE TABLE Request(
    requestID SERIAL PRIMARY KEY,
    approverID INT NOT NULL,
    EIN VARCHAR(9) NOT NULL,
    firstName VARCHAR(20) NOT NULL,
    lastName VARCHAR(20) NOT NULL,
    email VARCHAR(30) NOT NULL,
    description VARCHAR(4000) NOT NULL,
    sentOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actionTakenOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status requestStatus,
    FOREIGN KEY (approverID) REFERENCES "User"(userID)
);

CREATE TABLE Review(
    reviewID SERIAL PRIMARY KEY,
    reviewerID INT NOT NULL,
    reviewedUserID INT NOT NULL,
    orderID INT NOT NULL,
    description VARCHAR(4000) NOT NULL,
    rating INT,
    sentOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reviewerID) REFERENCES "User"(userID),
    FOREIGN KEY (reviewedUserID) REFERENCES "User"(userID),
    FOREIGN KEY (orderID) REFERENCES "Order"(orderID)
);


-- Insert data into the Inventory table
INSERT INTO Inventory (inventoryID, organizationID, parentInventoryID, Name, description, location)
VALUES 
    (1, 1, NULL, 'Main Inventory', 'Central warehouse inventory.', '123 Main St'),
    (2, 1, 1, 'Electronics Inventory', 'Electronics and gadgets.', '124 Electronics St'),
    (3, 1, 1, 'Office Supplies Inventory', 'Office supplies stock.', '125 Office St'),
    (4, 2, NULL, 'Warehouse Inventory', 'General warehouse stock.', 'Warehouse District');

-- Insert data into the User table
INSERT INTO "User" (userID, organizationID, firstName, lastName, email, password, displayName, accType, lastActivity, inactive, referralCode, referredBy, rating)
VALUES 
    (1, 1, 'John', 'Doe', 'john.doe@example.com', 'password123', 'JohnD', 'admin', CURRENT_TIMESTAMP, '0', 'ABC123', NULL, 4.5),
    (2, 2, 'Jane', 'Smith', 'jane.smith@example.com', 'securepass', 'JaneS', 'user', CURRENT_TIMESTAMP, '0', 'XYZ456', 1, 4.0),
    (3, 3, 'Michael', 'Johnson', 'm.johnson@example.com', 'passw0rd', 'MikeJ', 'moderator', CURRENT_TIMESTAMP, '0', 'LMN789', 2, 4.2),
    (4, 4, 'Emily', 'Brown', 'emily.brown@example.com', 'password321', 'EmilyB', 'user', CURRENT_TIMESTAMP, '0', 'DEF012', 3, 3.8);

-- Insert data into the Organization table
INSERT INTO Organization (organizationID, inventoryID, userID,  Name, lastActivity, inactive, services, rating, addressLine1, addressLine2, city, state, zipcode, phoneNumber)
VALUES 
    (1, 1, 1, 'Alpha Tech Solutions', CURRENT_TIMESTAMP, '0', 'IT consulting, Software development', 4.5, '123 Tech Lane', NULL, 'San Francisco', 'CA', 94105, '415-555-1234'), 
    (2, 2, 2, 'Beta Electronics', CURRENT_TIMESTAMP, '0', 'Gadget retail, Electronics repair', 3.8, '456 Electronics Blvd', 'Suite 200', 'Los Angeles', 'CA', 90001, '323-555-5678'),
    (3, 3, 3, 'Gamma Office Supplies', CURRENT_TIMESTAMP, '0', 'Stationery sales, Office supplies rental', 4.2, '789 Office Dr', 'Apt 101', 'Seattle', 'WA', 98101, '206-555-9012'), 
    (4, 4, 4, 'Delta Warehouse Services', CURRENT_TIMESTAMP, '0', 'Storage services, Logistics', 4.0, '321 Logistics Rd', NULL, 'Portland', 'OR', 97204, '503-555-3456');

-- Insert data into Invite table
INSERT INTO Invite (senderID, organizationID, recieverEmail, description, invType, sentOn, expiresOn, acceptedOn)
VALUES
    (1, 1, 'alex.brown@example.com', 'Invitation to join organization', "Organization",CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
    (2, 2, 'sara.green@example.com', 'Invitation to join organization', "Organization",CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
    (3, 3, 'lisa.white@example.com', 'Invitation to join organization', "Organization",CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
    (3, 1, 'jon.frost@example.com', 'Wants to join the site', "Site",CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
    (4, 1, 'mike.blue@example.com', 'Invitation to join organization', "Organization",CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

-- Insert data into Connections table
INSERT INTO Connections (user1ID, user2ID)
VALUES
    (1, 2),
    (2, 3),
    (3, 4),
    (1, 4);

-- Insert data into Manufacturer table
INSERT INTO Manufacturer (name)
VALUES
    ('Mobility Inc'),
    ('Access Corp'),
    ('Wheel Solutions'),
    ('Assistive Innovations');

-- Insert data into modelType table
INSERT INTO modelType (typeName)
VALUES
    ('Electric'),
    ('Manual'),
    ('Sports'),
    ('Portable');

-- Insert data into Model table
INSERT INTO Model (manufacturerID, name, year)
VALUES
    (1, 'EasyMove', 2023),
    (2, 'PowerGlide', 2022),
    (3, 'FlexiWheel', 2021),
    (4, 'SportRider', 2024);

-- Insert data into modelLinkModelType table
INSERT INTO modelLinkModelType (modelID, modelTypeID)
VALUES
    (1, 1),
    (2, 1),
    (3, 2),
    (4, 3);

-- Insert data into partType table
INSERT INTO partType (typeName)
VALUES
    ('Battery'),
    ('Wheel'),
    ('Joystick'),
    ('Seat');

-- Insert data into Part table
INSERT INTO Part (name, description, modelID, partNumber)
VALUES
    ('Lithium Battery', 'High capacity lithium battery.', 1, 'LB123'),
    ('Front Wheel', 'Durable rubber front wheel.', 2, 'FW456'),
    ('Joystick Controller', 'Joystick for precise control.', 3, 'JC789'),
    ('Comfort Seat', 'Adjustable padded seat.', 4, 'CS012');

-- Insert data into partLinkPartType table
INSERT INTO partLinkPartType (partID, partTypeID)
VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4);

-- Insert data into inventoryItem table
INSERT INTO inventoryItem (partID, modelID, inventoryID, quantity, publicCount, notes, attributes)
VALUES
    (1, 1, 1, 10, 5, 'Brand new batteries', 'Color: Black'),
    (2, 2, 2, 15, 7, 'Heavy-duty wheels', 'Size: 8 inches'),
    (3, 3, 3, 5, 3, 'Standard joystick', 'Material: Plastic'),
    (3, 3, 1, 5, 3, 'new joystick', 'Material: Plastic'),
    (4, 4, 4, 8, 4, 'Comfortable seats', 'Color: Blue');

-- Insert data into Listing table
INSERT INTO Listing (inventoryItemID, userID, name, description, attributes, quantity, latitude, longitude, zipcode)
VALUES
    (1, 1, 'Item A', 'Description for Item A', 'Attributes for Item A', 5, 40.748817, -73.985428, '10001'),
    (2, 2, 'Item B', 'Description for Item B', 'Attributes for Item B', 3, 40.749641, -73.987472, '10002'),
    (3, 3, 'Item C', 'Description for Item C', 'Attributes for Item C', 2, 40.752726, -73.977229, '10003'),
    (4, 4, 'Item D', 'Description for Item D', 'Attributes for Item D', 1, 40.754932, -73.984016, '10004');

-- Insert date into the Bookmark table
INSERT INTO Bookmark (bookmarkID, userID, listingID)
VALUES
    (1, 1, 4),
    (2, 2, 3),
    (3, 3, 2),
    (4, 4, 1);

-- Insert data into Order table
INSERT INTO "Order" (listingID, owner, recipient, quantity, status, dateCreated, dateCompleted)
VALUES
    (1, 1, 2, 2, 'Fulfilled', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (2, 2, 3, 1, 'Pending', CURRENT_TIMESTAMP, NULL),
    (3, 3, 4, 1, 'Initiated', CURRENT_TIMESTAMP, NULL),
    (4, 4, 1, 1, 'Voided', CURRENT_TIMESTAMP, NULL);

-- Insert data into Conversation table
INSERT INTO Conversation (listingID, participent1ID, participent2ID)
VALUES
    (1, 1, 2),
    (2, 2, 3),
    (3, 3, 4),
    (4, 4, 1);

-- Insert data into Message table
INSERT INTO Message (senderID, conversationID, messageContent)
VALUES
    (1, 1, 'Is this item still available?'),
    (2, 1, 'Yes, it is available.'),
    (3, 3, 'What is the delivery time?'),
    (4, 4, 'Can you ship this to my location?');

-- Insert data into the Tag table
INSERT INTO Tag (name) VALUES 
    ('Electronics'), 
    ('Home Appliance'), 
    ('Furniture'), 
    ('Outdoor Equipment');

-- Insert data into the inventoryItemLinkTag
INSERT INTO inventoryItemLinkTag(inventoryItemID, tagID)
VALUES  
    (1, 4),
    (2, 3),
    (3, 2),
    (1, 3),
    (4, 1);


-- Add foreign key constraints after data insertion
ALTER TABLE "User"
    ADD FOREIGN KEY (organizationID) REFERENCES Organization(organizationID);

ALTER TABLE Organization
    ADD FOREIGN KEY (userID) REFERENCES "User"(userID);

ALTER TABLE Inventory
    ADD FOREIGN KEY(organizationID) REFERENCES Organization(organizationID);



-- Get all organization base information + inventory information
SELECT 
    Organization.organizationID, 
    Organization.Name, 
    Organization.lastActivity, 
    Organization.services, 
    Inventory.Name AS "Inventory Name", 
    Inventory.location AS "Inventory location"
FROM 
    Organization
    INNER JOIN Inventory USING (inventoryID);

-- Get all Converations 
SELECT 
    Conversation.listingID, 
    user1.displayName AS "Participant 1", 
    user2.displayName AS "Participant 2"
FROM 
    Conversation
    INNER JOIN "User" AS user1 ON Conversation.participent1ID = user1.userID
    INNER JOIN "User" AS user2 ON Conversation.participent2ID = user2.userID;

-- Get all relevant Order information
SELECT 
    "Order".orderID,
    "Order".quantity,
    "Order".status,
    Listing.name AS "Listing Name",
    Listing.description AS "Description",
    Part.name AS "inventory Item Name",
    Part.partNumber AS "Part #",
    Model.name AS "Model Name",
    Manufacturer.name AS "Manufacturer Name",
    ownerUser.displayName AS "Owner Name",
    recipientUser.displayName AS "Recipient Name"
FROM 
    "Order"
    INNER JOIN Listing USING (listingID)
    INNER JOIN inventoryItem USING (inventoryItemID)
    INNER JOIN Part USING (partID)
    INNER JOIN Model ON inventoryItem.modelID = Model.modelID
    INNER JOIN Manufacturer ON Model.manufacturerID = Manufacturer.manufacturerID
    INNER JOIN "User" AS ownerUser ON "Order".owner = ownerUser.userID
    INNER JOIN "User" AS recipientUser ON "Order".recipient = recipientUser.userID;


-- Get all relavent information about a listing
SELECT 
    Listing.inventoryItemID,
    "User".displayName AS "Seller",
    Listing.name AS "Listing Name",
    Part.name AS "Part Name",
    Listing.description AS "Description",
    inventoryItem.attributes AS "Attributes",
    Listing.quantity AS "QTY",
    Listing.latitude,
    Listing.longitude,
    Listing.zipcode
FROM 
    Listing
    INNER JOIN "User" USING(userID)
    INNER JOIN inventoryItem USING(inventoryItemID)
    INNER JOIN Part USING(partID);

-- Show all the invites that a specific user has sent
SELECT
    "User".displayName AS "Sender",
    Invite.organizationID,
    Invite.recieverEmail AS "Recipient",
    Invite.description AS "Reason for invite",
    Invite.sentOn,
    Invite.expiresOn,
    Invite.acceptedOn
FROM
    Invite
    INNER JOIN "User" ON Invite.senderID = "User".userID
WHERE 
    Invite.senderID = 3;

-- Show all the conversations that a specific user is in
SELECT 
    Conversation.listingID,
    Listing.name AS "Listing Name", 
    user1.displayName AS "Participant 1", 
    user2.displayName AS "Participant 2"
FROM 
    Conversation
    INNER JOIN "User" AS user1 ON Conversation.participent1ID = user1.userID
    INNER JOIN "User" AS user2 ON Conversation.participent2ID = user2.userID
    INNER JOIN Listing USING (listingID)
WHERE user1.userID =  1 OR  user2.userID = 1;

-- Show all a specific users connections
SELECT 
    user1.displayName AS "Main User",
    user2.displayName AS "Connections"
FROM 
    Connections
    INNER JOIN "User" AS user1 ON Connections.user1ID = user1.userID
    INNER JOIN "User" AS user2 ON Connections.user2ID = user2.userID
WHERE Connections.user1ID = 1;

-- Show all the inventory items in an organization inventories
SELECT
    Organization.Name AS "Organization Name",
    Inventory.name AS "Inventory Name",
    Inventory.parentInventoryID AS "Parent Inventory",
    Inventory.description,
    Inventory.location,
    Manufacturer.name AS "Manufacturer Name",
    Model.name AS "Model Year",
    Model.year,
    Part.name AS "Part Name",
    Part.description,
    Part.partNumber AS "Part #",
    inventoryItem.quantity AS "Total QTY",
    inventoryItem.publicCount AS "Public QTY",
    inventoryItem.notes,
    inventoryItem.attributes
FROM 
    inventoryItem
    INNER JOIN Inventory ON inventoryItem.inventoryID = Inventory.inventoryID
    INNER JOIN Organization ON Inventory.organizationID = Organization.organizationID
    INNER JOIN Part ON inventoryItem.partID = Part.partID
    INNER JOIN Model ON inventoryItem.modelID = Model.modelID
    INNER JOIN Manufacturer ON Model.manufacturerID = Manufacturer.manufacturerID
WHERE
    Inventory.inventoryID = 1 OR Inventory.parentInventoryID = 1;

-- Show all users where rating is < 4.1
SELECT 
    "User".displayName AS 'Display name',
    "User".firstName AS 'First Name',
    "User".lastName AS 'Last Name',
    "User".email,
    "User".accType AS "Account Type", 
    "User".lastActivity, 
    "User".referralCode AS "Referral Code",
    "User".rating AS "Rating"
FROM 
    "User"
WHERE 
    rating < 4.1;

-- Show all users where rating is > 4.1
SELECT 
    "User".displayName AS 'Display name',
    "User".firstName AS 'First Name',
    "User".lastName AS 'Last Name',
    "User".email,
    "User".accType AS "Account Type", 
    "User".lastActivity, 
    "User".referralCode AS "Referral Code",
    "User".rating AS "Rating"
FROM 
    "User"
WHERE 
    rating > 4.1;

-- Show a users bookmarks
SELECT  
    Bookmark.bookmarkID,
    "User".firstName AS 'First Name',
    "User".lastName AS 'Last Name',
    Listing.name AS 'Listing Name',
    Part.name AS 'Part Name',
    Listing.description AS "Description",
    inventoryItem.attributes AS "Attributes",
    Listing.quantity AS "QTY",
    Listing.latitude,
    Listing.longitude,
    Listing.zipcode
FROM 
    Bookmark
    INNER JOIN "User" ON Bookmark.userID = "User".userID
    INNER JOIN Listing ON Bookmark.listingID = Listing.listingID
    INNER JOIN inventoryItem ON Listing.inventoryItemID = inventoryItem.inventoryItemID
    INNER JOIN Part ON inventoryItem.partID = Part.partID
WHERE 
    "User".userID = 1;

-- Show all messages from a conversation regarding a specific listing
SELECT 
    Conversation.listingID,
    Listing.name AS "Listing Name", 
    user1.displayName AS "Participant 1", 
    user2.displayName AS "Participant 2",
    Message.messageContent AS "Content"
FROM 
    Conversation
    INNER JOIN "User" AS user1 ON Conversation.participent1ID = user1.userID
    INNER JOIN "User" AS user2 ON Conversation.participent2ID = user2.userID
    INNER JOIN Listing USING (listingID)
    INNER JOIN Message USING (conversationID)
WHERE 
    Listing.listingID = 1;

-- Show all the parts associated with a specific manufacturer
SELECT 
    Model.year AS "Model Year",
    Manufacturer.name AS "Manufacturer Name",
    Model.name AS "Model Name",
    Part.name AS "Part Name",
    Part.description,
    Part.partNumber AS "Part Number"
FROM 
    Part
    INNER JOIN Model USING (modelID)
    INNER JOIN Manufacturer ON Model.manufacturerID = Manufacturer.manufacturerID
WHERE
    Manufacturer.name = 'Mobility Inc';

-- Show all the parts related to a specific model
SELECT 
    Model.year AS "Model Year",
    Manufacturer.name AS "Manufacturer Name",
    Model.name AS "Model Name",
    Part.name AS "Part Name",
    Part.description,
    Part.partNumber AS "Part Number"
FROM 
    Part
    INNER JOIN Model USING (modelID)
    INNER JOIN Manufacturer ON Model.manufacturerID = Manufacturer.manufacturerID
WHERE
    Model.name = 'EasyMove';

-- Show all the parts in a particular type
SELECT 
    Model.year AS "Model Year",
    Manufacturer.name AS "Manufacturer Name",
    Model.name AS "Model Name",
    Part.name AS "Part Name",
    Part.description,
    Part.partNumber AS "Part Number",
    partType.typeName AS "Part Type"
FROM 
    partLinkPartType
    INNER JOIN partType USING (partTypeID)
    INNER JOIN Part USING (partID)
    INNER JOIN Model ON Part.modelID = Model.modelID
    INNER JOIN Manufacturer ON Model.manufacturerID = Manufacturer.manufacturerID
WHERE
    partType.typeName = 'Wheel';