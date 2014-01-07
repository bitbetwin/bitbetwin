'use strict';

describe('HangmanCtrl', function() {

  beforeEach(function() {
    browser.ignoreSynchronization = true;
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
    expect(matchtext).toEqual('Guessed Word: __________');
    element(by.model('letter')).sendKeys('T');
    element(by.id('guess')).click();
    matchtext = element(by.id('match')).getText();
    expect(matchtext).toEqual('Guessed Word: t_________');

    element(by.model('letter')).sendKeys('pHrAsE');
    element(by.id('guess')).click();
    matchtext = element(by.id('match')).getText();
    expect(matchtext).toEqual('Guessed Word: tes_phra__');
  });

  it('should register, activate account and sign in afterwards', function() {
    browser.get('http://localhost:8080/logout');

    element(by.id('reg-email')).sendKeys('new-user@gmail.com');
    element(by.id('reg-password')).sendKeys('passw0rd');

    element(by.id('register-btn')).click();

    var welcometext = element(by.id('info')).getText();
    expect(welcometext).toEqual('Please check your emails in order to activate your account new-user@gmail.com');
    var activationtext = element(by.id('debug')).getText();
    expect(activationtext).toContain("Please activate localhost:8080/activate?token=");

    var activationurl = "---------- empty -----------";

    element(by.id('debug')).getText().then(function(text) {
      activationurl = "http://" + text.split(" ")[2];
      
      browser.get(activationurl);

      var signintext = element(by.id('info')).getText();
      expect(signintext).toEqual('Please sign in new-user@gmail.com');

      element(by.id('email')).sendKeys('new-user@gmail.com');
      element(by.id('password')).sendKeys('passw0rd');

      element(by.id('login-btn')).click();

      welcometext = element(by.id('welcome')).getText();
      expect(welcometext).toEqual('You are currently logged in as new-user@gmail.com');
    });
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
  });

  it('registering should fail', function() {
    browser.get('http://localhost:8080/logout');

    element(by.id('reg-email')).sendKeys('new-user');
    element(by.id('reg-password')).sendKeys('password');

    element(by.id('register-btn')).click();

    var welcometext = element(by.id('error')).getText();
    expect(welcometext).toEqual('You have entered an invalid email address');
  });

  it('login with invalid username', function() {
    browser.get('http://localhost:8080/logout');

    element(by.id('email')).sendKeys('invalid@gmail.com');
    element(by.id('password')).sendKeys('password');

    element(by.id('login-btn')).click();

    var welcometext = element(by.id('error')).getText();
    expect(welcometext).toEqual('Incorrect username or password.');
  });
});