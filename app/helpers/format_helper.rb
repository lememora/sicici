module FormatHelper
  # format activerecord datetime to a known string format
  def self.date(datetime, with_timezone=true)
    with_timezone ? ( datetime.nil? ? "" : ActiveSupport::TimeWithZone.new(DateTime.parse(datetime.to_s), ActiveSupport::TimeZone.new(APP_CONFIG["time_zone"])).strftime("%Y-%m-%d") ) : ( datetime.nil? ? "" : datetime.strftime("%Y-%m-%d") )
  end

  def self.time(datetime)
    datetime.nil? ? "" : ActiveSupport::TimeWithZone.new(datetime, ActiveSupport::TimeZone.new(APP_CONFIG["time_zone"])).strftime("%Hh%M") rescue ""
  end

  def self.date_time(datetime)
    datetime.nil? ? "" : ActiveSupport::TimeWithZone.new(datetime, ActiveSupport::TimeZone.new(APP_CONFIG["time_zone"])).strftime("%Y-%m-%d %Hh%M") rescue ""
  end

  def self.alphanum?(text)
    not text.to_s.match(/[^[:digit:][:alpha:]]/)
  end

  def self.alphanum!(text, replace='')
    text.to_s.gsub(/[^[:digit:][:alpha:]]/, replace)
  end

  def self.gender(gender)
    gender = gender.to_s.downcase
    return "" unless [ 'male', 'female' ].include?(gender)
    gender == 'male' ? "Masculino" : "Feminino"
  end

  def self.mailto(email)
    email = email.to_s.downcase
    return "" if email.empty?
    "<a href=\"mailto:#{email}\">#{email}</a>"
  end

  # wrap matched string with markup
  def self.markup_wrap(txt, sub, mkp)
    txt = txt.to_s
    sub = sub.to_s
    return "" if txt.empty? or sub.empty?
    out = txt
    if (x = txt.downcase.index(sub.downcase))
      tl = txt.length
      sl = sub.length
      out = "#{txt.slice(0,x)}<#{mkp}>#{txt.slice(x,sl)}</#{mkp}>#{txt.slice(x+sl,tl-x-sl)}"
    end
    out
  end

  # format quick search result
  def self.quick_result(header, footer)
    footer ? "#{header}<br/><i>#{footer}</i>" : header
  end
end
