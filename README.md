# Pantry Planner

Pantry Planner is an application that helps users organize the food in their
pantries, save their favorite recipes, and plan out their meal prep.

Plan meals on a calendar, see what ingredients those meals require, and know
what to buy.

See [the design document](docs/design.md) for the domain model, the unit system,
and the reasoning behind the main decisions.

> **Status:** in development. The database schema and backend scaffolding are in
> place; the API and frontend are not yet built.

## Tech Stack

**Backend**
- Java 21 (Eclipse Temurin)
- Spring Boot 4.1.1:
    - Spring Web, Spring Data JDBC, PostgreSQL Driver
- Maven

**Database**
- PostgreSQL 18

**Frontend**
- Next.js (not yet added)

## Prerequisites

- **JDK 21** or later: [Eclipse Temurin](https://adoptium.net/)
- **PostgreSQL 18**: [postgresql.org](https://www.postgresql.org/download/)
- **Node.js 20.9+**: for the frontend (once it exists)
- **Git**

Maven is not required. The project includes the Maven Wrapper (`mvnw`).

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/rayirving/pantry-planner.git
cd pantry-planner
```

### 2. Create the database and application role

Connect to PostgreSQL as a superuser:

```bash
psql -h localhost -p 5432 -U postgres -d postgres
```

Then create the role and database:

```sql
CREATE ROLE pantry_planner_app WITH LOGIN PASSWORD '<your-password>';
CREATE DATABASE pantry_planner OWNER pantry_planner_app;
```

### 3. Create the schema

```bash
psql -h localhost -p 5432 -U pantry_planner_app -d pantry_planner -f <path-to-schema.sql>
```

### 4. Set environment variables

The application reads its database credentials from the environment. Only the
password is required. The other two have defaults suitable for a local setup.

| Variable | Required | Default |
|---|---|---|
| `PANTRY_DB_PASSWORD` | Yes | — |
| `PANTRY_DB_URL` | No | `jdbc:postgresql://localhost:5432/pantry_planner` |
| `PANTRY_DB_USERNAME` | No | `pantry_planner_app` |

On Windows (PowerShell), for the current session:

```powershell
$env:PANTRY_DB_PASSWORD = "<your-password>"
```

To set it permanently, use **Edit the system environment variables** &rarr;
**Environment Variables** &rarr; **User variables** &rarr; **New**. A new terminal is
required for the change to take effect.

### 5. Run the backend

```bash
cd backend
.\mvnw.cmd spring-boot:run     # Windows
./mvnw spring-boot:run         # macOS / Linux
```

The application starts on port 8080.

To build and run the tests instead:

```bash
.\mvnw.cmd clean verify
```

## Project Structure

```
pantry-planner/
├── backend/        Spring Boot application
├── docs/           Design documentation
└── frontend/       Next.js application (not yet added)
```