# TitanPL Server Example

A high-performance, production-ready server built with **TitanPL**, featuring user authentication and PostgreSQL integration.

## 🚀 Getting Started

### 1. Prerequisites
- [Rust](https://www.rust-lang.org/tools/install) installed.
- npm i -g @ezetgalaxy/titan
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

### 1. Login Route
- **URL**: `POST /lg`
- **Description**: Authenticates a user and returns a JWT token.
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

#### 🔍 How it Works (Action: `login`)
1. **Request Parsing**: Extracts `username` and `password` from the request body.
2. **SQL Execution**: Loads the query from `app/db/login.sql` and searches for the user in the database using `t.db.connect`.
3. **Password Verification**: Uses `bcryptjs.compareSync` to verify the provided password against the stored hash.
4. **Token Generation**: If valid, it signs a JWT token using `t.jwt.sign` with a 1-minute expiration and a secret key (`jii`).
5. **Security**: Removes the password from the user object before returning it to the client.

---

### 2. Profile Route
- **URL**: `POST /me`
- **Description**: Verifies a JWT token and returns the user payload.
- **Request Body (JSON)**:
  ```json
  {
    "tk": "YOUR_JWT_TOKEN_HERE"
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
1. **Token Retrieval**: Extracts the token `tk` from the POST body.
2. **Verification**: Uses `t.jwt.verify` with the internal secret key (`jii`).
3. **Decoding**: If the token is valid and not expired, it returns the decoded JSON payload (user data). Otherwise, it throws an error/returns null.

---

## 📖 Further Reading

For a detailed explanation of the business logic and how the actions work, see [ACTIONS_LOGIC.md](./ACTIONS_LOGIC.md).

