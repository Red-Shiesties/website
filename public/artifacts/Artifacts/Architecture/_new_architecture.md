# Architecture

## Overview

## Contents

- [Services (Stack)](#services-stack)
  - [Backend](#backend)
  - [Frontend](#frontend)
- [Protected Routes (Role Based Authentication)](#protected-routes-role-based-authentication)
  - [Handling Protected Routes](#handling-protected-routes)
- [Important Notes](#important-notes)
- [Logging](#logging)
- [Handling Forms](#handling-forms)
- [Handling Query Parameters](#handling-query-parameters)
- [Result Format](#result-format)
- [Pagination](#pagination)

## Services (Stack)

### Backend

- NestJS
- TypeORM
- PostgreSQL

### Frontend

- VueJS
- Vuetify

## Protected Routes (Role Based Authentication)

- We will use [Guards](https://docs.nestjs.com/guards) to protect routes that require authentication.
- For the sake of simplicity, we will have four roles:
  - Admin: An admin of the site has access to all features.
  - Mod: Mod over forums.
  - Organization Owner: An organization owner has access to all features of their organization, and those of a user.
  - User: A user has access to all features of their account.
  - Guest: A guest has access to the public features of the site.
- These roles are hierarchical, with the Admin having the highest level of access, and the Guest having the lowest level of access. (no role because a user cannot be a guest)

### Handling Protected Routes

- We will use the `@Roles` decorator to specify the roles that can access a route.
- The folloing should be return for a route that is protected:
  - `401 Unauthorized` if the user is not authenticated.
  - `403 Forbidden` if the user is authenticated but does not have the correct role.

```json
// HTTP 401
{
  "message": "You must be authenticated to access this resource.",
  "data": null
}

// HTTP 403
{
  "message": "You do not have permission to access this resource.",
  "data": null
}
```

## Important Notes

- For all routes that handle forms, we need to ensure we validate the form.
  - Is the provided email address a valid email address?
  - Is the provided password strong enough?
- We need to ensure all routes return the same format.
- Ensure we implement proper error handling.
- Ensure we use the correct HTTP status codes.
  - https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
- Ensure `message` and `displayMessage` are used correctly and are detailed enough for the user to understand what happened.
- Ensure a protected route is properly guarded.
  - A Guest should be able to access the `Connections` route.
  - A User should not be able to access the `Admin` route.
- Ensure request are logged and sensitive information is not logged.
- Ensure we reject large requests

## Logging

- Ensure all routes log the request and response.
  - Be careful not to log sensitive information.
- Log user actions that are important.

## Handling Forms

- As noted earlier, we need to ensure we validate all forms. Below is an example on how we should peform form validation.
- From here on out, we will not describe form validation in detail, but it should be implemented for all routes that handle forms.

```json
// HTTP 400

{
  "message": "Invalid form data.",
  "data": {
    "email": "Email is required.",
    "password": "Password is required."
  }
}
```

## Handling Query Parameters

- We need to ensure we handle query parameters correctly. Below is an example of how we should handle query parameters.
- From here on out, we will not describe query parameters in detail, but it should be implemented for all routes that handle query parameters.

```json
// HTTP 400

{
  "message": "Invalid query parameters.",
  "data": {
    "latitude": "Latitude is required.",
    "longitude": "Longitude is required."
  }
}
```

## Result Format

```json
{
  "message": string | null,
  "data": object | null
}
```

## Pagination

- For routes that return a list of items, we need to ensure proper pagination is implemented. Below is an example of how we should handle pagination.
- From here on out, we will not describe pagination in detail, but it should be implemented for all routes that return a list of items.

```json
// HTTP 200

{
  "message": null,
  "data": {
    "count": 50,
    "total": 1000,
    "hasNext": true,
    "nextToken": "251",
    "results": [{
      ...
    }]
  }
}
```
