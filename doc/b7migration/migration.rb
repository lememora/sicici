require 'time'

B7_NACIONALIDADE = { 
  "Espanhola"   => "ES", 
  "Espa\361ola" => "ES", 
  "Brasileira"  => "BR", 
  "Cubana"      => "CU", 
  "Brasileiro"  => "BR", 
  "espanhola"   => "ES",
  "Espa\361ol"  => "ES", 
  "cubana"      => "CU", 
  "brasleira"   => "BR", 
  "brasileira"  => "BR", 
  "Chilena"     => "CL", 
  "Argentina"   => "AR", 
  "Mexicana"    => "MX", 
  "Cubano"      => "CU", 
  "senegales"   => "SN",
  "brasielira"  => "BR", 
  "argentina"   => "AR"
}

B7_PAIS = {
  "Afeganist\343o" => "AF",
  "\301frica do Sul" => "ZA",
  "Alb\342nia" => "AL",
  "Alemanha" => "DE",
  "Alg\351ria" => "DZ",
  "Andorra" => "AD",
  "Angola" => "AO",
  "Anguilla" => "AI",
  "Ant\341rtida" => "AQ",
  "Ant\355gua e Barbuda" => "AG",
  "Antilhas Holandesas" => "AN",
  "Ar\341bia Saudita" => "SA",
  "Argentina" => "AR",
  "Arm\352nia" => "AM",
  "Aruba" => "AW",
  "Austr\341lia" => "AU",
  "\301ustria" => "AT",
  "Azerbaij\343o" => "AZ",
  "Bahamas" => "BS",
  "Bahrein" => "BH",
  "Bangladesh" => "BD",
  "Barbados" => "BB",
  "Belarus" => "BY",
  "B\351lgica" => "BE",
  "Belize" => "BZ",
  "Benin" => "BJ",
  "Bermudas" => "BM",
  "Bol\355via" => "BO",
  "B\363snia-Herzeg\363vina" => "BA",
  "Botsuana" => "BW",
  "Brasil" => "BR",
  "Brunei" => "BN",
  "Bulg\341ria" => "BG",
  "Burkina Fasso" => "BF",
  "Burundi" => "BI",
  "But\343o" => "BT",
  "Cabo Verde" => "CV",
  "Camar\365es" => "CM",
  "Camboja" => "KH",
  "Canad\341" => "CA",
  "Cazaquist\343o" => "KZ",
  "Chade" => "TD",
  "Chile" => "CL",
  "China" => "CN",
  "Chipre" => "CY",
  "Cingapura" => "SG",
  "Col\364mbia" => "CO",
  "Congo" => "CG",
  "Cor\351ia do Norte" => "KP",
  "Cor\351ia do Sul" => "KR",
  "Costa do Marfim" => "CI",
  "Costa Rica" => "CR",
  "Cro\341cia (Hrvatska)" => "HR",
  "Cuba" => "CU",
  "Dinamarca" => "DK",
  "Djibuti" => "DJ",
  "Dominica" => "DM",
  "Egito" => "EG",
  "El Salvador" => "SV",
  "Emirados \301rabes Unidos" => "AE",
  "Equador" => "EC",
  "Eritr\351ia" => "ER",
  "Eslov\341quia" => "SK",
  "Eslov\352nia" => "SI",
  "Espanha" => "ES",
  "Espa\361a" => "ES",
  "Estados Unidos" => "US",
  "Est\364nia" => "EE",
  "Eti\363pia" => "ET",
  "Federa\347\343o Russa" => "RU",
  "Fiji" => "FJ",
  "Filipinas" => "PH",
  "Finl\342ndia" => "FI",
  "Fran\347a" => "FR",
  "Fran\347a Metropolitana" => "FX",
  "Gab\343o" => "GA",
  "G\342mbia" => "GM",
  "Gana" => "GH",
  "Ge\363rgia" => "GE",
  "Gibraltar" => "GI",
  "Gr\343-Bretanha (Reino Unido, UK)" => "GB",
  "Granada" => "GD",
  "Gr\351cia" => "GR",
  "Groel\342ndia" => "GL",
  "Guadalupe" => "GP",
  "Guam (Territ\363rio dos Estados Unidos)" => "GU",
  "Guatemala" => "GT",
  "Guiana" => "GY",
  "Guiana Francesa" => "GF",
  "Guin\351" => "GN",
  "Guin\351 Equatorial" => "GQ",
  "Guin\351-Bissau" => "GW",
  "Haiti" => "HT",
  "Holanda" => "NL",
  "Honduras" => "HN",
  "Hong Kong" => "HK",
  "Hungria" => "HU",
  "I\352men" => "YE",
  "Ilha Bouvet (Territ\363rio da Noruega)" => "BV",
  "Ilha Natal" => "CX",
  "Ilha Pitcairn" => "PN",
  "Ilha Reuni\343o" => "RE",
  "Ilhas Cayman" => "KY",
  "Ilhas Cocos" => "CC",
  "Ilhas Comores" => "KM",
  "Ilhas Cook" => "CK",
  "Ilhas Faeroes" => "FO",
  "Ilhas Falkland (Malvinas)" => "FK",
  "Ilhas Ge\363rgia do Sul e Sandwich do Sul" => "GS",
  "Ilhas Heard e McDonald (Territ\363rio da Austr\341lia)" => "HM",
  "Ilhas Marianas do Norte" => "MP",
  "Ilhas Marshall" => "MH",
  "Ilhas Menores dos Estados Unidos" => "UM",
  "Ilhas Norfolk" => "NF",
  "Ilhas Seychelles" => "SC",
  "Ilhas Solom\343o" => "SB",
  "Ilhas Svalbard e Jan Mayen" => "SJ",
  "Ilhas Tokelau" => "TK",
  "Ilhas Turks e Caicos" => "TC",
  "Ilhas Virgens (Estados Unidos)" => "VI",
  "Ilhas Virgens (Inglaterra)" => "VG",
  "Ilhas Wallis e Futuna" => "WF",
  "\355ndia" => "IN",
  "Indon\351sia" => "ID",
  "Ir\343" => "IR",
  "Iraque" => "IQ",
  "Irlanda" => "IE",
  "Isl\342ndia" => "IS",
  "Israel" => "IL",
  "It\341lia" => "IT",
  "Iugosl\341via" => "YU",
  "Jamaica" => "JM",
  "Jap\343o" => "JP",
  "Jord\342nia" => "JO",
  "K\352nia" => "KE",
  "Kiribati" => "KI",
  "Kuait" => "KW",
  "Laos" => "LA",
  "L\341tvia" => "LV",
  "Lesoto" => "LS",
  "L\355bano" => "LB",
  "Lib\351ria" => "LR",
  "L\355bia" => "LY",
  "Liechtenstein" => "LI",
  "Litu\342nia" => "LT",
  "Luxemburgo" => "LU",
  "Macau" => "MO",
  "Maced\364nia" => "MK",
  "Madagascar" => "MG",
  "Mal\341sia" => "MY",
  "Malaui" => "MW",
  "Maldivas" => "MV",
  "Mali" => "ML",
  "Malta" => "MT",
  "Marrocos" => "MA",
  "Martinica" => "MQ",
  "Maur\355cio" => "MU",
  "Maurit\342nia" => "MR",
  "Mayotte" => "YT",
  "M\351xico" => "MX",
  "Micron\351sia" => "FM",
  "Mo\347ambique" => "MZ",
  "Moldova" => "MD",
  "M\364naco" => "MC",
  "Mong\363lia" => "MN",
  "Montserrat" => "MS",
  "Myanma" => "MM",
  "Nam\355bia" => "NA",
  "Nauru" => "NR",
  "Nepal" => "NP",
  "Nicar\341gua" => "NI",
  "N\355ger" => "NE",
  "Nig\351ria" => "NG",
  "Niue" => "NU",
  "Noruega" => "NO",
  "Nova Caled\364nia" => "NC",
  "Nova Zel\342ndia" => "NZ",
  "Om\343" => "OM",
  "Palau" => "PW",
  "Panam\341" => "PA",
  "Papua-Nova Guin\351" => "PG",
  "Paquist\343o" => "PK",
  "Paraguai" => "PY",
  "Peru" => "PE",
  "Polin\351sia Francesa" => "PF",
  "Pol\364nia" => "PL",
  "Porto Rico" => "PR",
  "Portugal" => "PT",
  "Qatar" => "QA",
  "Quirguist\343o" => "KG",
  "Rep\372blica Centro-Africana" => "CF",
  "Rep\372blica Dominicana" => "DO",
  "Rep\372blica Tcheca" => "CZ",
  "Rom\352nia" => "RO",
  "Ruanda" => "RW",
  "Saara Ocidental" => "EH",
  "Saint Vincente e Granadinas" => "VC",
  "Samoa Americana" => "AS",
  "Samoa Ocidental" => "WS",
  "San Marino" => "SM",
  "Santa Helena" => "SH",
  "Santa L\372cia" => "LC",
  "S\343o Crist\363v\343o e N\351vis" => "KN",
  "S\343o Tom\351 e Pr\355ncipe" => "ST",
  "Senegal" => "SN",
  "Serra Leoa" => "SL",
  "S\355ria" => "SY",
  "Som\341lia" => "SO",
  "Sri Lanka" => "LK",
  "St. Pierre and Miquelon" => "PM",
  "Suazil\342ndia" => "SZ",
  "Sud\343o" => "SD",
  "Su\351cia" => "SE",
  "Su\355\347a" => "CH",
  "Suriname" => "SR",
  "Tadjiquist\343o" => "TJ",
  "Tail\342ndia" => "TH",
  "Taiwan" => "TW",
  "Tanz\342nia" => "TZ",
  "Territ\363rio Brit\342nico do Oceano \355ndico" => "IO",
  "Territ\363rios do Sul da Fran\347a" => "TF",
  "Timor Leste" => "TP",
  "Togo" => "TG",
  "Tonga" => "TO",
  "Trinidad and Tobago" => "TT",
  "Tun\355sia" => "TN",
  "Turcomenist\343o" => "TM",
  "Turquia" => "TR",
  "Tuvalu" => "TV",
  "Ucr\342nia" => "UA",
  "Uganda" => "UG",
  "Uruguai" => "UY",
  "Uzbequist\343o" => "UZ",
  "Vanuatu" => "VU",
  "Vaticano" => "VA",
  "Venezuela" => "VE",
  "Vietn\343" => "VN",
  "Zaire" => "ZR",
  "Z\342mbia" => "ZM",
  "Zimb\341bue" => "ZW"
}

def pais_estado_cidade(s)
  spl = s.to_s.split(/\//)
  spl_len = spl.length

  continente = ""
  pais = ""
  estado = ""
  cidade = ""

  if spl_len == 2
    continente, pais = spl
  elsif spl_len == 3
    continente, pais, cidade = spl
  elsif spl_len == 4
    continente, pais, cidade, estado = spl
  end

  pais = B7_PAIS[pais] if B7_PAIS[pais]

  return pais, estado, cidade
end

B7_TELEFONE_TIPO = {
  479 => "phone_home",
  482 => "phone_business",
  487 => "phone_mobile",
  489 => "phone_fax",
  617 => "fax_only"
}


class Object
  def b7int
    self.to_s.gsub(/[^0-9]/, '').to_i
  end

  def b7str
    s = self.to_s.strip
    s = "" if s.upcase == "NULL"
    s.gsub(/\"/, '\"')
  end

  def b7dt
    d = self.b7str
    rxp = /^[\d]{2,4}-[\d]{2}-[\d]{2}\s[\d]{2}:[\d]{2}:[\d]{2}$/
    if d.match(rxp)
      d = (Time.parse(d.match(rxp).to_s) + (3600 * 3)).strftime("%Y-%m-%d %H:%M:%S") # to utc
    elsif d.match(/^[\d]{2}\/[\d]{2}\/[\d]{2,4}$/)
      dd, mm, aaaa = d.split(/\//)
      d = "#{aaaa}-#{mm}-#{dd}"
    elsif d.match(/^[\d]{4}$/)
      d = "#{d}-#{01}-#{01}"
    else
      d = "0000-00-00 00:00:00"
    end
    d
  end

  def b7bo(f=false, t=true)
    v = self.b7str
    b = nil if v == ""
    b = false if v == "0" or v.upcase == "FALSE"
    b = true  if b != false and b != nil
    b == nil ? "" : ((f==false and t==true) ? b : (b ? t : f))
  end
end


# ------------------------------------------------------------------------------
# AREA DE ATUAÇÃO (PESSOAS)
# ------------------------------------------------------------------------------

puts "DROP TABLE IF EXISTS b7migration_areas_pf;"
puts
puts "CREATE TABLE b7migration_areas_pf (area_id INT, area_hierarquia VARCHAR(255));"
puts
sqla="INSERT INTO b7migration_areas_pf VALUES (%d, \"%s\");"


f=File.new("05-site_areas_pf-clean.txt", "r")

d=Array.new
u=Array.new

f.each do |line|
  r = line.to_s.chop

  cd_entidade     = r[   0,  11].b7int
  area_id         = r[  12,  11].b7int
  area_hierarquia = r[  24, 255].b7str

  unless u.include?(area_id)
    u<< area_id
    d<< sqla % [ area_id, area_hierarquia ]
  end
end

puts
d[0, d.length - 1].each { |j| puts j }
puts


## # ------------------------------------------------------------------------------
## # CARGOS
## # ------------------------------------------------------------------------------

## puts "DROP TABLE IF EXISTS b7migration_cargos;"
## puts
## puts "CREATE TABLE b7migration_cargos (cargo_id INT, cargo VARCHAR(255));"
## puts
## sqlc="INSERT INTO b7migration_cargos VALUES (%d, \"%s\");"


## f=File.new("05-cargos-clean.txt", "r")

## d=Array.new
## u=Array.new

## f.each do |line|
##   r = line.to_s.chop

##   cargo_id = r[   0,  11].b7int
##   cargo    = r[  12, 255].b7str

##   unless u.include?(cargo_id)
##     u<< cargo_id
##     d<< sqlc % [ cargo_id, cargo ]
##   end
## end

## puts
## d[0, d.length - 1].each { |j| puts j }
## puts


# ------------------------------------------------------------------------------
# PESSOAS
# ------------------------------------------------------------------------------

puts "DROP TABLE IF EXISTS b7migration_pessoas;"
puts
puts "CREATE TABLE b7migration_pessoas (pessoa_id INT, email VARCHAR(255), email_local_ VARCHAR(255), email_dominio_ VARCHAR(255), nome VARCHAR(255), nome_ VARCHAR(255), sobrenome_ VARCHAR(255), data_nascimento VARCHAR(255), sexo VARCHAR(255), sexo_ VARCHAR(255), pais_nacionalidade VARCHAR(255), pais_nacionalidade_ VARCHAR(255), documento VARCHAR(255), documento_tipo VARCHAR(255), documento_tipo_id INT, lista_areas_ids VARCHAR(255), lista_areas VARCHAR(255), telefone1 VARCHAR(255), telefone1_tipo VARCHAR(255), telefone1_tipo_id INT, telefone2 VARCHAR(255), telefone2_tipo VARCHAR(255), telefone2_tipo_id INT, telefone3 VARCHAR(255), telefone3_tipo VARCHAR(255), telefone3_tipo_id INT, endereco_residencial_logradouro VARCHAR(255), endereco_residencial_cidade_id INT, endereco_residencial_cidade VARCHAR(255), endereco_residencial_cep VARCHAR(255), endereco_residencial_bairro VARCHAR(255), empresa_id INT, empresa VARCHAR(255), cargo_id INT, cargo VARCHAR(255), cargo_descricao VARCHAR(255), endereco_comercial_logradouro VARCHAR(255), endereco_comercial_cidade_id INT, endereco_comercial_cidade VARCHAR(255), endereco_comercial_cep VARCHAR(255), endereco_comercial_bairro VARCHAR(255), data_cadastro VARCHAR(255), data_atualizacao VARCHAR(255), usuario_cadastro_id INT, usuario_cadastro VARCHAR(255), usuario_atualizacao_id INT, usuario_atualizacao VARCHAR(255));"
puts
sqlx="INSERT INTO b7migration_pessoas VALUES (%d, \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", %s, \"%s\", \"%s\", \"%s\", \"%s\", %d, \"%s\", \"%s\", \"%s\", \"%s\", %d, \"%s\", \"%s\", %d, \"%s\", \"%s\", %d, \"%s\", %d, \"%s\", \"%s\", \"%s\", %d, \"%s\", %d, \"%s\", \"%s\", \"%s\", %d, \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", %d, \"%s\", %d, \"%s\");"


puts "DROP TABLE IF EXISTS b7migration_pessoas_areas;"
puts
puts "CREATE TABLE b7migration_pessoas_areas (pessoa_id INT, area_id INT);"
puts
sqla="INSERT INTO b7migration_pessoas_areas VALUES (%d, %d);"


puts "DROP TABLE IF EXISTS b7migration_pessoas_telefones;"
puts
puts "CREATE TABLE b7migration_pessoas_telefones (pessoa_id INT, telefone_tipo VARCHAR(255), telefone VARCHAR(255));"
puts
sqlt="INSERT INTO b7migration_pessoas_telefones VALUES (%d, \"%s\", \"%s\");"


puts "DROP TABLE IF EXISTS b7migration_pessoas_enderecos;"
puts
puts "CREATE TABLE b7migration_pessoas_enderecos (pessoa_id INT, tipo_ VARCHAR(50), logradouro VARCHAR(255), pais_ VARCHAR(2), estado_ VARCHAR(255), cidade_ VARCHAR(255), cep VARCHAR(255), bairro VARCHAR(255));"
puts
sqle="INSERT INTO b7migration_pessoas_enderecos VALUES (%d, \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\");"


puts "DROP TABLE IF EXISTS b7migration_pessoas_emails_invalidos;"
puts
puts "CREATE TABLE b7migration_pessoas_emails_invalidos (pessoa_id INT, email VARCHAR(255), motivo VARCHAR(255));"
puts
sqld="INSERT INTO b7migration_pessoas_emails_invalidos VALUES (%d, \"%s\", \"%s\");"


f=File.new("05-site_consulta_pessoa-clean.txt", "r")

d=Array.new
email_buffer=Array.new

f.each do |line|
  r = line.to_s.chop

  pessoa_id                       = r[   0,  11].b7int
  email                           = r[  12, 255].b7str.downcase
  email_local_                    = ""
  email_dominio_                  = ""
  if email.match(/^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,6}$/)
    if email_buffer.include?(email)
      d<< sqld % [ pessoa_id, email, 'duplicado' ]
      email = ""
    else
      email_local_, email_dominio_ = email.split("@", 2)
      email_buffer<< email
    end
  else
    unless email.empty?
      d<< sqld % [ pessoa_id, email, 'formato' ]
      email = ""
    end
  end
  nome                            = r[ 268, 255].b7str
  nome_                           = ""
  sobrenome_                      = ""
  if nome.index(/\s/)
    nome_, sobrenome_ = nome.split(" ", 2)
  end
  data_nascimento                 = r[ 524, 255].b7dt
  sexo                            = r[ 780,   4].b7int
  sexo_ = (sexo == 0 ? "NULL" : "'male'") # 0 is ambiguous (null/female)
  pais_nacionalidade              = r[ 785, 255].b7str
  pais_nacionalidade_ = B7_NACIONALIDADE[pais_nacionalidade] || ""
  documento                       = r[1041,  50].b7str
  documento_tipo                  = r[1092, 255].b7str
  documento_tipo_id               = r[1348,  17].b7int
  lista_areas_ids                 = r[1366, 255].b7str
  lista_areas_ids_ = lista_areas_ids.split(',')
  lista_areas                     = r[1623, 256].b7str
  telefone1                       = r[1880, 255].b7str
  telefone1_tipo                  = r[2136, 255].b7str
  telefone1_tipo_id               = r[2392,  17].b7int
  telefone1_tipo_ = B7_TELEFONE_TIPO[telefone1_tipo_id] || "phone_home"
  telefone2                       = r[2410, 255].b7str
  telefone2_tipo                  = r[2666, 255].b7str
  telefone2_tipo_id               = r[2922,  17].b7int
  telefone2_tipo_ = B7_TELEFONE_TIPO[telefone2_tipo_id] || "phone_home"
  telefone3                       = r[2940, 255].b7str
  telefone3_tipo                  = r[3196, 255].b7str
  telefone3_tipo_id               = r[3452,  17].b7int
  telefone3_tipo_ = B7_TELEFONE_TIPO[telefone3_tipo_id] || "phone_home"
  endereco_residencial_logradouro = r[3470, 255].b7str
  endereco_residencial_cidade_id  = r[3726,  30].b7int
  endereco_residencial_cidade     = r[3757, 255].b7str
  endereco_residencial_pais_, endereco_residencial_estado_, endereco_residencial_cidade_ = pais_estado_cidade(endereco_residencial_cidade)
  endereco_residencial_cep        = r[4013, 255].b7str
  endereco_residencial_bairro     = r[4269, 255].b7str
  empresa_id                      = r[4525,  11].b7int
  empresa                         = r[4537, 255].b7str
  cargo_id                        = r[4793,  11].b7int
  cargo                           = r[4805, 255].b7str
  cargo_descricao                 = r[5061, 255].b7str
  endereco_comercial_logradouro   = r[5317, 255].b7str
  endereco_comercial_cidade_id    = r[5573,  28].b7int
  endereco_comercial_cidade       = r[5602, 255].b7str
  endereco_comercial_pais_, endereco_comercial_estado_, endereco_comercial_cidade_ = pais_estado_cidade(endereco_comercial_cidade)
  endereco_comercial_cep          = r[5858, 255].b7str
  endereco_comercial_bairro       = r[6114, 255].b7str
  data_cadastro                   = r[6370,  54].b7dt
  data_atualizacao                = r[6425,  54].b7dt
  usuario_cadastro_id             = r[6480,  19].b7int
  usuario_cadastro                = r[6500, 255].b7str
  usuario_atualizacao_id          = r[6756,  22].b7int
  usuario_atualizacao             = r[6779, 255].b7str

  if pessoa_id > 0 and
     nome_.length > 0 and
     sobrenome_.length > 0
    d<< sqlx % [ pessoa_id, email, email_local_, email_dominio_, nome, nome_, sobrenome_, data_nascimento, sexo, sexo_, pais_nacionalidade, pais_nacionalidade_, documento, documento_tipo, documento_tipo_id, lista_areas_ids, lista_areas, telefone1, telefone1_tipo, telefone1_tipo_id, telefone2, telefone2_tipo, telefone2_tipo_id, telefone3, telefone3_tipo, telefone3_tipo_id, endereco_residencial_logradouro, endereco_residencial_cidade_id, endereco_residencial_cidade, endereco_residencial_cep, endereco_residencial_bairro, empresa_id, empresa, cargo_id, cargo, cargo_descricao, endereco_comercial_logradouro, endereco_comercial_cidade_id, endereco_comercial_cidade, endereco_comercial_cep, endereco_comercial_bairro, data_cadastro, data_atualizacao, usuario_cadastro_id, usuario_cadastro, usuario_atualizacao_id, usuario_atualizacao ]

    lista_areas_ids_.each do |a|
      d<< sqla % [ pessoa_id, a ]
    end

    unless telefone1.empty?
      d<< sqlt % [ pessoa_id, telefone1_tipo_, telefone1 ]
    end
    unless telefone2.empty? 
      d<< sqlt % [ pessoa_id, telefone2_tipo_, telefone2 ]
    end
    unless telefone3.empty? 
      d<< sqlt % [ pessoa_id, telefone3_tipo_, telefone3 ]
    end

    unless endereco_residencial_logradouro.empty? or
           endereco_residencial_pais_.empty? or
           endereco_residencial_cidade_.empty?
      d<< sqle % [ pessoa_id, "home", endereco_residencial_logradouro, endereco_residencial_pais_, endereco_residencial_estado_, endereco_residencial_cidade_, endereco_residencial_cep, endereco_residencial_bairro ]
    end

    unless endereco_comercial_logradouro.empty? or
           endereco_comercial_pais_.empty? or
           endereco_comercial_cidade_.empty?
      d<< sqle % [ pessoa_id, "business", endereco_comercial_logradouro, endereco_comercial_pais_, endereco_comercial_estado_, endereco_comercial_cidade_, endereco_comercial_cep, endereco_comercial_bairro ]
    end
  end
end

puts
d[0, d.length - 1].each { |j| puts j }


# ------------------------------------------------------------------------------
# AREA DE ATUAÇÃO (EMPRESAS)
# ------------------------------------------------------------------------------

puts "DROP TABLE IF EXISTS b7migration_areas_pj;"
puts
puts "CREATE TABLE b7migration_areas_pj (area_id INT, area_hierarquia VARCHAR(255));"
puts
sqla="INSERT INTO b7migration_areas_pj VALUES (%d, \"%s\");"


f=File.new("05-site_areas_pj-clean.txt", "r")

d=Array.new
u=Array.new

f.each do |line|
  r = line.to_s.chop

  cd_entidade     = r[   0,  11].b7int
  area_id         = r[  12,  11].b7int
  area_hierarquia = r[  24, 255].b7str

  unless u.include?(area_id)
    u<< area_id
    d<< sqla % [ area_id, area_hierarquia ]
  end
end

puts
d[0, d.length - 1].each { |j| puts j }
puts


# ------------------------------------------------------------------------------
# EMPRESAS
# ------------------------------------------------------------------------------

puts "DROP TABLE IF EXISTS b7migration_empresas;"
puts
puts "CREATE TABLE b7migration_empresas (empresa_id INT, nome VARCHAR(255), cnpj VARCHAR(255), lista_areas_ids VARCHAR(255), lista_areas VARCHAR(255), endereco_logradouro VARCHAR(255), endereco_cidade_id INT, endereco_cidade VARCHAR(255), endereco_cep VARCHAR(255), endereco_bairro VARCHAR(255), telefone1 VARCHAR(255), telefone1_tipo VARCHAR(255), telefone1_tipo_id INT, telefone2 VARCHAR(255), telefone2_tipo VARCHAR(255), telefone2_tipo_id INT, telefone3 VARCHAR(255), telefone3_tipo VARCHAR(255), telefone3_tipo_id INT, data_cadastro VARCHAR(255), data_atualizacao VARCHAR(255), usuario_cadastro_id INT, usuario_cadastro VARCHAR(255), usuario_atualizacao_id INT, usuario_atualizacao VARCHAR(255));"
puts
sqlx="INSERT INTO b7migration_empresas VALUES (%d, \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", %d, \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", %d, \"%s\", \"%s\", %d, \"%s\", \"%s\", %d, \"%s\", \"%s\", %d, \"%s\", %d, \"%s\");"

puts "DROP TABLE IF EXISTS b7migration_empresas_areas;"
puts
puts "CREATE TABLE b7migration_empresas_areas (empresa_id INT, area_id INT);"
puts
sqla="INSERT INTO b7migration_empresas_areas VALUES (%d, %d);"


puts "DROP TABLE IF EXISTS b7migration_empresas_telefones;"
puts
puts "CREATE TABLE b7migration_empresas_telefones (empresa_id INT, telefone_tipo VARCHAR(255), telefone VARCHAR(255));"
puts
sqlt="INSERT INTO b7migration_empresas_telefones VALUES (%d, \"%s\", \"%s\");"


puts "DROP TABLE IF EXISTS b7migration_empresas_enderecos;"
puts
puts "CREATE TABLE b7migration_empresas_enderecos (empresa_id INT, tipo_ VARCHAR(50), logradouro VARCHAR(255), pais_ VARCHAR(2), estado_ VARCHAR(255), cidade_ VARCHAR(255), cep VARCHAR(255), bairro VARCHAR(255));"
puts
sqle="INSERT INTO b7migration_empresas_enderecos VALUES (%d, \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\");"


f=File.new("05-site_consulta_empresa-clean.txt", "r")

d=Array.new

f.each do |line|
  r = line.to_s.chop

  empresa_id             = r[   0,  11].b7int
  nome                   = r[  12, 255].b7str
  cnpj                   = r[ 268,  50].b7str
  lista_areas_ids        = r[ 319, 256].b7str
  lista_areas_ids_ = lista_areas_ids.split(',')
  lista_areas            = r[ 576, 256].b7str
  endereco_logradouro    = r[ 833, 256].b7str
  endereco_cidade_id     = r[1089,  18].b7int
  endereco_cidade        = r[1108, 255].b7str
  endereco_pais_, endereco_estado_, endereco_cidade_ = pais_estado_cidade(endereco_cidade)
  endereco_cep           = r[1364, 255].b7str
  endereco_bairro        = r[1620, 255].b7str
  telefone1              = r[1876, 255].b7str
  telefone1_tipo         = r[2132, 255].b7str
  telefone1_tipo_id      = r[2388,  17].b7int
  telefone1_tipo_ = B7_TELEFONE_TIPO[telefone1_tipo_id] || "phone_business"
  telefone2              = r[2406, 255].b7str
  telefone2_tipo         = r[2662, 255].b7str
  telefone2_tipo_id      = r[2918,  17].b7int
  telefone2_tipo_ = B7_TELEFONE_TIPO[telefone2_tipo_id] || "phone_business"
  telefone3              = r[2936, 255].b7str
  telefone3_tipo         = r[3192, 255].b7str
  telefone3_tipo_id      = r[3448,  17].b7int
  telefone3_tipo_ = B7_TELEFONE_TIPO[telefone3_tipo_id] || "phone_business"
  data_cadastro          = r[3466,  54].b7str
  data_atualizacao       = r[3521,  54].b7str
  usuario_cadastro_id    = r[3576,  19].b7int
  usuario_cadastro       = r[3596, 255].b7str
  usuario_atualizacao_id = r[3852,  22].b7int
  usuario_atualizacao    = r[3875, 255].b7str

  if empresa_id > 0 and
     nome.length > 0
    d<< sqlx % [ empresa_id, nome, cnpj, lista_areas_ids, lista_areas, endereco_logradouro, endereco_cidade_id, endereco_cidade, endereco_cep, endereco_bairro, telefone1, telefone1_tipo, telefone1_tipo_id, telefone2, telefone2_tipo, telefone2_tipo_id, telefone3, telefone3_tipo, telefone3_tipo_id, data_cadastro, data_atualizacao, usuario_cadastro_id, usuario_cadastro, usuario_atualizacao_id, usuario_atualizacao ]

    lista_areas_ids_.each do |a|
      d<< sqla % [ empresa_id, a ]
    end

    unless telefone1.empty?
      d<< sqlt % [ empresa_id, telefone1_tipo_, telefone1 ]
    end
    unless telefone2.empty? 
      d<< sqlt % [ empresa_id, telefone2_tipo_, telefone2 ]
    end
    unless telefone3.empty? 
      d<< sqlt % [ empresa_id, telefone3_tipo_, telefone3 ]
    end

    unless endereco_logradouro.empty? or
           endereco_pais_.empty? or
           endereco_cidade_.empty?
      d<< sqle % [ empresa_id, "office", endereco_logradouro, endereco_pais_, endereco_estado_, endereco_cidade_, endereco_cep, endereco_bairro ]
    end
  end
end

puts
d[0, d.length - 1].each { |j| puts j }


# ------------------------------------------------------------------------------

puts
puts "INSERT INTO individuals (id, name_first, name_last, birthdate, gender, citizenship_country, document, prefered_localization_context, prefered_phone, created_at, updated_at) SELECT pessoa_id, nome_, sobrenome_, data_nascimento, sexo_, pais_nacionalidade_, documento, NULL, NULL, data_cadastro, data_atualizacao FROM b7migration_pessoas ORDER BY pessoa_id;"

puts "INSERT INTO subscribers (id, individual_id, hash_id, email_local, email_domain, validated, unsubscribed, rejected, bounces, created_at, updated_at) SELECT pessoa_id, pessoa_id, SHA1(RAND() + pessoa_id), email_local_, email_dominio_, FALSE, FALSE, FALSE, 0, data_cadastro, data_atualizacao FROM b7migration_pessoas WHERE email IS NOT NULL AND email != '' ORDER BY pessoa_id;"

puts "DELETE FROM personal_activities;" 

puts "INSERT INTO personal_activities (id, name) SELECT area_id, area_hierarquia FROM b7migration_areas_pf ORDER BY area_id;"

puts "REPLACE INTO individual_activities (individual_id, personal_activity_id) SELECT pessoa_id, area_id FROM b7migration_pessoas_areas WHERE pessoa_id IN (SELECT id FROM individuals) AND area_id IN (SELECT id FROM personal_activities);"

puts "INSERT INTO individual_connections (individual_id, connection_type_id, position, value) SELECT pessoa_id, (SELECT id FROM connection_types WHERE name = telefone_tipo) AS connection_type_id, 1, telefone FROM b7migration_pessoas_telefones WHERE pessoa_id IN (SELECT id FROM individuals) AND (SELECT id FROM connection_types WHERE name = telefone_tipo) > 0 AND telefone IS NOT NULL AND telefone != '';";

puts "INSERT INTO localizations (id, country, state, city, district, code, address) SELECT (pessoa_id + 1000000) AS localization_id, pais_, estado_, cidade_, bairro, cep, logradouro FROM b7migration_pessoas_enderecos WHERE tipo_ = 'home' ORDER BY pessoa_id;";

puts "INSERT INTO localizations (id, country, state, city, district, code, address) SELECT (pessoa_id + 2000000) AS localization_id, pais_, estado_, cidade_, bairro, cep, logradouro FROM b7migration_pessoas_enderecos WHERE tipo_ = 'business' ORDER BY pessoa_id;";

puts "INSERT INTO individual_localizations (individual_id, localization_id, context) SELECT (id - 1000000) AS individual_id, id, 'home' FROM localizations WHERE id < 2000000 ORDER BY id;"

puts "INSERT INTO individual_localizations (individual_id, localization_id, context) SELECT (id - 2000000) AS individual_id, id, 'business' FROM localizations WHERE id > 2000000 ORDER BY id;"


# ------------------------------------------------------------------------------

puts

puts "ALTER TABLE organizations MODIFY COLUMN name VARCHAR(200) NOT NULL;"

puts "INSERT INTO organizations (id, name, document, created_at, updated_at) SELECT empresa_id, nome, cnpj, data_cadastro, data_atualizacao FROM b7migration_empresas ORDER BY empresa_id;"

puts "DELETE FROM business_activities;"

puts "INSERT INTO business_activities (id, name) SELECT area_id, area_hierarquia FROM b7migration_areas_pj ORDER BY area_id;";

puts "REPLACE INTO organization_activities (organization_id, business_activity_id) SELECT empresa_id, area_id FROM b7migration_empresas_areas WHERE empresa_id IN (SELECT id FROM organizations) AND area_id IN (SELECT id FROM business_activities);"

puts "INSERT INTO organization_connections (organization_id, connection_type_id, position, value) SELECT empresa_id, (SELECT id FROM connection_types WHERE name = telefone_tipo) AS connection_type_id, 1, telefone FROM b7migration_empresas_telefones WHERE empresa_id IN (SELECT id FROM organizations) AND (SELECT id FROM connection_types WHERE name = telefone_tipo) > 0 AND telefone IS NOT NULL AND telefone != '';";

puts "INSERT INTO localizations (id, country, state, city, district, code, address) SELECT (empresa_id + 3000000) AS localization_id, pais_, estado_, cidade_, bairro, cep, logradouro FROM b7migration_empresas_enderecos WHERE tipo_ = 'office' ORDER BY empresa_id;";

puts "INSERT INTO organization_localizations (organization_id, localization_id, context) SELECT (id - 3000000) AS organization_id, id, 'office' FROM localizations WHERE id > 3000000 ORDER BY id;"


# ------------------------------------------------------------------------------

##puts "INSERT INTO job_positions (name) SELECT DISTINCT(cargo) FROM b7migration_cargos ORDER BY cargo;"

##puts "INSERT INTO employments (individual_id, organization_id, job_position_id) SELECT pessoa_id, empresa_id, (SELECT id FROM job_positions WHERE name = cargo LIMIT 1) AS job_position_id FROM b7migration_pessoas WHERE pessoa_id IN (SELECT id FROM individuals) AND empresa_id IN (SELECT id FROM organizations) ORDER BY pessoa_id;";

puts "INSERT INTO employments (individual_id, organization_id, job_position) SELECT pessoa_id, empresa_id, (CASE WHEN cargo_descricao='' THEN cargo ELSE cargo_descricao END) cargo_ FROM b7migration_pessoas WHERE pessoa_id IN (SELECT id FROM individuals) AND empresa_id IN (SELECT id FROM organizations) ORDER BY pessoa_id;";
