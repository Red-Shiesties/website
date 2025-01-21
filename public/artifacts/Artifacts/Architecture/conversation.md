# Conversation Endpoint

## Contents

## Orders

- Minimum Role: `User`
- Notes:
  - The DB is a bit confusing here. Who do we initiate the conversation with?

### Initiate a Conversation

- Notes:
  - We need to discuss who we initiate the conversation with, since listings/orders belong to an organization.

```json
// POST /api/conversations
{
  "listingId": str | null,
  "userId": str,
}

// HTTP 404
{
  "message": "The specified listing does not exist.",
  "data": null
}

// HTTP 404
{
  "message": "The specified user does not exist.",
  "data": null
}

// HTTP 201
{
  "message": "Conversation initiated.",
  "data": null
}
```

```mermaid
sequenceDiagram
participant  app  as  Web App
participant  service  as  Conversation  Service
participant  db  as  Database

app->>service: POST /api/conversations
alt Listing id is provided
  service->>db: Query Listing table on id
  db-->>service: Result: Listing | null
  alt Listing does not exist
    service-->>app: Reject request
  end
end

service->>db: Query User table on id
db-->>service: Result: User | null
alt User does not exist
  service-->>app: Reject request
end

service-->>db: Create a new conversation
db-->>service: Result: Conversation
service-->>app: Successully initiated a conversation
```

### Get Conversations

- Notes:
  - Suppose conversations are between users.
    - Here, we fetch the user's conversations.

```json
// GET /api/conversations

// HTTP 200
{
  "message": null,
  "data": {
    "count": 50,
    "hasNext": true,
    "nextToken": "251",
    "results": [{
      ...
    }]
  }
}
```

```mermaid
sequenceDiagram
participant  app  as  Web App
participant  service  as  Conversation  Service
participant  db  as  Database

app->>service: GET /api/conversations
service->>db: Query Conversation table on user id
db-->>service: Result: Conversation[]
service-->>app: Return list of conversations
```

### Send a Message

```json
// POST /api/conversations/{id}/messages
{
  "content": str,
  "attachments": str[]
}
```
