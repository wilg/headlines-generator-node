express = require("express")
fs = require("fs")

require('coffee-trace')

coffee = require("coffee-script")
markov = require("./markov")

app = express()
app.use express.logger()

app.get "/", (request, response) ->

  contents = []

  console.log "PARSING PARSING"

  data = fs.readFileSync("./dictionaries/hackernews.txt").toString().split(/\r?\n/);

  mk = new markov.Markov(data)

  console.log "DONE"

  contents.push(mk.get_sentence()) for i in [0..10]

  response.json contents

port = 5001 #process.env.PORT ||
app.listen port, ->
  console.log "Listening on " + port
