Given /^I am on the (.+) Home Page$/ do |site|
	@site = site.downcase
	visit_page HomePage
	# wait for the google home page to load
	@current_page.wait_until(10, "Google home page not reached. Check connection or URL.") do
		@current_page.title == Common.get_result('expected_page_title')
	end
end

When /^I search for ?"([^"]*)"$/ do |term|
	@current_page.search_for term
	# wait for the search to finish and the DOM to be completely loaded
	# sleep(3)
end

Then /^I should see at least ([\d,]+) results$/ do |exp_num_results|
	on_page ResultPage do 
	    # wait for the search to finish and the DOM to be completely loaded
	    @current_page.wait_until(10, "Search not completed.") do
	    	@current_page.results_element.visible?
	    end
	    begin
	    	@current_page.number_search_results.should >= exp_num_results.gsub(",","").to_i
			rescue => error
				$log.error("#{error.class}: #{error.message}\n#{error.backtrace.join("\n")}")
				raise("#{error.class} encountered!")
	     end
	end
end

When /^I search for a? ?([^"].+[^"])$/ do |term|
	term = Common.get_search_term term
	@current_page.search_for term
end

Then /^I should see at most ([\d,]+) results$/ do |exp_num_results|
	on_page ResultPage do
		# wait for the search to finish and page completely loaded
		@current_page.wait_until(10, "Search not completed.") do
			@current_page.results_element.visible?
		end
		begin
	    	@current_page.number_search_results.should <= exp_num_results.gsub(",","").to_i
			rescue => error
				$log.error("#{error.class}: #{error.message}\n#{error.backtrace.join("\n")}")
				raise("#{error.class} encountered!")
	    end
	end
end
