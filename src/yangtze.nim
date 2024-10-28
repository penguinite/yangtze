import yangtze/[conf, routes]
import std/[os, strutils]
import mummy, mummy/routers

var router: Router

# Loop over every file in the pages dir
# and register it with Mummy
# Except for home.tmpl, posts.tmpl, post.tmpl which are special
if dirExists("./pages"):
  for f in walkDir("./pages/"):
    var fn = f.path.split("/")[1] # Split the pages/ part
    fn = fn.split(".")[0] # Split the .tmpl part

    echo "Templated file ", f.path, " will be visible at /", fn

    # Skip home, posts and post.
    case fn:
    of "home", "posts", "post": continue
    else: discard

    router.get("/" & fn, pageHandler)
    router.get("/" & fn & "/", pageHandler)

# Loop over every file in the static folder.
# And just add it as a plain route in Mummy
if dirExists("./static"):
  for f in walkDir("./static/"):
    var fn = f.path.split("/")[1] # Split the static/ part

    echo "Static file ", f.path, " will be visible at /", fn
    router.get("/" & fn, staticHandler)

let config = parseFile(getConfigFilename())
let postsSlug = config.getStringOrDefault("web", "posts_slug", "/posts")

router.get(postsSlug, postDisplayHandler)
if postsSlug != "/":
  router.get(postsSlug & "/", postDisplayHandler)
  router.get("/", homeHandler)

echo "Posts will be displayed at " & postsSlug

let port = config.getIntOrDefault("web","port",8080)

echo "Serving on http://localhost:", port
newServer(router).serve(Port(port))