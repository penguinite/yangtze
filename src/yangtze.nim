import mummy, mummy/routers
import yangtze/[conf, routes]

var router: Router
router.get("/", indexHandler)
router.get("/port", portHandler)

var port = parseFile(getConfigFilename()).getIntOrDefault("web","port",8080)
echo "Serving on localhst:", port
newServer(router).serve(Port(port))