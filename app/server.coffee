http = require('http')
io = require('socket.io')
express = require('express')

# TODO: package the server into a class

app = express()
server = http.createServer(app)
io = io.listen(server)

server.listen(8080)

app.get('/', (req, res) -> res.sendfile(__dirname + '/views/index.html'))

io.sockets.on('connection', (socket) ->
  socket.emit('news', { hello: 'world' })
  socket.on('my other event', (data) -> console.log(data))
)