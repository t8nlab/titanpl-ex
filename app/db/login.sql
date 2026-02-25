-- app/db/login.sql (login query)

SELECT id, username, email, password
FROM users
WHERE username = $1
LIMIT 1;