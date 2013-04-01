module TemplateHelper
  
  def self.render_rhtml(rhtml, data={})
    output = rhtml.result(TemplateData.new(data).get_binding)
    while (data = output.match(/\{\{[\w\_\.]+\}\}/).to_s).length > 0 do
      replace = data.gsub(/[^\w\_\.]+/, '').split(/\./).join("\"][\"")
      replace = "<%= @data[\"#{replace}\"] %>"
      output = output.gsub(data, replace)
    end
    output
  end

  def self.render_view(view, data="")
    path = "#{RAILS_ROOT}/app/views/#{view}.erb"
    rhtml = ERB.new(File.exists?(path) ? File.read(path) : "")
    render_rhtml(rhtml, data)
  end

  # http://ruby-doc.org/stdlib/libdoc/erb/rdoc/ (Ruby in HTML)
  class TemplateData
    def initialize(data)
      @data = data
    end

    def get_binding
      binding
    end
  end
end
