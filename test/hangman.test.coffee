should = require "should"

describe "Hangman", ->

  before (done) ->
    process.env.NODE_ENV = "testing"
    Hangman = require('../app/hangman/hangman').Hangman
    @hangman = new Hangman 'Guess word test'
    done()

  it 'tests a guess with multiple matches', (done) ->
    @hangman.check 'guess', (guessedword) ->
      guessedword.should.be.equal 'guess ____ ____'
      done()

  it 'tests a guess without match', (done) ->
    @hangman.check 'axyz1389?', (guessedword) ->
      guessedword.should.be.equal '_____ ____ ____'
      done()

  it 'tests a guess with matches in divers order', (done) ->
    @hangman.check 'seuotss', (guessedword) ->
      guessedword.should.be.equal '_uess _o__ t_s_'
      done()

  it 'tests a guess with complete match in divers order', (done) ->
    @hangman.check 'seuotssgrdwte', (guessedword) ->
      guessedword.should.be.equal 'guess word test'
      done()

  it 'test case insensitive words', (done) ->
    @hangman.check 'GuEss', (guessedword) ->
      guessedword.should.be.equal 'guess ____ ____'
      done()