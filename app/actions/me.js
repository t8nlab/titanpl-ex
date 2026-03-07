import { log } from "@titanpl/native";
import { auth } from "../auth/config"

export function me(req) {
  const user = auth.guard(req);

  return user
}