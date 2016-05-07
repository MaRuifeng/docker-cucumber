

class HomePage
	include PageObject, Common
	page_url FigNewton.base_url

	# find the search field and assign methods
	text_field :search, :name => "q"

	def search_for term
		self.search = term
		$log.info "search term: " + term
		self.search_element.respond_to?(:send_keys) ? self.search_element.send_keys(:enter) : @browser.send_keys('{ENTER}')
	end
end

