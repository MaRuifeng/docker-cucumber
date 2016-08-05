# Customized HTML formatter that writes an HTML report file for each feature, instead of a combined one for all scenarios. 
# Maintainer: ruifengm@sg.ibm.com
# 01-Jul-2016

require 'cucumber/formatter/html'
require 'cucumber/formatter/duration_extractor'
require 'open-uri'

module SegmentedView
  class HtmlEach < Cucumber::Formatter::Html

    def initialize(runtime, path_or_io, options)
      @report_path = path_or_io
      @runtime = runtime
      @options = options
      @buffer = {}
      @feature_number = 0
      @scenario_number = 0
      @step_number = 0
      @delayed_messages = []
      @img_id = 0
      @text_id = 0
      @inside_outline = false
      @previous_step_keyword = nil
    end

    def before_features(features)
      @step_count = features && features.step_count || 0 #TODO: Make this work with core!
    end

    def after_features(features)
      # Nothing to do
    end

    def before_feature(feature)
      # @html_io = ensure_io("#{Dir.home}/cucumber_results/reports/#{feature.name}.html")
      @html_io = ensure_io("#{@report_path}/#{feature.name.gsub(/\s+/, '-')}.html")
      @builder = create_builder(@html_io)
      @feature_duration = 0
      @header_red = false

      # Number of steps & scenarios visited
      @feature_step_count = 0
      @feature_scenario_count = 0
      @step_count_before_feature = @runtime.steps.length
      @scenario_count_before_feature = @runtime.scenarios.length

      # <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
      @builder.declare!(
        :DOCTYPE,
        :html,
        :PUBLIC,
        '-//W3C//DTD XHTML 1.0 Strict//EN',
        'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'
      )

      @builder << '<html xmlns ="http://www.w3.org/1999/xhtml">'
        @builder.head do
        @builder.meta('http-equiv' => 'Content-Type', :content => 'text/html;charset=utf-8')
        @builder.title 'Cucumber'
        inline_css
        inline_js
      end
      @builder << '<body>'
      @builder << "<!-- Step count #{@step_count}-->"
      @builder << '<div class="cucumber">'
      @builder.div(:id => 'cucumber-header') do
        @builder.div(:id => 'label') do
          @builder.h1("Cucumber Feature: #{feature.name}")
        end
        @builder.div(:id => 'summary') do
          @builder.p('',:id => 'totals')
          @builder.p('',:id => 'duration')
          @builder.div(:id => 'expand-collapse') do
            @builder.p('Expand All', :id => 'expander')
            @builder.p('Collapse All', :id => 'collapser')
          end
        end
      end
        @exceptions = []
        @builder << '<div class="feature">'
      end

      def after_feature(feature)
        @builder << '</div>'
        @feature_step_count = @runtime.steps.length - @step_count_before_feature
      @feature_scenario_count = @runtime.scenarios.length - @scenario_count_before_feature
        print_stats(feature)
      @builder << '</div>'
      @builder << '</body>'
      @builder << '</html>'
      end

      def print_stats(feature)
        @builder <<  "<script type=\"text/javascript\">document.getElementById('duration').innerHTML = \"Finished in <strong>#{format_duration(@feature_duration)} seconds</strong>\";</script>"
        @builder <<  "<script type=\"text/javascript\">document.getElementById('totals').innerHTML = \"#{print_stat_string(feature)}\";</script>"
      end

      # Purpose of overriding: create correctly encoded URLs for embedded screen shots
      def embed_image(src, label)
        id = "img_#{@img_id}"
        @img_id += 1
        if @io.respond_to?(:path) and File.file?(src)
          out_dir = Pathname.new(File.dirname(File.absolute_path(@io.path)))
          src = Pathname.new(File.absolute_path(src)).relative_path_from(out_dir)
        end
        # removing home dir
        src = URI::encode(src.gsub("#{Dir.home}", ''))
        @builder.span(:class => 'embed') do |pre|
          pre << %{<a href="" onclick="img=document.getElementById('#{id}'); img.style.display = (img.style.display == 'none' ? 'block' : 'none');return false">#{label}</a><br>&nbsp;
          <img id="#{id}" style="display: none" src="#{src}"/>}
        end
      end

      # Purpose of overriding: update feature duration
      def after_test_case(test_case, result)
        if result.failed? and not @scenario_red
          set_scenario_color_failed
        end
        @feature_duration += Cucumber::Formatter::DurationExtractor.new(result).result_duration
      end

      # Purpose of overriding: update feature scenario and step counts
      def print_stat_string(feature)
        string = String.new
        string << dump_count(@feature_scenario_count, 'scenario')
        scenario_count = print_status_counts{|status| filter_by_status(@runtime.scenarios.last(@feature_scenario_count), status)}
        string << scenario_count if scenario_count
        string << '<br />'
        string << dump_count(@feature_step_count, 'step')
        step_count = print_status_counts{|status| filter_by_status(@runtime.steps.last(@feature_step_count), status)}
        string << step_count if step_count
      end

      def filter_by_status(elements, status = nil)
        if (status)
          elements.select{|element| element.status == status }
        else
          elements
        end
      end

  end
end
