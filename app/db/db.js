// app/db/db.js (db connection)

export const db = () => {
    return t.db.connect(t.env.DB_URI, {
        max: 10
    })
}