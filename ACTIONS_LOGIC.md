# 🔐 Authentication Logic Documentation

This document explains the two authentication methods implemented in this application: **Manual Login Logic** and the **IAuth Extension**.

---

## 🛤️ Application Routes

Routes are defined in `app/app.js`. We provide two endpoints for login to demonstrate both manual and automated authentication.

```javascript
// app/app.js
import t from "@titanpl/route";

// Manual Login (Plain logic)
t.post("/login").action("login");

// Secure Login (via IAuth extension)
t.post("/iauth-login").action("iauthlg");

t.get("/me").action("me");
t.start(5100);
```

---

## ⚙️ Action Logic Comparison

### 1. Manual Login Action (`app/actions/login.js`)

This action represents the "manual" way of handling authentication. It gives you full control but requires manual management of every security step.

#### 🏗️ Implementation Details:
*   **FS Query Loading**: Loads raw SQL from `app/db/login.sql` using the native filesystem.
*   **Manual Validation**: Explicitly checks for presence of `username` and `password`.
*   **Native DB Query**: Executes the query using the `drift()` bridge for synchronous-style execution.
*   **Manual Bcrypt Comparison**: Uses `bcryptjs` to manually verify the hashed password.
*   **Manual Token Generation**: Uses `t.jwt.sign` to create a security token with a manual payload and secret.

> [!WARNING]
> While flexible, manual login requires you to manually handle token expiration, security headers, and data scrubbing.

---

### 2. IAuth Extension Login (`app/actions/iauthlg.js`)

This is the **TitanPl Secure Auth Extension**. It simplifies authentication by abstracting the database lookups, security comparisons, and token management into a single, secure interface.

#### 🏗️ Implementation Details:
*   **Configuration-Based**: Everything is configured once in `app/auth/config.js`.
*   **One-Liner Execution**: The entire login flow is handled by `auth.signIn(req.body)`.
*   **Built-in Security**: Automatically handles secure password hashing, timing attack protection, and proper JWT payload management.
*   **Scoped Returns**: Only returns the fields defined in your `scope` config, ensuring sensitive data (like password hashes) never leaks.

> [!TIP]
> **Why use IAuth?** It reduces boilerplate, follows security best practices, and minimizes the risk of implementation errors in your authentication logic.

---

## 🗄️ Shared Infrastructure

Both methods utilize the same underlying database configuration:

-   **`app/db/db.js`**: Centralized database connection sharing.
-   **`app/auth/config.js`**: Configuration for the `IAuth` extension, defining which database table and fields to use for identity and security.

---

> **Development Note**: All application logic resides within the `app/` directory. The system automatically routes requests from the integrated server to these JavaScript actions.
