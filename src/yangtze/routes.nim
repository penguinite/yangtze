import mummy, conf, std/[tables,strutils], temple, waterpark

let configPool* = newConfigPool()

proc configValueToString(val: ConfigValue): string =
  case val.kind:
  of CVString: return val.stringVal
  of CVInt: return $(val.intVal)
  of CVBool: return $(val.boolVal)
  of CVArray:
    for item in val.arrayVal:
      result.add(configValueToString(item))
    return result
  of CVNone, CVTable: return ""

proc configToTable(cnf: ConfigTable): Table[string, string] =
  for key,val in cnf.pairs:
    if key[0] == "custom" and val.kind != CVTable:
      # Check if this is a special "File string" or whatever
      if startsWith(val.stringVal, "$") and endsWith(val.stringVal, "$"):
        result[key[1]] = readFile(val.stringVal[1..^2])
      else:
        # Otherwise, just convert it into a string and add it into the table
        result[key[1]] = configValueToString(val)

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


proc fetchAsset(fn: string): string =
  return readFile("pages/" & fn & ".tmpl")

proc pageHandler*(req: Request) =
  var fn = req.path[0..^1] # Remove initial slash

  # Remove last slash, if it exists and this isn't the landing page.
  if fn[high(fn)] == '/' and fn != "/": fn = fn[0..^2]

  var headers: HttpHeaders
  headers["Content-Type"] = "text/html"

  tmplPool.withConnection tmpl:
    req.respond(200, headers,
      templateify(fetchAsset(fn), tmpl)
    )

proc homHandler*(request: Request) =
  # Render "home.tmpl"
  var headers: HttpHeaders
  headers["Content-Type"] = "text/html"
  
  tmplPool.withConnection tmpl:
    request.respond(200, headers,
      templateify(fetchAsset("home"), tmpl)
    )