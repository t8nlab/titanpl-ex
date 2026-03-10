// app/app.js
import t from "@titanpl/route";

// 🛤️ Manual Login Route
t.post("/login").action("login");

// 🛡️ Official IAuth Secure Login Route
t.post("/iauth-login").action("iauthlg");

// User Context Route
t.get("/me").action("me");

// Fallback Route
t.get("/").reply("Titan Auth Example Server");

t.get("/hello").action("hello")

t.start(5100, "Titan Running on port 5100!");

