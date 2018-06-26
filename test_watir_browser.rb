require 'watir'

browser = Watir::Browser.new :firefox
browser.goto "http://google.com"
browser.text_field(name: 'q').set("WebDriver rocks!")
browser.button(name: 'btnG').click
puts browser.url
browser.close