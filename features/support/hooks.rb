# coding: utf-8
require 'watir-webdriver'

## DIRECTORIES
results_directory = "#{FigNewton.results_directory}"
screenshot_directory = "#{FigNewton.screenshot_directory}"
log_directory = "#{FigNewton.log_directory}"

results_directory.gsub!('/', "\\") if Selenium::WebDriver::Platform.windows?
screenshot_directory.gsub!('/', "\\") if Selenium::WebDriver::Platform.windows?
log_directory.gsub!('/', "\\") if Selenium::WebDriver::Platform.windows?

Dir.mkdir results_directory unless Dir.exist? results_directory
Dir.mkdir log_directory unless Dir.exist? log_directory
Dir.mkdir screenshot_directory unless Dir.exist? screenshot_directory

## BROWSER
Watir.default_timeout = 30
client = Selenium::WebDriver::Remote::Http::Default.new
client.timeout = 180 # seconds – default is 60

firefox_profile = Selenium::WebDriver::Firefox::Profile.new

## HOOKS
Before do |scenario|
  case FigNewton.browser.downcase.to_sym
    when :chrome
      browser = Watir::Browser.new :chrome, :http_client => client, :switches => %w[--test-type --ignore-certificate-errors --disable-popup-blocking --disable-translate]
    # --test-type switch is to exclude the 'Unsupported command-line flag:--ignore-certificate-errors' pop-up message
    when :firefox
      browser = Watir::Browser.new :firefox, :profile => firefox_profile
    else
      puts 'No valid browser type specified!'
  end
  browser.window.maximize
  @browser = browser

  # flags
  if !$ran_once_in_feature # flag to check whether ran once in a feature
    $ran_once_in_feature = false
  end
  if !$ran_once_in_outline # flag to check whether ran once in a scenario outline
    $ran_once_in_outline = false
  end

  # scenario, scenario outline, feature
  case    # cannot use when Class directly as ScenarioOutlineExample inherits Scenario
    when scenario.instance_of?(Cucumber::RunningTestCase::Scenario)
      if $feature_name.nil? || $feature_name != scenario.feature.name
        # new feature encountered
        $log.nil? ? () : ($log.info("Feature completed: #{$feature_name}"); $log.info('=====FEATURE END====='); $log.close)
        $stdout_log.nil? ? () : ($stdout_log.info('=====FEATURE END====='); $stdout_log.close)
        $ran_once_in_feature = false
        $feature_name = scenario.feature.name
      end
      $scenario_info = scenario.name
      $scenario_outline_name = nil
    when scenario.instance_of?(Cucumber::RunningTestCase::ScenarioOutlineExample)
      if  $feature_name.nil? || $feature_name != scenario.scenario_outline.feature.name
        # new feature encountered
        $log.nil? ? () : ($log.info("Feature completed: #{$feature_name}"); $log.info('=====FEATURE END====='); $log.close)
        $stdout_log.nil? ? () : ($stdout_log.info('=====FEATURE END====='); $stdout_log.close)
        $ran_once_in_feature = false
        $feature_name = scenario.scenario_outline.feature.name
      end
      $scenario_info = scenario.scenario_outline.name

      if $scenario_outline_name.nil? || $scenario_outline_name != scenario.scenario_outline.name.gsub(/,.*Examples.*\(#\d+\)/, '')
        # new scenario outline encountered
        $ran_once_in_outline = false
        $scenario_outline_name = scenario.scenario_outline.name.gsub(/,.*Examples.*\(#\d+\)/, '')
      end
    # Cucumber version 1.3.18
    #  when Cucumber::Ast::Scenario
    #    $feature_name= scenario.scenario_outline.feature.title
    #    $scenario_info = scenario.name
    #  when Cucumber::Ast::OutlineTable::ExampleRow
    #    $feature_name= scenario.scenario_outline.feature.title
    #    $scenario_info = scenario.scenario_outline.name + " > " + scenario.name
    else
      $feature_name= 'Unknown-feature'
      $scenario_info = 'Unknown-scenario'
  end

  # log
  $log = Logger.new("#{log_directory}/#{$feature_name.gsub(/\s+/, '-')}-cuke_trace.log", 10, 1024000)
  $log.level = Logger::DEBUG
  $log.formatter = proc do |severity, datetime, progname, msg|
    "[#{datetime}][#{$feature_name}][#{$scenario_info}]#{progname} #{severity} > #{msg}\n"
  end

  $stdout_log = Logger.new("#{log_directory}/#{$feature_name.gsub(/\s+/, '-')}-stdout.log", 10, 1024000)
  $stdout_log.level = Logger::INFO
  $stdout_log.formatter = proc do |severity, datetime, progname, msg|
    "[#{datetime}]#{msg}\n"
  end

  def $stdout.write string
    # Monkey-patch STDOUT to make it output to the log file as well
    (string.nil? || string.empty?) ? () : $stdout_log.info(string)
    super
  end

  $log.info('=====FEATURE START=====') unless $ran_once_in_feature
  $log.info("Assigned testing portal URL: #{FigNewton.base_url}") unless $ran_once_in_feature
  $log.info("Feature to be run: #{$feature_name}") unless $ran_once_in_feature
  $ran_once_in_feature = true
  $log.info('######################SCENARIO Start######################')
  unless $scenario_outline_name.nil?
    $log.info("Scenario outline: #{$scenario_outline_name}")
  end
  $log.info("Scenario started: #{$scenario_info}")
  $stdout_log.info("Scenario started: #{$scenario_info}")
end

After do |scenario|
  # Capture screenshot on failure and include in report
  if scenario.failed?
    filename = "#{screenshot_directory}/error_#{scenario.feature.name.gsub(/\s+/, '').gsub(/\//, '')}_#{scenario.name.gsub(/\s+/, '').gsub(/\//, '')}_#{@current_page.class}_#{Time.new.strftime('%Y-%m-%d_%H%M%S')}.png"
    @current_page.save_screenshot(filename) if @current_page
    embed(filename, 'image/png')
    # browser.refresh # avoid the notorious 'target URL not well-formed' error of selenium
    $log.info("Scenario failed: #{$scenario_info}. Screenshot saved to #{filename}")
  else
    $log.info("Scenario passed: #{$scenario_info}")
  end
  $log.info('######################SCENARIO END######################')
  $stdout_log.info("Scenario ended: #{$scenario_info}")
  # Clear cookies and session storage
  # $log.info(@browser.cookies.to_a)
  # @browser.cookies.to_a.each do |cookie|
  #   # $log.info(cookie)
  # end
  begin
    @browser.cookies.clear
    @browser.execute_script('window.sessionStorage.clear()') # execute JavaScript
    @browser.execute_script('window.localStorage.clear()') # execute JavaScript
  rescue => error
    $log.error("#{error.class}: #{error.message}\n#{error.backtrace.join("\n")}")
  ensure
    # Close the browser
    @browser.close if @browser
  end
end

at_exit do
  # last feature log
  $log.info("Feature completed: #{$feature_name}")
  $log.info('=====FEATURE END=====')
  $stdout_log.info('=====FEATURE END=====')
  # Close log
  $log.close
  $stdout_log.close
end
