# Package

version       = "0.1.0"
author        = "penguinite"
description   = "A CMS built on top of a MastoAPI-compatible server"
license       = "AGPL-3.0-or-later"
srcDir        = "src"
bin           = @["yangtze"]


# Dependencies

requires "nim >= 2.0.8"
requires "mummy"
requires "iniplus"
requires "waterpark"