import yangtze/[conf, routes]
import std/[os, strutils]
import mummy, mummy/routers

var
  router: Router
  port: int

# Loop over every file in the pages dir
# and register it with Mummy
# Except for home.tmpl, posts.tmpl, post.tmpl which are special
for f in walkDir("./pages/", checkDir = true):
  var fn = f.path.split("/")[1] # Split the pages/ part
  fn = fn.split(".")[0] # Split the .tmpl part

  # Skip home, posts and post.
  case fn:
  of "home", "posts", "post": continue
  else: discard

  router.get("/" & fn, pageHandler)
  router.get("/" & fn & "/", pageHandler)

configPool.withConnection config:
  port = config.getIntOrDefault("web","port",8080)
  
echo "Serving on localhst:", port
newServer(router).serve(Port(port))