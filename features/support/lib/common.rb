module Common
	def Common.get_url route
		YAML.load_file("#{TEST_DATA_DIR}/test_data.yml")["urls"][route]
	end 

	def Common.get_search_term term 
		YAML.load_file("#{TEST_DATA_DIR}/test_data.yml")["search_term_data"][term]
	end

	def Common.get_result item
		YAML.load_file("#{TEST_DATA_DIR}/test_data.yml")["results"][item]
	end
end