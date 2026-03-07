import { log } from "@titanpl/native";
import { auth } from "../auth/config"

export function iauthlg(req) {
  log(`[Login] Attempting login for: ${req.body?.username || 'unknown'}`);
  log(t.env.DB_URI)
  try {
    const res = auth.signIn(req.body);
    log(`[Login] Result: ${JSON.stringify(res)}`);
    return res;
  } catch (err) {
    log(`[Login] CRASH: ${err.message}`);
    return { error: "Internal Server Error", message: err.message };
  }
}