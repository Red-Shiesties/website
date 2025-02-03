# Conversation Endpoint

- Minimum Role: `User`

## Contents

- [Conversation](#conversation)
  - [Initiate a Conversation](#initiate-a-conversation)
  - [Get Conversations](#get-conversations)
  - [Add attachments to a message](#add-attachments-to-a-message)
  - [Send a Message](#send-a-message)
  - [Get Messages](#get-messages)
  - [Update a Message](#update-a-message)
  - [Delete a Message](#delete-a-message)

## Conversation

- Minimum Role: `User`

### Initiate a Conversation

```json
// POST /api/conversations
{
  "userId": str,
  "listingId": str | null
}

// HTTP 400 (if userId is missing)
{
  "message": "userId is required.",
  "data": null
}

// HTTP 404 (if userId is invalid)
{
  "message": "The specified user does not exist.",
  "data": null
}

// HTTP 404 (if listingId is provided but invalid
// (consider listings in terminal state)
{
  "message": "The specified listing does not exist.",
  "data": null
}

// HTTP 201
{
  "message": "Conversation initiated.",
  "data": {
    "id": "conversationId",
    "listingId": "listingId" | null,
    "user": {
      "id": "userId",
      "firstName": "firstName",
      "lastName": "lastName",
      "username": "username",
      "displayName": "displayName",
      "organization": {
        "id": "organizationId",
        "name": "organizationName"
      }
    }
  }
```

```mermaid
sequenceDiagram
participant  app  as  Web App
participant  service  as  Conversation  Service
participant  db  as  Database

app->>service: POST /api/conversations
service->>db: Query User table on userId
db-->>service: Result: User | null
alt User does not exist
  service-->>app: Reject request with "User does not exist"
end

alt listingId is provided
    service->>db: Query Listing table on listingId
    db-->>service: Result: Listing | null
    alt Listing does not exist or is in terminal state
        service-->>app: Reject request
    end
end

service-->>db: Create a new conversation with userId and optional listingId
db-->>service: Result: Conversation created
service-->>app: Successfully initiated a conversation
```

### Get Conversations

```json
// GET /api/conversations?nextToken={nextToken}&count={count}

// HTTP 200
{
  "message": null,
  "data": {
    "count": 50,
    "hasNext": true,
    "nextToken": "251",
    "results": [
      {
        "id": "conversationId",
        "listingId": "listingId",
        "user": {
          "id": "userId",
          "firstName": "firstName",
          "lastName": "lastName",
          "username": "username",
          "displayName": "displayName",
          "organization": {
            "id": "organizationId",
            "name": "organizationName"
          }
        }
      }
    ]
  }
}
```

```mermaid
sequenceDiagram
participant  app  as  Web App
participant  service  as  Conversation  Service
participant  db  as  Database

app->>service: GET /api/conversations
service->>db: Query Conversation table and join User and Organization tables
db-->>service: Result: Conversation[]
service-->>app: Return list of conversations
```

### Add attachments to a message

- The file should be uploaded to S3 and the attachment metadata should be saved in the database.
- This is a different endpoint from sending a message because the file upload is a separate process.

```json
// POST /api/conversations/{id}/attachments
{
  // For binary data, you'd use multipart/form-data
  "file": <binary data>
}

// HTTP 404
{
  "message": "Conversation not found.",
  "data": null
}

// HTTP 400
{
  "message": "File is required.",
  "data": null
}

// HTTP 413
{
  "message": "File size exceeds the limit.",
  "data": null
}

// HTTP 415 (consider HEIC)
{
  "message": "Unsupported file type.",
  "data": null
}

// HTTP 201
{
  "message": "Attachment uploaded successfully.",
  "data": {
    "attachmentId": "attachmentId",
    "fileUrl": "fileUrl",
    "fileName": "fileName",
    "fileSize": 0,
    "fileType": "fileSize"
  }
}
```

```mermaid
sequenceDiagram
participant app as Web App
participant service as Conversation Service
participant db as Database
participant s3 as S3 (Cloudflare)

app->>service: POST /api/conversations/{id}/attachments
service->>db: Check if Conversation exists
db-->>service: Result: Conversation | null
alt Conversation does not exist
  service-->>app: Reject request
end

service->>s3: Upload file to S3
s3-->>service: Result: File URL
service->>db: Create a new attachment linked to conversation
db-->>service: Result: Attachment created
service-->>app: Return attachment info
```

### Send a Message

- Either `content` or `attachments` must be provided.

```json
// POST /api/conversations/{id}/messages
{
  "content": "content",
  "attachments": ["attachmentId"]
}

// HTTP 404
{
  "message": "Conversation not found.",
  "data": null
}

// HTTP 400 (require content or attachments)
{
  "message": "Cannot send an empty message.",
  "data": null
}

// HTTP 201
{
  "message": "Message sent successfully.",
  "data": {
    "messageId": "messageId",
    "content": "content",
    "attachments": [
      {
        "attachmentId": "attachmentId",
        "fileUrl": "fileUrl",
        "fileName": "fileName",
        "fileSize": 0,
        "fileType": "fileSize"
      }
    ]
  }
}
```

```mermaid
sequenceDiagram
participant app as Web App
participant service as Conversation Service
participant db as Database

app->>service: POST /api/conversations/{id}/messages
service->>db: Check if Conversation exists
db-->>service: Result: Conversation | null
alt Conversation does not exist
  service-->>app: Reject request
end

service->>db: Create a new message linked to attachment(s)
db-->>service: Message created successfully with attachment metadata
service-->>app: Return message confirmation with attachment info
```

### Get Messages

- The messages should be ordered by the `createdAt` timestamp in descending order.
  - The first element in the array should be the most recent message.

```json
// GET /api/conversations/{id}/messages?nextToken=15&count=10

// HTTP 200
{
  "message": null,
  "data": {
    "count": 10,
    "hasNext": true,
    "nextToken": "15",
    "results": [
      {
        "messageId": "msg123",
        "content": "Here's a photo",
        "attachments": [
          {
            "attachmentId": "abc123",
            "fileUrl": "https://api.example.com/attachments/abc123",
            "fileName": "image.jpg",
            "fileSize": 2048,
            "fileType": "image/jpeg"
          }
        ]
      }
    ]
  }
}
```

```mermaid
sequenceDiagram
participant app as Web App
participant service as Conversation Service
participant db as Database

app->>service: GET /api/conversations/{id}/messages
service->>db: Check if Conversation exists
db-->>service: Result: Conversation | null
alt Conversation does not exist
  service-->>app: Reject request
end

service->>db: Query Message table and join Attachment table
db-->>service: Result: Message[]
service-->>app: Return list of messages
```

### Update a Message

- The values passed into the request body are what will be updated. For example, an empty `content` will remove the content of the message. An empty `attachments` will remove all attachments from the message.
  - If you want to remove a specific attachment, you will need to pass in all the other attachments and exclude the one you want to remove.
  - You cannot add new attachments to a message.
  - Either `content` or `attachments` must be provided.
  - The updated record must not have an empty `content` and `attachments` (one of them must be non-empty).

```json
// PATCH /api/conversations/{id}/messages/{messageId}
{
  "content": "content",
  "attachments": ["attachmentId"]
}

// HTTP 404
{
  "message": "Message not found.",
  "data": null
}

// HTTP 400
{
  "message": "Cannot update to an empty message.",
  "data": null
}

// HTTP 200
{
  "message": "Message updated successfully.",
  "data": {
    "messageId": "messageId",
    "content": "content",
    "attachments": [
      {
        "attachmentId": "attachmentId",
        "fileUrl": "fileUrl",
        "fileName": "fileName",
        "fileSize": 0,
        "fileType": "fileSize"
      }
    ]
  }
}
```

```mermaid
sequenceDiagram
participant app as Web App
participant service as Conversation Service
participant db as Database

app->>service: PATCH /api/conversations/{id}/messages/{messageId}
service->>db: Check if Message exists
db-->>service: Result: Message | null
alt Message does not exist
  service-->>app: Reject request
end

service->>db: Update message with new content and/or attachments
db-->>service: Message updated successfully with attachment metadata
service-->>app: Return message confirmation with attachment info
```

### Delete a Message

- Deleting a message will remove the message from the conversation.

```json
// DELETE /api/conversations/{id}/messages/{messageId}

// HTTP 404
{
  "message": "Message not found.",
  "data": null
}

// HTTP 200
{
  "message": "Message successfully deleted.",
  "data": null
}
```

```mermaid
sequenceDiagram
participant app as Web App
participant service as Conversation Service
participant db as Database

app->>service: DELETE /api/conversations/{id}/messages/{messageId}
service->>db: Check if Message exists
db-->>service: Result: Message | null
alt Message does not exist
  service-->>app: Reject request
end

service->>db: Delete message
db-->>service: Message deleted successfully
service-->>app: Return success message
```
