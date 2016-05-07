
Feature: Google Search 2
	As a good programmer
	I want to be able to use Google as a useful tool to get new knowledge and fix issues
	So that I can be well paid 

    @search_with_data @most_results
	Scenario: Search using data specified externally
		Given I am on the "Google" Home Page
		When I search for a rididulously small number of results
		Then I should see at most 2 results


