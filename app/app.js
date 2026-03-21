// app/app.js
import t from "@titanpl/route";

// 🛤️ Manual Login Route
t.post("/login").action("login");

// 🛡️ Official IAuth Secure Login Route
t.post("/iauth-login").action("iauthlg");

// User Context Route
t.get("/me").action("me");

t.ws("/chat").action("chat")

// Fallback Route
t.get("/").action("home")


t.start(5100, "Titan Running on port 5100!");

