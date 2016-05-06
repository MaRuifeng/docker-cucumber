require 'watir-webdriver'
require 'require_all'
require 'page-object'
require 'page-object/page_factory'
require 'rspec'
require 'data_magic'
require 'fig_newton'
require 'logger'

World(PageObject::PageFactory)

TEST_DATA_DIR = "./features/support/test_data"
DataMagic.yml_directory = './features/support/test_data'  # Tells data-magic where to look for test data


if ENV['HEADLESS'] == 'true'  # Check if the test is run in a headless environment
	require 'headless'
	headless = Headless.new
	headless.start

	at_exit do
		headless.destroy
	end
end