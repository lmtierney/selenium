require "selenium-webdriver"

$DEBUG = true
caps = Selenium::WebDriver::Remote::W3CCapabilities.firefox
caps[:firefox_options] = {binary: '/Applications/FirefoxNightly.app/Contents/MacOS/firefox-bin'}
driver = Selenium::WebDriver.for :firefox, desired_capabilities: caps
# driver.get('http://the-internet.herokuapp.com/key_presses')
driver.get('http://the-internet.herokuapp.com/login')
driver.find_element(id: 'username').click

action = driver.action(true).key_down(:shift).send_keys('hello there!').click_and_hold.release
action.perform
puts 'hi'
driver.quit
