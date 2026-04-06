import IAuth from "@t8n/iauth"
import { db } from "../db/db.js";

const dbConnection = db()
export const auth = new IAuth({
    secret: "jii",
    
    db: {
        conn: dbConnection,
        table: "users",
        identityField: "username",
        passwordField: "password",
        scope: ["id", "username", "email", "avatar_url"] 
    }
})