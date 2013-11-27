http = require('http')
io = require('socket.io')
express = require('express')
Hangman = require('./hangman')

# TODO: package the server into a class

app = express()
server = http.createServer(app)
io = io.listen(server)

server.listen(8080)

app.use((req, res, next) ->
  if (/\/public\/hidden\/*/.test(req.path))
    res.send(404, "Not Found")
  next()
)
app.use(express.static(__dirname + "/../public"))
app.use(express.static(__dirname + "/views"))
#app.use(express.directory(__dirname + "/"));
app.get('/', (req, res) -> res.sendfile(__dirname + '/views/index.html'))
app.get('/landingpage', (req, res) -> res.sendfile(__dirname + '/views/landingpage/index.html'))

hangman = new Hangman 'Congratulations you guessed the sentence correctly'

io.sockets.on('connection', (socket) ->
	hangman.check [], (match) -> 
		socket.emit('hangman', { phrase: match })

	socket.on('guess', (data) -> 
  		hangman.check data, (match) -> 
  			socket.emit('hangman', { phrase: match })
	)
)