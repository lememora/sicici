class ConnectionType < ActiveRecord::Base
  EMAIL          = "email"
  PHONE_HOME     = "phone_home"
  PHONE_BUSINESS = "phone_business"
  PHONE_MOBILE   = "phone_mobile"
  PHONE_FAX      = "phone_fax"
  FAX_ONLY       = "fax_only"
  MSN            = "msn"
  SKYPE          = "skype"
  GOOGLE_TALK    = "google_talk"
  ICQ            = "icq"
  WEBSITE        = "website"
  FACEBOOK       = "facebook"
  LINKEDIN       = "linkedin"
  TWITTER        = "twitter"

  PHONES = [ PHONE_HOME, PHONE_BUSINESS, PHONE_MOBILE, PHONE_FAX ]

  has_many :individual_connections
  has_many :organization_connections

  validates_presence_of :name
  validates_uniqueness_of :name
end
