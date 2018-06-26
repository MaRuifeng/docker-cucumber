class ResultPage
	include PageObject, Common

	# find the search results statistics
	div :results, :id => 'resultStats'

	def number_search_results
		result = /[\s\D]*([\d,]+) results \(\d+\.\d+ seconds\)/.match(results)
		raise "Could not determine number of search results from : '#{results}'" if not result
		result.captures[0].gsub(',', '').to_i
	end
end