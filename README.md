hangman
=======

Linux: 

* install mongodb for development mode
    * http://docs.mongodb.org/manual/administration/install-on-linux/
* make sure it is running
    * sudo service mongodb start
* connect to mongo db and create database, afterwards also a test user should exist ;)
    * type: use bangmandb
    * type: db.users.save( { email:"user", password: "password" } )
    * type: db.users.find( {} ) to find inserted user
    * type: show dbs to verify if bangmandb was created
