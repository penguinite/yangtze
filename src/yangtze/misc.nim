import conf
import std/[tables, mimetypes]
import iniplus, waterpark

proc fetchAsset*(fn: string): string =
  return readFile("pages/" & fn & ".tmpl")

# Yup... there is more cryptic code! My favorite!
type TmplPool* = Pool[Table[string,string]]
proc borrow*(pool: TmplPool): Table[string,string] {.inline, gcsafe.} = waterpark.borrow(pool)
proc recycle*(pool: TmplPool, conn: Table[string,string]) {.inline, gcsafe.} = waterpark.recycle(pool, conn)

proc newTmplPool*(size: int = 50): TmplPool =
  result = newPool[Table[string,string]]()
  let tmp = configToTable(parseFile(getConfigFilename()))
  for _ in 0 ..< size: result.recycle(tmp)

template withConnection*(pool: TmplPool, config, body) =
  block:
    let config = pool.borrow()
    try:
      body
    finally:
      pool.recycle(config)

let tmplPool* = newTmplPool()
const mimedb* = newMimetypes()