import { auth } from "../auth/config"

export function iauthlg(req) {
  
  const res = auth.signIn(req.body);

  return res
}