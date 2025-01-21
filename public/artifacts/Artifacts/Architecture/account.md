# Account Endpoint

## Contents

- [Connections](#connections)
  - [Get Connections](#get-connections)
  - [Create a Connection](#create-a-connection)
  - [Remove a Connection](#remove-a-connection)

## Connections

- Minimum Role: `User`
- Notes:
  - A connection is a relationship between two users. A user can have multiple connections. A connection is a one-way relationship. If user A is connected to user B, user B is not necessarily connected to user A.

### Get Connections

- Notes: Make sure we JOIN on the User (and possible Organization) table to get details about the connection.

```json
// GET /api/account/connections

// HTTP 200
{
  "message": null,
  "data": {
    "connections": [
      {
        "id":"...",
        "firstName": "...",
        "lastName": "...",
        "email": "...",
        "organization": {
          ...
        }
      },
      ...
    ]
  }
}
```

```mermaid
sequenceDiagram
participant  app  as  Web App
participant  service  as  Account  Service
participant  db  as  Database

app->>service: GET /api/account/connections
service->>db: Query Connection table for all connections
db-->>service: Result: Connection[]
service-->>app: Return connection details
```

### Create a Connection

```json
// PUT /api/account/connections/{id}

// HTTP 400
{
  "message": "A user with the specified email address does not exist.",
  "data": null
}

// HTTP 200
{
  "message": "Successfully created a connection with {user}!",
  "data": null
}
```

```mermaid
sequenceDiagram
participant  app  as  Web App
participant  service  as  Account  Service
participant  db  as  Database

app->>service: PUT /api/account/connections/{id}
service->>db: Query User table on email
db-->>service: Result: User | null
alt User does not exist
service-->>app: Reject request
else User exist
service->>db: Insert record into Connection table
db-->>service: Success
service-->>app: Successfully created a Connection
end
```

### Remove a Connection

```json
// DELETE /api/account/connections/{id}

// HTTP 400
{
  "message": "A connection with the specified ID does not exist.",
  "data": null
}

// HTTP 200
{
  "message": "Successfully removed a connection!",
  "data": null
}


```

```mermaid
sequenceDiagram
participant  app  as  Web App
participant  service  as  Account  Service
participant  db  as  Database

app->>service: DELETE /api/account/connections/{id}
service->>db: Query Connection table on ID
db-->>service: Result: Connection | null
alt Connection does not exist
service-->>app: Reject request
else Connection exist
service->>db: Delete record from Connection table
db-->>service: Success
service-->>app: Successfully removed a Connection
end
```

##
