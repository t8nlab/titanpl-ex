// app/actions/me.js

import { jwt } from "@titanpl/native"

export const me = (req) => {

    const { tk } = req.body

    const user = jwt.verify(tk, "jii")

    return user;
}