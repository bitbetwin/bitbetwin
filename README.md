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

coding style: 
* please make use of the following settings 
    * tabs size = 2
    * tabs are spaces
    * for sublime text: 
        * http://www.sublimetext.com/docs/2/indentation.html


testing:

* Unit Testing
   * run tests
      * karma start public/js/test/karma.config.js

* e2e Testing - Protractor
   * assure you have installed a jdk.
      * selenium runs on java.
   * installation
      * npm install -g protractor
      * webdriver-manager update
   * run tests
      * assure you started the server: coffee server.coffee
      * protractor public/js/test/protractor.conf.js
