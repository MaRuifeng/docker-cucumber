require 'rubygems'

begin
  require 'cucumber'
  require 'cucumber/rake/task'

  namespace :google_search do 
    Cucumber::Rake::Task.new(:features) do |t|
      t.profile = 'default'
      t.cucumber_opts = "--tag @direct_search "
    end
    desc "All google_search scripts."
    task :all => [:features]
  end
  
  namespace :parallel_cukes do 
    task :features do
      # cucumber_options = "-p dev_parallel -t @parallel_test -t @modify"
      # commands = ["bundle exec parallel_cucumber features/parallel_test/ -o '#{cucumber_options}'"]
      puts "Current directory: #{Dir.pwd}"
      commands = ["pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY #{Dir.pwd}/parallel_cukes.sh -d #{Dir.pwd}"]
      # commands = ["pkexec env DISPLAY=:0 XAUTHORITY=/home/ruifeng/.Xauthority #{Dir.pwd}/parallel_cukes.sh -d #{Dir.pwd}"]
      commands.each do |command|
        puts "Running command: #{command}"
        abort "Failed command: #{command}" unless system(command)
      end
    end
  end
  rescue LoadError
  desc "Cucumber rake task not available"
  task :features do
    abort "Cucumber rake task is not available. Be sure to install cucumber as a gem or plugin."
  end
end
