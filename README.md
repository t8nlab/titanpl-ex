# TitanPL Server Example

A high-performance, production-ready server built with **TitanPL**, featuring user authentication and PostgreSQL integration.

## 🚀 Getting Started

### 1. Prerequisites
- [Rust](https://www.rust-lang.org/tools/install) installed. (optional)
- npm i -g @titanpl/cli
- A PostgreSQL database instance.
- [Postman](https://www.postman.com/) or any HTTP client for testing.

### 2. Environment Construction
Create a `.env` file in the root directory and add your PostgreSQL connection string:

```env
DB_URI=postgresql://USER:PASSWORD@HOST:PORT/DATABASE
```

### 3. Database Schema
For the authentication system to work, you must have a `users` table. Run the following SQL command in your database:

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL
);
```

> **Note**: The `password` field expects a **bcrypt** hash. For testing purposes, you can generate a hash online or use a tool.

---

## 🛠️ Installation & Running

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Start the development server**:
   ```bash
   npm run dev
   ```
   The server will start on `http://localhost:5100` (configured in `app/app.js`).

---

## 🛣️ API Documentation & Testing

### 1. Manual Login Route
- **URL**: `POST /login`
- **Description**: Authenticates a user using custom manual logic. Returns a JWT token.
- **Request Body (JSON)**:
  ```json
  {
    "username": "testuser",
    "password": "yourpassword"
  }
  ```
- **Response**:
  ```json
  {
    "auth_method": "manual",
    "success": true,
    "token": "eyJhbGci...",
    "user": {
      "id": 1,
      "username": "testuser",
      "email": "test@example.com"
    }
  }
  ```

#### 🔍 How it Works (Action: `login`)
1. **Manual Parsing**: Extracts `username` and `password` from the request body.
2. **FS Query**: Loads the raw SQL from `app/db/login.sql` via native FS.
3. **Drift Bridge**: Executes DB queries synchronously within the action.
4. **Bcrypt Verification**: Manually compares the password hash.
5. **JWT Issuance**: Signs a token manually with a secret key (`jii`).

---

### 2. Secure Login Route (IAuth)
- **URL**: `POST /iauth-login`
- **Description**: Authenticates a user using the **IAuth Extension**. Returns a JWT token.
- **Request Body (JSON)**:
  ```json
  {
    "username": "testuser",
    "password": "yourpassword"
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "token": "eyJhbGci...",
    "user": {
      "id": 1,
      "username": "testuser",
      "email": "test@example.com"
    }
  }
  ```

#### 🔍 How it Works (Action: `iauthlg`)
1. **Abstraction**: The entire login flow is handled by `auth.signIn(req.body)`.
2. **Configuration**: Uses the settings in `app/auth/config.js` for DB table and field mapping.
3. **Security**: Automatically handles hashing, JWT creation, and data scrubbing.

---

### 3. Profile Route (Secure Guard)
- **URL**: `GET /me`
- **Description**: Retrieves the current user's payload from the bearer token.
- **Headers**:
  ```json
  {
    "Authorization": "Bearer YOUR_JWT_TOKEN_HERE"
  }
  ```
- **Response**:
  ```json
  {
    "id": 1,
    "username": "testuser",
    "email": "test@example.com",
    "iat": 1740475163,
    "exp": 1740475223
  }
  ```

#### 🔍 How it Works (Action: `me`)
1. **Auth Guard**: Uses `auth.guard(req)` to verify the token in the incoming request.
2. **Auto-Decoding**: If the token is valid, it returns the decoded user payload.
3. **Access Control**: This pattern allows you to protect any route with a single function call.

---

## 📖 Further Reading

For a detailed explanation of the business logic and how the actions work, see [ACTIONS_LOGIC.md](./ACTIONS_LOGIC.md).
