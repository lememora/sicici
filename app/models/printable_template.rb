class PrintableTemplate < ActiveRecord::Base
  has_many :printables

  validates_presence_of :name
  validates_uniqueness_of :name

  def permalink
    self.name.to_s.parameterize.to_s.gsub(/-/,'_')
  end

  # A4 210mm x 297mm
  # 1 point = 0.3528mm

  def self.template_lista_de_pessoas(title, data)
    require 'pdf/writer'

    pdf = PDF::Writer.new(:paper => "A4", :orientation => :portait)

    offset_y = 0
    counter = 0

    img_base = "public/images/printable_template"
    img_logo = pdf.image "#{RAILS_ROOT}/#{img_base}/logo.jpg", :resize => 0.1
    img_plus = pdf.image "#{RAILS_ROOT}/#{img_base}/plus.jpg", :resize => 0.1

    data.each do |j|
      pdf.add_text(95, 780, ApplicationHelper.ignore_utf8(title), 18)

      pdf.add_image(img_logo, 25, 780, 55, 34)
      pdf.add_image(img_plus, 95, 25, 18, 18)

      pdf.stroke_color Color::RGB::Gray
      pdf.move_to(95, 755 - offset_y).line_to(570, 755 - offset_y)
      pdf.stroke

      data_name = j.name || ''
      data_name = ApplicationHelper.ignore_utf8(data_name)
      data_organization = (j.employment.organization.name rescue nil) || ''
      data_organization = ApplicationHelper.ignore_utf8(data_organization)
      data_country = (j.individual_localizations.first.localization.country rescue nil) || ''
      data_country = Country.find_by_id(data_country) unless data_country.empty?
      data_country = ApplicationHelper.ignore_utf8(data_country)
      data_phone = (j.individual_connections.last.value rescue nil) || ''
      data_phone = ApplicationHelper.ignore_utf8(data_phone)
      data_activity = (j.personal_activities.last.name rescue nil) || ''
      data_activity = ApplicationHelper.ignore_utf8(data_activity)

      pdf.add_text( 95, 735 - offset_y, data_name, 10)
      pdf.fill_color Color::RGB::Gray
      pdf.add_text(375, 735 - offset_y, data_organization, 10)
      pdf.add_text( 95, 720 - offset_y, data_country, 10)
      pdf.add_text(255, 720 - offset_y, data_phone, 10)
      pdf.add_text(375, 720 - offset_y, data_activity, 10)

      pdf.stroke_color Color::RGB::Black
      pdf.fill_color Color::RGB::Black

      offset_y = offset_y + 45
      counter = counter + 1

      if counter == 15
        counter = 0
        offset_y = 0
        pdf.start_new_page
      end

      pdf.fill_color Color::RGB::White
      pdf.stroke_color Color::RGB::Black

      pdf.rectangle(570, 0, 200, 800).fill

      pdf.fill_color Color::RGB::Black
      pdf.stroke_color Color::RGB::Black
    end

    pdf.render
  end

  # Letter Landscape Pimaco 6095
  # width: 168 points
  # height: 243 points
  def self.template_cracha_pimaco_6095(title, data)
    require 'pdf/writer'

    pdf = PDF::Writer.new(:paper => "LETTER", :orientation => :landscape)

    offset_x = 70.86
    offset_y = 535.00
    counter = 0

    img_base = "public/images/printable_template"
    img_logo = pdf.image "#{RAILS_ROOT}/#{img_base}/logo.jpg", :resize => 0.1
    img_plus = pdf.image "#{RAILS_ROOT}/#{img_base}/plus.jpg", :resize => 0.1

    data.each do |j|

      pdf.fill_color Color::RGB::White
      pdf.stroke_color Color::RGB::White

      pdf.rectangle(offset_x, offset_y - 243, 168, 243).fill

      pdf.fill_color Color::RGB::Black
      pdf.stroke_color Color::RGB::Black

      pdf.add_image(img_logo, 15 + offset_x, offset_y - 15, 55, 34)
      pdf.add_image(img_plus, 15 + offset_x, offset_y - 200, 18, 18)

      pdf.rectangle(15 + offset_x, offset_y - 52, 153, 25).fill
      pdf.fill_color Color::RGB::White
      pdf.add_text(22 + offset_x, offset_y - 45, ApplicationHelper.ignore_utf8(title), 16)
      pdf.fill_color Color::RGB::Black

      data_name = j.name || ''
      data_name = ApplicationHelper.ignore_utf8(data_name)
      data_organization = (j.employment.organization.name rescue nil) || ''
      data_organization = ApplicationHelper.ignore_utf8(data_organization)
      data_country = (j.individual_localizations.first.localization.country rescue nil) || ''
      data_country = Country.find_by_id(data_country) unless data_country.empty?
      data_country = ApplicationHelper.ignore_utf8(data_country)
      data_phone = (j.individual_connections.last.value rescue nil) || ''
      data_phone = ApplicationHelper.ignore_utf8(data_phone)
      #data_activity = (j.personal_activities.last.name rescue nil) || ''
      #data_activity = ApplicationHelper.ignore_utf8(data_activity)
      data_job_position = (j.employment.job_position rescue nil) || ''
      data_job_position = ApplicationHelper.ignore_utf8(data_job_position)

      pdf.add_text(15.5 + offset_x, offset_y - 65, data_name, 11)
      pdf.add_text(15.5 + offset_x, offset_y - 86, data_organization, 8)

      pdf.stroke_color Color::RGB::Gray
      pdf.fill_color Color::RGB::Gray

      pdf.move_to(15 + offset_x, offset_y - 72)
      pdf.line_to(153 + offset_x, offset_y - 72)
      pdf.stroke
      pdf.move_to(15 + offset_x, offset_y - 95)
      pdf.line_to(153 + offset_x, offset_y - 95)
      pdf.stroke

      pdf.add_text(15.5 + offset_x, offset_y - 111, data_country, 9)
      #pdf.add_text(80 + offset_x, offset_y - 111, data_phone, 9)
      #pdf.add_text(22 + offset_x, offset_y - 128, data_activity, 9)
      pdf.add_text(15.5 + offset_x, offset_y - 128, data_job_position, 9)

      pdf.fill_color Color::RGB::White
      pdf.stroke_color Color::RGB::White

      pdf.rectangle(743.76, 0, 300, 611.96).fill

      pdf.fill_color Color::RGB::Black
      pdf.stroke_color Color::RGB::Black

      offset_x = offset_x + 168
      counter = counter + 1

      if counter > 0 and counter % 4 == 0
        offset_x = 70.86
        offset_y = 265.00
      end

      if counter == 8
        counter = 0
        offset_x = 70.86
        offset_y = 535.00
        pdf.start_new_page
      end
    end

    pdf.render
  end

  # Letter Pimaco 6082
  # vertical margin: 59.67 points
  # horizontal margin: 12 points
  # horizontal spacing: 12 points
  # width: 287.98 points
  # height: 96.09 points
  def self.template_correspondencia_pimaco_6082(title, data)
    require 'pdf/writer'

    pdf = PDF::Writer.new(:paper => "LETTER", :orientation => :portait)

    offset_x = 12
    offset_y = 732.3
    counter = 0

    img_base = "public/images/printable_template"
    img_logo = pdf.image "#{RAILS_ROOT}/#{img_base}/logo.jpg", :resize => 0.1
    img_plus = pdf.image "#{RAILS_ROOT}/#{img_base}/plus.jpg", :resize => 0.1

    data.each do |j|
      pdf.fill_color Color::RGB::White
      pdf.stroke_color Color::RGB::White

      pdf.rectangle(offset_x, offset_y - 96.09, 287.98, 96.09).fill

      pdf.fill_color Color::RGB::Black
      pdf.stroke_color Color::RGB::Black

      #pdf.add_image(img_logo, 15 + offset_x, offset_y - 45, 55, 34)
      #pdf.add_image(img_plus, 255 + offset_x, offset_y - 50, 18, 18)

      data_name = j.name || ''
      data_name = ApplicationHelper.ignore_utf8(data_name)
      data_organization = (j.employment.organization.name rescue nil) || ''
      data_organization = ApplicationHelper.ignore_utf8(data_organization)
      data_address = (j.individual_localizations.first.localization.address rescue nil) || ''
      data_address = ApplicationHelper.ignore_utf8(data_address)
      data_district = (j.individual_localizations.first.localization.district rescue nil) || ''
      data_district = ApplicationHelper.ignore_utf8(data_district)
      data_city = (j.individual_localizations.first.localization.city rescue nil) || ''
      data_city = ApplicationHelper.ignore_utf8(data_city)
      data_state = (j.individual_localizations.first.localization.state rescue nil) || ''
      data_state = ApplicationHelper.ignore_utf8(data_state)
      data_code = (j.individual_localizations.first.localization.code rescue nil) || ''
      data_code = ApplicationHelper.ignore_utf8(data_code)
      data_country = (j.individual_localizations.first.localization.country rescue nil) || ''
      data_country = Country.find_by_id(data_country) unless data_country.empty?
      data_country = ApplicationHelper.ignore_utf8(data_country)
      data_address_2 = String.new
      data_address_2<< "#{data_district} - " unless data_district.empty?
      data_address_2<< "#{data_city}"
      data_address_2<< ",#{data_state}" unless data_state.empty?
      data_address_2<< " - #{data_country}" unless data_country.empty?
      data_address_2<< " | #{data_code}" unless data_code.empty?

      pdf.add_text(20 + offset_x, offset_y - 20, data_name, 10)

      pdf.stroke_color Color::RGB::Gray
      pdf.fill_color Color::RGB::Gray

      pdf.add_text(20 + offset_x, offset_y - 39, data_organization, 10)

      pdf.stroke_color Color::RGB::Black
      pdf.fill_color Color::RGB::Black

      pdf.add_text(20 + offset_x, offset_y - 55, data_address, 8)
      pdf.add_text(20 + offset_x, offset_y - 70, data_address_2, 8)

      pdf.stroke_color Color::RGB::Gray
      pdf.fill_color Color::RGB::Gray

      offset_x = offset_x + 299.98
      counter = counter + 1

      if counter > 0 and counter % 2 == 0
        offset_x = 12
        offset_y = offset_y - 96.09
      end

      if counter == 14
        counter = 0
        offset_x = 12
        offset_y = 732.3
        pdf.start_new_page
      end
    end

    pdf.render
  end

end
