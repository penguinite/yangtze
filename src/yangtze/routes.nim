import mummy, conf, std/[tables, strutils]

let configPool = newConfigPool()

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
      result[key[1]] = configValueToString(val)

proc fetchAsset(fn: string): string =
  return #TODO: Implement


proc indexHandler*(request: Request) =
  # Check if the config has specified the 
  # post display page to be first.
  configPool.withConnection config:
    if config.getStringOrDefault("web","posts_slug","post") == "":
      discard # TODO: Implement post displays
    else:
      # Render "home.tmpl"
      # TODO: Implement
      discard

  var headers: HttpHeaders
  headers["Content-Type"] = "text/plain"
  request.respond(200, headers, "Hello, World!")

proc portHandler*(req: Request) =
  var headers: HttpHeaders
  headers["Content-Type"] = "text/plain"
  configPool.withConnection config:
    req.respond(200, headers, "Port: " & $(config.getIntOrDefault("web","port",8080)))