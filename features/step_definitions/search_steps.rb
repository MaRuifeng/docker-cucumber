Given /^I am on the (.+) Home Page$/ do |site|
	@site = site.downcase
	visit(HomePage) do |page|
		# wait for the search engine home page to load
    page.wait_until(10, "#{@site} home page not reached. Check connection or URL.") do
      page.title.should eq(Common.get_result('expected_home_page_title'))
    end
  end
end

When /^I search for ?"([^"]*)"$/ do |term|
	# on(HomePage).search_for(term)
  # if_page(HomePage) do |page|
   #  page.search_for(term)
  # end
	@current_page.search_for(term)
end

Then /^I should see at least ([\d,]+) results$/ do |exp_num_results|
	on(ResultPage) do |page|
    # wait for the search to finish and the DOM to be completely loaded
		page.wait_until(10, 'Search not completed.') do
      page.results_element.visible?
    end
		begin
			@current_page.number_search_results.should >= exp_num_results.gsub(',', '').to_i
		rescue => error
			$log.error("#{error.class}: #{error.message}\n#{error.backtrace.join("\n")}")
			raise("#{error.class} encountered!")
		 end
	end
end

When /^I search for a? ?([^"].+[^"])$/ do |term_key|
	term = Common.get_search_term term_key
	on(HomePage).search_for(term)
end

Then /^I should see at most ([\d,]+) results$/ do |exp_num_results|
	on(ResultPage) do |page|
		# wait for the search to finish and page completely loaded
		page.wait_until(10, 'Search not completed') do
			page.results_element.visible?
		end
		begin
			page.number_search_results.should <= exp_num_results.gsub(',' , '').to_i
    rescue => error
      $log.error("#{error.class}: #{error.message}\n#{error.backtrace.join('\n')}")
      raise("#{error.class} encountered!")
    end
	end
end
