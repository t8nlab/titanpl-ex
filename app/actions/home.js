// app/actions/home.js
// simple chat ui render action with @t8n/ui extension

import ui from "@t8n/ui";

export const home = (req) => {
  return ui.render("static/chat.html")
}
