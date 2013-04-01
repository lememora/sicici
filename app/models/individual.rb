class Individual < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  GENDER_MALE = 'male'
  GENDER_FEMALE = 'female'

  has_one :acl_user
  has_one :employment
  has_one :subscriber
  has_many :individual_connections, :order => :position
  has_many :individual_localizations
  has_many :printable_dispatches
  has_and_belongs_to_many :containers, :join_table => "individual_containers"
  has_and_belongs_to_many :personal_activities, :join_table => "individual_activities"

  validates_presence_of :name_first
  validates_presence_of :name_last
  validates_inclusion_of :gender, 
    :in => [ GENDER_MALE, GENDER_FEMALE ], 
    :allow_blank => true,
    :allow_nil => true
  validates_inclusion_of :prefered_localization_context, 
    :in => [ Localization::CONTEXT_HOME, 
             Localization::CONTEXT_BUSINESS,
             Localization::CONTEXT_OFFICE ],
    :allow_blank => true,
    :allow_nil => true
  validates_inclusion_of :citizenship_country,
    :in => Country.keys,
    :allow_blank => true,
    :allow_nil => true

  def to_s
    "##{self.id} #{self.name}"
  end

  def name=(name)
    self.name_first, self.name_last = name.split(" ", 2)
  end

  def name
    [ name_first, name_last ].join(" ")
  end

  def to_json(options={})
    self.hashmap.to_json(options)
  end

  def hashmap
    map = HashWithIndifferentAccess.new
    map["individual"] = self.attributes
    map["individual"]["name"] = self.name
    map["individual_birthdate"] = FormatHelper.date(self.birthdate, false)
    map["individual_birthdate_y"] = self.birthdate ? self.birthdate.year : nil
    map["individual_birthdate_m"] = self.birthdate ? self.birthdate.month : nil
    map["individual_birthdate_d"] = self.birthdate ? self.birthdate.day : nil
    map["individual"]["created_at"] = FormatHelper.date_time(self.created_at)
    map["individual"]["updated_at"] = FormatHelper.date_time(self.updated_at)
    map["individual_gender"] = FormatHelper.gender(self.gender)
    map["individual_citizenship_country"] = Country.find_by_id(self.citizenship_country)
    personal_activity_id_array = self.personal_activities.map { |v| v.id }
    map["personal_activity"] = personal_activity_id_array.first
    map["personal_activities"] = personal_activity_id_array 
    personal_activity_name_array = self.personal_activities.map { |v| v.name }
    map["personal_activity_name"] = personal_activity_name_array.first
    map["personal_activity_name_array"] = personal_activity_name_array
    map["personal_activity_names"] = personal_activity_name_array.join(",")
    map["individual_connections"] = Hash.new
    ConnectionType::PHONES.each do |phone|
      map["individual_connections"][phone] = nil
    end
    self.individual_connections.each do |v|
      map["individual_connections"][v.connection_type.name] = v.value
    end
    map["individual_localizations"] = Hash.new
    IndividualLocalization::CONTEXT_ARRAY.each do |j|
      map["individual_localizations"][j] = Hash.new
    end
    self.individual_localizations.each do |v|
      map["individual_localizations"][v.context] = v.localization.hashmap
    end
    map["containers"] = self.containers.map { |v| v.hash_id }
    map["container_names"] = self.containers.map { |v| v.name }.join(",")
    map["job_position"] = nil
    map["job_position_name"] = nil
    unless self.employment.nil?
      job_position = self.employment.job_position
      unless job_position.nil?
        #map["job_position"] = job_position.id
        #map["job_position_name"] = job_position.name
        map["job_position"] = job_position
        map["job_position_name"] = job_position
      end
    end
    map
  end

  def populate(data)
    self.attributes = data["individual"]
    data["individual_gender"] = GENDER_MALE if data["individual_gender"]=="m"
    data["individual_gender"] = GENDER_FEMALE if data["individual_gender"]=="f"
    self.gender = data["individual_gender"] if data["individual_gender"]
    bdy = data["individual_birthdate_y"].to_i
    bdm = data["individual_birthdate_m"].to_i
    bdd = data["individual_birthdate_d"].to_i
    if Date.valid_civil?(bdy, bdm, bdd)
      self.birthdate = Date.parse("#{bdy}-#{bdm}-#{bdd}")
    end

    citizenship = data["individual"]["citizenship_country"] rescue nil
    country_id = citizenship ? Country.find_by_name(citizenship) : nil
    self.citizenship_country = country_id unless country_id.nil?

    if data["individual_prefered_phone"]
      self.prefered_phone = data["individual_connections"][(data["individual_prefered_phone"])]
    end

    personal_activity_names = data["personal_activity_names"] || []
    self.personal_activities.clear if personal_activity_names.length > 0
    personal_activity_names.each do |j|
      activity = PersonalActivity.find_by_name(j)
      self.personal_activities << activity if activity
    end

    personal_activity_ids = (data["personal_activities"] || {}).values
    self.personal_activity_ids = personal_activity_ids if personal_activity_ids.length > 0

    if data["personal_activity"].to_i > 0
      self.personal_activity_ids = [ data["personal_activity"] ]
    end

    unless data["personal_activity"].to_s.empty?
      if data["personal_activity"].to_s.match(/^[0-9]+$/)
        self.personal_activity_ids = [ data["personal_activity"] ]
      else
        j = PersonalActivity.find_by_name(data["personal_activity"])
        ##self.personal_activity_ids = j.id unless j.nil?
      end
    end

    (data["individual_connections"] || {}).each do |k,v|
      if (t = ConnectionType.find_by_name(k))
        c = self.individual_connections.find_by_connection_type_id(t.id)
        c.destroy unless c.nil?
        if not v.to_s.empty?
          self.individual_connections.build(
            :connection_type => t,
            :value => v)
        end
      end
    end

    (data["individual_localizations"] || {}).each do |k,v|
      c = k.to_s
      if (d = self.individual_localizations.find_by_context(c))
        a = d.localization
        d.destroy
        a.destroy unless a.nil?
      end
      a = Localization.new
      a.populate(v)
      if a.valid? and not c.empty?
        self.individual_localizations.build(
          :localization => a,
          :context => c)
      end
    end

    self.containers.clear
    (data["containers"] || []).each do |v|
      container = Container.find_by_hash_id(v)
      self.containers << container unless container.nil?
    end
  end

  def self.find_by_name(name)
    name_first, name_last = name.split(" ", 2)
    self.first(:conditions => { :name_first => name_first, :name_last => name_last })
  end
end
