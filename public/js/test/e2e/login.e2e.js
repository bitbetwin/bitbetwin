'use strict';

describe('HangmanCtrl', function() {
  
  it('should login', function() {
    browser.get('http://localhost:8080/logout');

    element(by.id('email')).sendKeys('user');
    element(by.id('password')).sendKeys('password');

    element(by.id('login-btn')).click();

    var welcometext = element(by.id('welcome')).getText();
    expect(welcometext).toEqual('You are currently logged in as user');
    var greetingtext = element(by.id('greeting')).getText();
    expect(greetingtext).toEqual('Bangman :) Hey: user');

  });
});