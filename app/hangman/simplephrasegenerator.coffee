class exports.SimplePhraseGenerator

	constructor: () ->
		@words = ['Blatt', 'Kronen Zeitung', 'London', 'Buchstabensuppe', 'Klo', 'Tischfussballtisch', 'Paris']

	generate: () ->
		index = Math.floor((Math.random()*6)+1);
		@words[index]