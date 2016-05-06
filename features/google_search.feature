Feature: Google Search
	As a good programmer
	I want to be able to use Google as a useful tool to get new knowledge and fix issues
	So that I can be well paid

    @direct_search 
	Scenario Outline: Search for NoClassDefException
		Given I am on the <search engine> Home Page
		When I search for "NoClassDefException"
		Then I should see at least <expected number of> results

		Scenarios: 
			| search engine | expected number of |  
			| Google        | 1000               |  

    @search_with_data @most_results
	Scenario: Search using data specified externally
		Given I am on the "Google" Home Page
		When I search for a rididulously small number of results
		Then I should see at most 2 results


