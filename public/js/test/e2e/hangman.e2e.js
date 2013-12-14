'use strict';

describe('HangmanCtrl', function() {
  
  it('should login and make a sample guess', function() {
    browser.get('http://localhost:8080/logout');

    element(by.id('email')).sendKeys('user');
    element(by.id('password')).sendKeys('password');

    element(by.id('login-btn')).click();

    var welcometext = element(by.id('welcome')).getText();
    expect(welcometext).toEqual('You are currently logged in as user');

    var matchtext = element(by.id('match')).getText();
    expect(matchtext).toEqual('Guessed Word: _______________ ___ _______ ___ ________ _________');
    element(by.model('letter')).sendKeys('Con');
    element(by.id('guess')).click();
    matchtext = element(by.id('match')).getText();
    expect(matchtext).toEqual('Guessed Word: Con____________ ___ _______ ___ ________ _________');
  });
});