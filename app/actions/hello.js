import { log } from "@titanpl/native"

function hello() {
    log("\x1b[31mRED TEXT\x1b[0m")
    log("\x1b[32mGREEN TEXT\x1b[0m")
    log("\x1b[33mYELLOW TEXT\x1b[0m")
    log("\x1b[34mBLUE TEXT\x1b[0m")
    log("\x1b[35mMAGENTA TEXT\x1b[0m")
    log("\x1b[36mCYAN TEXT\x1b[0m")
}

export default hello