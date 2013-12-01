class Markov

  constructor: (source_sentences) ->
    @build_map source_sentences

  build_map: (@source_sentences, @lookback = 2) ->

    markov_map = {}

    # Generate map in the form word1 -> word2 -> occurences of word2 after word1
    for title in @source_sentences
      title = title.split(" ")
      if title.length > @lookback
        for i in [0...(title.length + 1)]
          a = title[Math.max(0, i - lookback)...i].join(' ')
          b = title[i...i+1].join(' ')
          markov_map[a]    = {} unless markov_map[a]?
          markov_map[a][b] = 0 unless markov_map[a][b]?
          markov_map[a][b] = markov_map[a][b] + 1

    # Convert map to the word1 -> word2 -> probability of word2 after word1
    for word, following of markov_map

      # Get values
      following_values = []
      following_values.push(v) for k, v of following

      total = following_values.reduce (x, y) -> x + y

      for key, value of following
        following[key] /= total

    # Save this baby
    @markov_map = markov_map

  # Typical sampling from a categorical distribution
  markov_sample: (items) ->
    items = {} unless items?
    next_word = null
    t = 0.0
    for k, v of items
      t += v
      next_word = k if t > 0 and Math.random() < v / t
    next_word

  get_sentence: (length_max = 140) ->

    mapkeys = []
    mapkeys.push(k) for k, v of @markov_map

    while true
      sentence_parts = []
      next_word = mapkeys[Math.floor(Math.random() * mapkeys.length)]

      while next_word != '' and !!next_word and sentence_parts.join(' ').length < length_max
        sentence_parts.push next_word
        next_word = @markov_sample(@markov_map[sentence_parts[-@lookback..].join(' ')])

      sentence_str = sentence_parts.join(' ')

      # Prune titles that are substrings of actual titles
      continue if @source_sentences.some (title) ->  title.indexOf(sentence_str) isnt -1

      continue if sentence_str.length > length_max

      return sentence_str

module.exports.Markov = Markov