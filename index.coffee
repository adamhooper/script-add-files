args = require('minimist')(process.argv.slice(2))

Uploader = require('./lib/Uploader')

Options = [
  [ 'apiToken', 'api-token' ]
  [ 'documentSetId', 'document-set-id' ]
  [ 'server', 'server' ]
]

options = {}
for [ k1, k2 ] in Options
  throw new Error("You must call this script with a --#{k2}=abcd argument") if !args[k2]
  options[k1] = args[k2]
if args._.length == 0
  throw new Error("You must call this script with some filenames as arguments")

uploader = new Uploader(options)
uploader.upload(args._)
  .catch (err) -> console.warn(err)
