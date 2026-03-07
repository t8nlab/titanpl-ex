// app/actions/iauthlg.js
/**
 * OFFICIAL SECURE AUTH LOGIC (IAuth Extension)
 * This is the recommended way to handle authentication in TitanPl.
 * It uses the @t8n/iauth extension to securely handle database lookups,
 * password verification, and session management in one secure step.
 */

import { auth } from "../auth/config.js";

export function iauthlg(req) {
  // Official one-liner for secure authentication
  // This automatically handles validation, security, and token issuance
  // based on the configuration in app/auth/config.js
  const authResponse = auth.signIn(req.body);

  return authResponse;
}
