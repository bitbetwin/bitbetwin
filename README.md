hangman
=======

Linux: 

* install mongodb for development mode
    * http://docs.mongodb.org/manual/administration/install-on-linux/
* make sure it is running
    * sudo service mongodb start
* connect to mongo db and create database
    * type: use bangmandb
    * type: db.users.save( {username:"bangmanuser"} )
    * type: show dbs to verify if bangmandb was created
