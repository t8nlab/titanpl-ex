// chat simple ws api action

import { log, ws } from "@titanpl/native";

export const chat = (req) => {
    const { event, socketId, body } = req;

  
    if (event === "open") {
      log(`[Server] New socket connected: ${socketId}`);
  
      ws.send(socketId, "Welcome to the Titan Starship!")
      ws.broadcast(`User ${socketId} joined the orbit.`);
    }
  
    if (event === "message") {
      log(`[Server] Message from ${socketId}: ${body}`);
      // Echo it back and broadcast to others
      ws.broadcast(`${socketId}: ${body}`);
    }
  
    if (event === "close") {
      log(`[Server] Socket disconnected: ${socketId}`);
      ws.broadcast(`User ${socketId} left the orbit.`);
    }
  };
  