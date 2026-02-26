// app/actions/me.js

import { jwt } from "@titan/native"

export const me = (req) => {

    const { tk } = req.body

    const user = jwt.verify(tk, "jii")

    return user;
}