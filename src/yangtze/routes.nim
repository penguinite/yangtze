import mummy, conf

let configPool = newConfigPool()

proc indexHandler*(request: Request) =
  var headers: HttpHeaders
  headers["Content-Type"] = "text/plain"
  request.respond(200, headers, "Hello, World!")

proc portHandler*(req: Request) =
  var headers: HttpHeaders
  headers["Content-Type"] = "text/plain"
  configPool.withConnection config:
    req.respond(200, headers, "Port: " & $(config.getIntOrDefault("web","port",8080)))