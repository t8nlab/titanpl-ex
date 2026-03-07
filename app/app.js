// app/app.js

import t from "@titanpl/route";

t.post("/lg").action("iauthlg")

t.get("/me").action("me")

t.get("/").reply("Titan example server")

t.start(5100, "Titan Running!");
