'use strict';

describe('HangmanCtrl', function() {
  
  it('should register and be logged in afterwards', function() {
    browser.get('http://localhost:8080/logout');

    element(by.id('reg-email')).sendKeys('new-user');
    element(by.id('reg-password')).sendKeys('password');

    element(by.id('register-btn')).click();

    var welcometext = element(by.id('welcome')).getText();
    expect(welcometext).toEqual('You are currently logged in as new-user');
  });
});