# This XML handler converges all JUnit XML reports produced by the 
# cucumber scripts into a single XML file suitable for HTML report generation. 
# An XSLT file is then applied to generate a summarized HTML report in JUnit format. 
# Maintainer: ruifengm@sg.ibm.com
# Date: 2016-July-05

require 'nokogiri'
require 'rexml/document'

include REXML

result_directory = "#{Dir.home}/cucumber_results"
junit_directory = "#{result_directory}/junit"
log_directory = "#{result_directory}/logs"
report_directory = "#{result_directory}/reports"

xml_all_doc = Document.new

# Add XML declaration
xml_all_doc << XMLDecl.new

# Add element tree
testsuites = Element.new "testsuites"
testsuite_id = 0
testsuites.add_attribute("logs", (log_directory + "/").gsub("#{Dir.home}", ""))
Dir["#{junit_directory}/TEST-*.xml"].each do |file_path|
    xml_file = File.new(file_path)
	xml_doc = Document.new(xml_file)
	xml_doc.elements.each("testsuite") do |e|
		# Add useful attributes
		feature_name = e.attribute("name").value
		e.add_attribute("id", testsuite_id)
		e.add_attribute("package", feature_name)
		log_link = String.new
		Dir["#{log_directory}/*cuke_trace.log"].each do |file_path|
			# if file_path =~ Regexp.new(feature_name.gsub(/\s+/, "-"), Regexp::IGNORECASE)
			if file_path.split("/")[-1].gsub("-cuke_trace.log", "") == feature_name.gsub(/\s+/, "-")
				log_link = file_path.gsub("#{Dir.home}", "")
				break
			end
		end
        e.add_attribute("log", log_link)
        report_link = String.new
		Dir["#{report_directory}/*.html"].each do |file_path|
			# if file_path =~ Regexp.new(feature_name.gsub(/\s+/, "-"), Regexp::IGNORECASE)
			if file_path.split("/")[-1].gsub(".html", "") == feature_name.gsub(/\s+/, "-")
				report_link = file_path.gsub("#{Dir.home}", "")
				break
			end
		end
        e.add_attribute("cuke_report", report_link)
        # Add test properties
		properties = Element.new "properties"
		property = Element.new "property"
		property.add_attribute("name", "test_env")
		property.add_attribute("value", "docker-cucumber")
		properties.add_element property
		e.add_element properties
		testsuites.add_element e

		testsuite_id = testsuite_id + 1
	end
end 
xml_all_doc.add_element testsuites

# Write summary XML file
xml_all_doc.write(:output => File.open("#{result_directory}/summary.xml", "w"), :indent => 2)

# Write summary HTML file
document = Nokogiri::XML(xml_all_doc.to_s)
template = Nokogiri::XSLT(File.read('junit-noframe.xsl'))

transformed_document = template.transform(document)
File.open("#{result_directory}/summary.html", "w").write(transformed_document)