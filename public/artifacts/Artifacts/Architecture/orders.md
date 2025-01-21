# Orders Endpoint

## Contents

- [Get Orders](#get-orders)
- [Get an Order](#get-an-order)
- [Creating an Order](#creating-an-order)
- [Updating an Order](#updating-an-order)
- [Leaving a Review](#leaving-a-review)

## Orders

- Minimum Role: `User`
- Notes:

### Get Orders

- Notes:
  - This will be an organization's orders.

```json
// GET /api/orders

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
participant  app  as Web App
participant  service  as  Orders Service
participant  db  as  Database

app->>service: GET /api/orders
service->>db: Query Order table
db-->>service: Result: Order[]
service-->>app: Return order details
```

### Get an Order

```json
// GET /api/orders/{id}

// HTTP 404
{
  "message": "An order with the specified ID does not exist.",
  "data": null
}

// HTTP 403
{
  "message": "You do not have permission to access this order.",
  "data": null
}

// HTTP 200
{
  "message": null,
  "data": {
    ...
  }
}
```

```mermaid
sequenceDiagram
participant  app  as Web App
participant  service  as Orders Service
participant  db  as Database

app->>service: GET /api/orders/{id}
service->>db: Query Order table on id
db-->>service: Result: Order | null
alt Order does not exist
  service-->>app: Reject request
end

alt Order does not belong to the user's organization
  service-->>app: Reject request
end

service-->>app: Return order details
```

### Creating an Order

- Notes:
  - The order will be attached to users' organizations.
  - With who is the conversation initiated with?

```json
// POST /api/orders
{
  "listingId": str,
  "quantity": int
}

// HTTP 404
{
  "message": "A listing with the specified ID does not exist.",
  "data": null
}

// HTTP 403
{
  "message": "The listing is inactive and cannot be ordered.",
  "data": null
}

// HTTP 403
{
  "message": "You do not have permission to create an order for this listing.",
  "data": null
}

// HTTP 200
{
  "message": "Successfully created the order!",
  "data": null
}
```

```mermaid
sequenceDiagram
participant  app  as Web App
participant  service1  as Orders Service
participant  db  as Database
participant  service2  as Conversation Service

app->>service1: POST /api/orders
service1->>db: Query Listing table on listingId
db-->>service1: Result: Listing | null
alt Listing does not exist
  service1-->>app: Reject request
end

alt Listing is inactive
  service1-->>app: Reject request
end

alt Listing is in a terminal state
  service1-->>app: Reject request
end

service1-->>db: Create Order
db-->>service1: Success
service1->>service2: Initiate conversation with organization
service2-->>service1: Success
service1-->>app: Successfully created the order
```

### Updating an Order

- Notes:
  - The request will specify the attributes that are being updated, alongside the new values.
  - I'm not sure what else can be updated...

```json
// PATCH /api/orders/{id}
{
  "quantity": int,
  "status": INTIATED | PENDING | FULLFILLED | VOIDED
}

// HTTP 404
{
  "message": "An order with the specified ID does not exist.",
  "data": null
}

// HTTP 403
{
  "message": "You do not have permission to update this order.",
  "data": null
}

// HTTP 403
{
  "message": "The order is in a terminal state and cannot be updated.",
  "data": null
}

// HTTP 200
{
  "message": "Successfully updated the order!",
  "data": null
}
```

```mermaid
sequenceDiagram
participant  app  as Web App
participant  service  as Orders Service
participant  db  as Database

app->>service: PATCH /api/orders/{id}
service->>db: Query Order table on id
db-->>service: Result: Order | null
alt Order does not exist
  service-->>app: Reject request
end

alt Order does not belong to the user's organization
  service-->>app: Reject request
end

alt Order is in a terminal state
  service-->>app: Reject request
end

service-->>db: Update Order
db-->>service: Success
service-->>app: Successfully updated the order
```

### Leaving a Review

- Notes:
  - The rating is attached to the order, but maps to an organization.
  - Notice that we use a PUT request to update the review.
    - This allows us to update the review if the user changes their mind.
    - Should / Are we logging changes?
    - Are we still moving forward with the idea of waiting 2 weeks?
  - The reviewable state is `FULLFILLED`.

```json
// PUT /api/orders/{id}/reviews
{
  "rating": int,
  "comment": str
}

// HTTP 404
{
  "message": "An order with the specified ID does not exist.",
  "data": null
}

// HTTP 403
{
  "message": "You do not have permission to leave a review for this order.",
  "data": null
}

// HTTP 403
{
  "message": "The order is not in a reviewable state.",
  "data": null
}

// HTTP 200
{
  "message": "Successfully left a review!",
  "data": null
}
```

```mermaid
sequenceDiagram
participant  app  as Web App
participant  service  as Orders Service
participant  db  as Database

app->>service: PUT /api/orders/{id}/reviews
service->>db: Query Order table on id
db-->>service: Result: Order | null
alt Order does not exist
  service-->>app: Reject request
end

alt Order does not belong to the user's organization
  service-->>app: Reject request
end

alt Order is not in a reviewable state
  service-->>app: Reject request
end

service-->>db: Update Order
db-->>service: Success
service-->>app: Successfully left a review
```
