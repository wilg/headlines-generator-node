express = require("express")
fs = require("fs")
coffee = require("coffee-script")
markov = require("./markov")

app = express()
app.use express.logger()

# Settings
max_corpus_size = 20000

getRandomInt = (min, max) ->
  Math.floor(Math.random() * (max - min + 1)) + min

data_for_sources = (sources) ->
  per_dictionary_limit = max_corpus_size / sources.length
  data = []
  for source in sources
    source_data = fs.readFileSync("./lib/dictionaries/#{source}.txt").toString().split(/\r?\n/)

    if source_data.length > per_dictionary_limit
      window_start = getRandomInt(0, source_data.length - per_dictionary_limit)
      source_data = source_data[window_start...window_start+per_dictionary_limit]

    data = data.concat source_data
  data


app.get "/", (request, response) ->
  sources = request.query.sources?.split(",") || []

  contents = []

  if sources.length > 0
    data = data_for_sources(sources)
    for source in sources
      data = data.concat fs.readFileSync("./lib/dictionaries/#{source}.txt").toString().split(/\r?\n/)
    mk = new markov.Markov(data)
    contents.push(mk.get_sentence()) for i in [0..10]

  response.json contents

port = process.env.PORT || 5001
app.listen port, ->
  console.log "Listening on " + port
