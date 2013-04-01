# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def self.public_data_find(context, id)
    directory = "public/data/#{context}"
    return nil if not File.exist?(directory)
    results = Dir.entries(directory).select { |f| f.match(Regexp.new("^#{id}\.")) }
    "#{directory}/#{results.first}" if results.length > 0
  end

  def self.public_data_delete(context, id)
    found = public_data_find(context, id)
    File.delete(found) unless found.nil?
  end

  def self.public_data_url(context, id)
    found = public_data_find(context, id)
    return found.sub('public', '') if found
  end

  def self.public_data_base64(context, id)
    require 'base64'
    found = public_data_find(context, id)
    found ? Base64.encode64(IO.read(found).chop) : nil
  end

  def self.public_data_write(data, extension, context, id)
    context = context.to_s
    directory = "public/data/#{context}"

    require 'fileutils'
    FileUtils.mkdir_p directory

    public_data_delete(context, id)

    File.open(File.join(directory, "#{id}#{extension}"), "wb") { |f| f.write(data) }
  end

  def self.public_data_upload(param, context, id)
    extension = param.original_filename.match(/\.[a-z0-9]+$/i).to_s.downcase
    public_data_write(param.read, extension, context, id)
  end

  def self.public_data_read(context, id)
    path = public_data_find(context, id)
    File.open(path, "r") { |f| f.read }
  end

  def self.generate_rand_hash
    temporary = Array.new
    16.times { temporary << rand(1024) }
    require 'digest/sha1'
    Digest::SHA1.hexdigest(temporary.join('-'))
  end

  def self.remove_diacritics(str) # under deprecation...
    diacritics = [
      [ "ÁáĆćÉéǴǵÍíḰḱĹĺḾḿŃńÓóṔṕŔŕŚśÚúẂẃÝýŹź",
        "AaCcEeGgIiKkLlMmNnOoPpRrSsUuWwYyZz" ],
      [ "ȺⱥɃƀȻȼĐđɆɇǤǥĦħƗɨɈɉŁłØøⱣᵽɌɍŦŧɄʉɎɏƵƶ",
        "AaBbCcDdEeGgHhIiJjLlOoPpRrTtUuYyZz" ],
      [ "ĂăĔĕĞğĬĭŎŏŬŭ",
        "AaEeGgIiOoUu" ],
      [ "ǍǎČčĎďĚěǦǧȞȟǏǐǰǨǩĽľŇňǑǒŘřŠšŤťǓǔŽž",
        "AaCcDdEeGgHhIijKkLlNnOoRrSsTtUuZz" ],
      [ "ÇçḐḑȨȩĢģḨḩĶķĻļŅņŖŗŞşŢţ",
        "CcDdEeGgHhKkLlNnRrSsTt" ],
      [ "ÂâĈĉÊêĜĝĤĥÎîĴĵÔôŜŝÛûŴŵŶŷẐẑ",
        "AaCcEeGgHhIiJjOoSsUuWwYyZz" ],
      [ "ḆḇḎḏẖḴḵḺḻṈṉṞṟ",
        "BbDdhKkLlNnRr" ],
      [ "ȦȧḂḃĊċḊḋĖėḞḟĠġḢḣİṀṁṄṅȮȯṖṗṘṙṠṡṪṫẆẇẊẋẎẏŻż",
        "AaBbCcDdEeFfGgHhIMmNnOoPpRrSsTtWwXxYyZz" ],
      [ "ẠạḄḅḌḍẸẹḤḥỊịḲḳḶḷṂṃṆṇỌọṚṛṢṣṬṭỤụṾṿẈẉỴỵẒẓ",
        "AaBbDdEeHhIiKkLlMmNnOoRrSsTtUuVvWwYyZz" ],
      [ "ŐőŰű",
        "OoUu" ],
      [ "ȀȁȄȅȈȉȌȍȐȑȔȕ",
        "AaEeIiOoRrUu" ],
      [ "ÀàÈèÌìǸǹÒòÙùẀẁỲỳ",
        "AaEeIiNnOoUuWwYy" ],
      [ "ƠơƯư",
        "OoUu" ],
      [ "ĀāĒēḠḡĪīŌōŪūȲȳ",
        "AaEeGgIiOoUuYy" ],
      [ "ĄąĘęĮįǪǫŲų",
        "AaEeIiOoUu" ],
      [ "ÅåŮůẘẙ",
        "AaUuwy" ],
      [ "ÃãẼẽĨĩÑñÕõŨũṼṽỸỹ",
        "AaEeIiNnOoUuVvYy" ],
      [ "ÄäËëḦḧÏïÖöẗÜüẄẅẌẍŸÿ",
        "AaEeHhIiOotUuWwXxYy" ] ]
    
    acc = diacritics.map { |j| j[0] }.join.split(//u)
    noa = diacritics.map { |j| j[1] }.join.split(//u)

    if acc.length != noa.length
      throw Exception.new("diacritics translation table with different size")
    end

    arr = Array.new
    str.split(//u).each do |c|
      j = acc.index(c)
      arr<< (j.nil? ? c : noa[j])
    end
    arr.join
  end

  def self.generate_permalink(str) # under deprecation...
    ## str = self.remove_diacritics(str)
    ## str = str.gsub(/[^\w\s]/, '').gsub(/[^\w]|[\_]/, ' ')
    ## str.split.join('-').downcase
    str.parameterize.to_s # simple like that :)
  end

  def self.extract_key_value(records, k, v, filter, value_only=false)
    results = []
    if value_only
      results = records.map { |r| r[v.to_sym] }
      results = results.select do |r|
        r.downcase.index(filter.downcase) != nil
      end unless filter.nil?
    else
      results = records.map { |r| [ r[k.to_sym], r[v.to_sym] ] }
      results = results.select do |r|
        r[1].downcase.index(filter.downcase) != nil
      end unless filter.nil?
    end
    results
  end

  def self.ignore_utf8(str)
    require 'iconv'

    ic_ignore = Iconv.new('ISO-8859-15//IGNORE//TRANSLIT', 'UTF-8')
    str = ic_ignore.iconv(str)
    ic_ignore.close
      
    str
  end
end
