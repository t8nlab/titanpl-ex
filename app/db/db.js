// app/db/db.js (db connection)

export const db = () => {
    // eslint-disable-next-line no-undef
    return t.db.connect(process.env.DB_URI, {
        max: 10
    })
}