// app/actions/home.js
// simple chat ui render action with @t8n/ui extension

import { fs, response } from "@titanpl/native"




export const home = (req) => {
    let html = fs.readFile("../app/static/chat.html")
    return response.html(html, { status: 200 })
}
