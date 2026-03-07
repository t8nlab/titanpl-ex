// app/actions/login.js

/* eslint-disable titanpl/drift-only-titan-async */
import "@titanpl/node/globals";
import { fs, response } from "@titanpl/native";
import { db } from "../db/db.js";
import bcrypt from "bcryptjs"


export const login = (req) => {

    const sql = fs.readFile("app/db/login.sql");
    const { username, password } = req.body;

    if (!username || !password) {
        return response.json(
            { error: "Username and password required" },
            { status: 400 }
        );
    }

    const conn = db();

    const rows = drift(
        conn.query(sql, [username])
    );

    if (!rows || rows.length === 0) {
        return response.json(
            { error: "Invalid credentials" },
            { status: 401 }
        );
    }

    const user = rows[0];

    const valid = bcrypt.compareSync(password, user.password);

    if (!valid) {
        return response.json(
            { error: "Invalid credentials" },
            { status: 401 }
        );
    }

    delete user.password;

    const token = t.jwt.sign(
        {
            id: user.id,
            username: user.username,
            email: user.email
        },
        "jii",
        { expiresIn: "7d" }
    );

    return response.json({
        success: true,
        token,
        user
    });
};