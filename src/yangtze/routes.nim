import misc
import std/[mimetypes, os]
import temple, mummy

proc pageHandler*(req: Request) =
  ## This route handles templated files (Files in the pages/ folder)
  echo req.path
  var headers: HttpHeaders
  headers["Content-Type"] = "text/html"
  var fn = req.path # Remove initial slash

  # If this is just a slash then something is horribly wrong.
  if fn == "/":
    req.respond(200, headers, "Error: Initial Slash")

  # Remove last slash (If it exists)
  if fn[high(fn)] == '/':
    fn = fn[0..^2]

  tmplPool.withConnection tmpl:
    req.respond(200, headers,
      templateify(fetchAsset(fn), tmpl)
    )

proc staticHandler*(req: Request) =
  ## This route handles plain old static files (Files in the static/ folder)
  echo req.path
  var headers: HttpHeaders
  let (dir, file, ext) = splitFile(req.path)
  discard dir # Fucking nim.
  discard file # Fucking nim^2
  headers["Content-Type"] = mimedb.getMimetype(ext)
  req.respond(200, headers, readFile("static/" & req.path[1..^1]))

proc homeHandler*(request: Request) =
  # Render "home.tmpl"
  var headers: HttpHeaders
  headers["Content-Type"] = "text/html"
  
  tmplPool.withConnection tmpl:
    request.respond(200, headers,
      templateify(fetchAsset("home"), tmpl)
    )