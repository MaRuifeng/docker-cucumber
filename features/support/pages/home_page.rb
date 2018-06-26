class HomePage
	include PageObject
	include DataMagic
	include FigNewton

	def initialize_page
		# gets called at end of page_object initializer
	end

	page_url("#{FigNewton.base_url}")
	# page_url("#{FigNewton.send('base_url')}")

	# find the search field and assign methods
	# text_field :search, :name => 'q'
  text_field(:search, name: 'q', type: 'text')

	def search_for term
		self.search = term
		$log.info "Searching term: #{term}"
		self.search_element.respond_to?(:send_keys) ? self.search_element.send_keys(:enter) : @browser.send_keys('{ENTER}')
	end
end

