// app/app.js

import t from "@titan/route";

t.post("/lg").action("login") // pass a json payload { "username": "titan", "password": "planet" }

t.post("/me").action("me") // {"tk": "pass the token here"}

t.get("/").reply("Read the README.md file to know everything")

t.start(5100, "Titan Running!");
