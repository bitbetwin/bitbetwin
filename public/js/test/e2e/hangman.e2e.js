'use strict';

describe('HangmanCtrl', function() {

  beforeEach(function() {
    browser.ignoreSynchronization = true;
  });

  it('should login', function() {
    browser.get('http://localhost:8080/logout');

    element(by.id('email')).sendKeys('user@gmail.com');
    element(by.id('password')).sendKeys('password');

    element(by.id('login-btn')).click();

    var welcometext = element(by.id('welcome')).getText();
    expect(welcometext).toEqual('You are currently logged in as user@gmail.com');
    var greetingtext = element(by.id('greeting')).getText();
    expect(greetingtext).toEqual('Bangman :) Hey: user@gmail.com');

    var games = element.all(by.repeater('games'));
    expect(games.count()).toEqual(2);
    expect(games.get(0).getText()).toEqual('Join game1');
  });

  it('registering should fail', function() {
    browser.get('http://localhost:8080/logout');

    element(by.id('reg-email')).sendKeys('new-user');
    element(by.id('reg-password')).sendKeys('password');

    element(by.id('register-btn')).click();

    var welcometext = element(by.id('error')).getText();
    expect(welcometext).toEqual('You have entered an invalid email address');
  });

  it('should register and show activation message afterwards', function() {
    browser.get('http://localhost:8080/logout');

    element(by.id('reg-email')).sendKeys('new-user@gmail.com');
    element(by.id('reg-password')).sendKeys('password');

    element(by.id('register-btn')).click();

    var welcometext = element(by.id('info')).getText();
    expect(welcometext).toEqual('Please check your emails in order to activate your account new-user@gmail.com');
  });


  it('login with invalid username', function() {
    browser.get('http://localhost:8080/logout');

    element(by.id('email')).sendKeys('invalid@gmail.com');
    element(by.id('password')).sendKeys('password');

    element(by.id('login-btn')).click();

    var welcometext = element(by.id('error')).getText();
    expect(welcometext).toEqual('Incorrect username or password.');
  });
  
  it('should login and make a sample guess', function() {
    browser.get('http://localhost:8080/logout');

    element(by.id('email')).sendKeys('user@gmail.com');
    element(by.id('password')).sendKeys('password');

    element(by.id('login-btn')).click();

    var welcometext = element(by.id('welcome')).getText();
    expect(welcometext).toEqual('You are currently logged in as user@gmail.com');

    var games = element.all(by.repeater('games'));
    expect(games.count()).toEqual(2);
    expect(games.get(0).getText()).toEqual('Join game1');
    element(by.id('game1')).click();

    var matchtext = element(by.id('match')).getText();
    expect(matchtext).toEqual('Guessed Word: _______________ ___ _______ ___ ________ _________');
    element(by.model('letter')).sendKeys('C');
    element(by.id('guess')).click();
    matchtext = element(by.id('match')).getText();
    expect(matchtext).toEqual('Guessed Word: C______________ ___ _______ ___ ________ _________');
  });
});