express = require("express")
fs = require("fs")
coffee = require("coffee-script")
markov = require("./markov")

app = express()
app.use express.logger()

app.get "/", (request, response) ->

  contents = []

  data = []
  for source in request.query.sources.split(",")
    data = data.concat fs.readFileSync("./lib/dictionaries/#{source}.txt").toString().split(/\r?\n/)

  mk = new markov.Markov(data)

  contents.push(mk.get_sentence()) for i in [0..10]

  response.json contents

port = process.env.PORT || 5001
app.listen port, ->
  console.log "Listening on " + port
