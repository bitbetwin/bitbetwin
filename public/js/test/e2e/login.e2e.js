'use strict';

describe('HangmanCtrl', function() {
  
  it('should login', function() {
    browser.get('http://localhost:8080/');

    element(by.id('email')).sendKeys('user');
    element(by.id('password')).sendKeys('password');

    element(by.id('login-btn')).click();

    var welcometext = element(by.id('welcome')).getText();
    expect(welcometext).toEqual('You are currently logged in as user');
  });
});