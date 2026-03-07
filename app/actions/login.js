// app/actions/login.js
/**
 * MANUAL LOGIN LOGIC
 * This file demonstrates the manual way to handle authentication.
 * It manually performs validation, DB lookups, password hashing checks, and JWT issuance.
 */

import "@titanpl/node/globals";
import { fs, response } from "@titanpl/native";
import { db } from "../db/db.js";
import bcrypt from "bcryptjs";

export const login = (req) => {
    // 1. Manual Validation
    const { username, password } = req.body;
    if (!username || !password) {
        return response.json(
            { error: "Identification (username & password) is required for manual login" },
            { status: 400 }
        );
    }

    // 2. Load the manual SQL query
    const sql = fs.readFile("app/db/login.sql");

    // 3. Manual Database lookup
    const conn = db();
    const rows = drift(conn.query(sql, [username]));

    if (!rows || rows.length === 0) {
        return response.json(
            { error: "Manual authentication failed: User not found" },
            { status: 401 }
        );
    }

    const user = rows[0];

    // 4. Manual Password Verification (Bcrypt)
    const isValid = bcrypt.compareSync(password, user.password);
    if (!isValid) {
        return response.json(
            { error: "Manual authentication failed: Invalid password" },
            { status: 401 }
        );
    }

    // 5. Manual Data Scrubbing
    delete user.password;

    // 6. Manual Token Issuance
    const token = t.jwt.sign(
        {
            id: user.id,
            username: user.username,
            email: user.email
        },
        "jii", // Secret key
        { expiresIn: "7d" }
    );

    // 7. Manual Response
    return response.json({
        auth_method: "manual",
        success: true,
        token,
        user
    });
};