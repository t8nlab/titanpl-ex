// app/actions/me.js


export const me = (req) => {

    const { tk } = req.body

    const user = t.jwt.verify(tk, "jii")

    return user;
}