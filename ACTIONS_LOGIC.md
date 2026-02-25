# Actions & Logic Documentation

This document explains the development workflow and the business logic behind the application actions.

## 🛤️ Route Definitions

Routes are defined in `app/app.js` using the TitanPL routing API. This is the entry point for your application logic.

```javascript
// app/app.js
import t from "@titan/route";

t.post("/lg").action("login");
t.post("/me").action("me");
t.get("/").reply("Read the README.md file to know everything");

t.start(5100, "Titan Running!");
```

---

## ⚙️ Action Logic Details

### 1. Login Action (`app/actions/login.js`)

The `login` action handles user authentication by verifying credentials against the database and issuing a security token.

#### Key Steps:
1.  **Schema Loading**: Dynamically loads the SQL query from `app/db/login.sql` using the native filesystem API.
2.  **Input Validation**: Ensures both `username` and `password` are provided in the request body.
3.  **Database Lookup**:
    *   Establishes a connection via the shared `db()` utility.
    *   Executes the query using `drift()`, which allows asynchronous database operations to behave synchronously within the action.
4.  **Security Verification**:
    *   Uses `bcryptjs` to compare the plain-text password from the user with the hashed password stored in the database. This ensures passwords are never stored in plain text.
5.  **Token Issuance**:
    *   On successful verification, it generates a JSON Web Token (JWT) using `t.jwt.sign`.
    *   The token contains the user's `id`, `username`, and `email`.
    *   The password field is explicitly deleted from the user object before sending the response to ensure data privacy.

---

### 2. Me Action (`app/actions/me.js`)

The `me` action is a protected utility that retrieves user information from a provided session token.

#### Key Steps:
1.  **Token Extraction**: Reads the `tk` (token) field from the request body.
2.  **JWT Verification**: Uses the `jwt.verify` native module with the application's secret key (`jii`) to decode the token.
3.  **State Recovery**: If the token is valid, it returns the decoded user payload stored inside the JWT, allowing the frontend to know "who" is logged in without querying the database again.

---

## 🗄️ Database Integration

Logic related to data persistence is separated into `app/db/`:

-   **`db.js`**: Centralizes the connection logic using `t.db.connect`. It uses the `DB_URI` from your environment variables.
-   **`login.sql`**: Contains the raw SQL for fetching users, keeping queries decoupled from the JavaScript code for better maintainability.

---

> **Development Note**: All application logic resides within the `app/` directory. The `server/` directory is automatically managed by the TitanPL runtime and does not require manual modifications during development.
