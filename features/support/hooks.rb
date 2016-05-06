
## DIRECTORIES
screenshot_directory = "#{Dir.home}/#{FigNewton.screenshot_directory}"
log_directory = "#{Dir.home}/#{FigNewton.log_directory}"
screenshot_directory.gsub!("/", "\\") if Selenium::WebDriver::Platform.windows?
log_directory.gsub!("/", "\\") if Selenium::WebDriver::Platform.windows?
Dir.mkdir screenshot_directory unless Dir.exist? screenshot_directory
Dir.mkdir log_directory unless Dir.exist? log_directory

## BROWSER
Watir.default_timeout = 30
client = Selenium::WebDriver::Remote::Http::Default.new
client.timeout = 180 # seconds – default is 60

firefox_profile = Selenium::WebDriver::Firefox::Profile.new
firefox_profile['browser.download.folderList'] = 2 # custom location
firefox_profile['browser.download.dir'] = screenshot_directory
firefox_profile['browser.download.panel.shown'] = false
firefox_profile['browser.download.animateNotifications'] = false
firefox_profile['browser.helperApps.neverAsk.saveToDisk'] = "attachment/csv, text/csv, text/plain, application/csv"
firefox_profile['browser.download.manager.showWhenStarting'] = false
firefox_profile['browser.download.manager.showAlertOnComplete'] = false
firefox_profile['browser.download.manager.closeWhenDone'] = true

case FigNewton.browser.downcase.to_sym
when :chrome
  browser = Watir::Browser.new :chrome, :http_client => client, :switches => %w[--test-type --ignore-certificate-errors --disable-popup-blocking --disable-translate]
  # --test-type switch is to exclude the 'Unsupported command-line flag:--ignore-certificate-errors' pop-up message
when :firefox
  browser = Watir::Browser.new :firefox, :profile => firefox_profile
else 
  puts "No valid browser type specified!"
end
browser.window.maximize

## HOOKS
Before do |scenario|
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
    $feature_name= scenario.feature.name
    $scenario_info = scenario.name
  when scenario.instance_of?(Cucumber::RunningTestCase::ScenarioOutlineExample)
    $feature_name= scenario.scenario_outline.feature.name
    $scenario_info = scenario.scenario_outline.name

    if $scenario_outline_name != scenario.scenario_outline.name.gsub(/,.*Examples.*\(#\d+\)/, "")
      # new scenario outline encountered
      $ran_once_in_outline = false
      $scenario_outline_name = scenario.scenario_outline.name.gsub(/,.*Examples.*\(#\d+\)/, "")
    end
  else 
    $feature_name= "Unknow-feature"
    $scenario_info = "Unknow-scenario"
  end
  
  # browser
  @browser = browser
  
  # log
  $log = Logger.new("#{Dir.home}/#{FigNewton.log_directory}/#{$feature_name.gsub(/\s+/, "-")}-cuke_trace.log", 10, 1024000)
  $log.level = Logger::DEBUG
  $log.formatter = proc do |severity, datetime, progname, msg|
    "[#{datetime}]#{progname} #{severity} > #{msg}\n"
  end
  
  $stdout_log = Logger.new("#{Dir.home}/#{FigNewton.log_directory}/#{$feature_name.gsub(/\s+/, "-")}-stdout.log", 10, 1024000)
  $stdout_log.level = Logger::INFO
  $stdout_log.formatter = proc do |severity, datetime, progname, msg|
    "[#{datetime}]#{msg}\n"
  end
  
  def $stdout.write string
    # Monkey-patch STDOUT to make it output to the log file as well
    string.strip.empty? ? () : $stdout_log.info(string)
    super
  end

  $log.info("=====FEATURE START=====") unless $ran_once_in_feature
  $log.info("Assigned testing portal URL: #{FigNewton.base_url}") unless $ran_once_in_feature
  $log.info("Feature to be run: #{$feature_name}") unless $ran_once_in_feature
  $log.info("######################SCENARIO Start######################")      
  unless $scenario_outline_name.nil?
    $log.info("Scenario outline: #{$scenario_outline_name}")
  end
  $log.info("Scenario started: #{$scenario_info}")
  $stdout_log.info("Scenario started: #{$scenario_info}")
end

After do |scenario|
  #capture screenshot on failure and include in report
  if scenario.failed?
    filename = "#{Dir.home}/#{FigNewton.screenshot_directory}/error_#{scenario.feature.name.gsub(/\s+/, "")}_#{scenario.name.gsub(/\s+/, "")}_#{@current_page.class}_#{Time.new.strftime("%Y-%m-%d_%H%M%S")}.png"
    @current_page.save_screenshot(filename)
    embed(filename, 'image/png')
    $log.info("Scenario failed: #{$scenario_info}. Screenshot saved to #{filename}")
   else $log.info("Scenario passed: #{$scenario_info}")
  end
  $log.info("######################SCENARIO END######################")
  $stdout_log.info("Scenario ended: #{$scenario_info}")
  @cobalt=nil
end

at_exit do
  $log.info("Feature completed: #{$feature_name}")
  $log.info("=====FEATURE END=====")
  $stdout_log.info("=====FEATURE END=====")
  # reset ran_once flag
  $ran_once_in_feature=nil
  $ran_once_in_outline=nil
  # Close log
  $log.close
  $stdout_log.close
  # Close the browser
  browser.close
end
