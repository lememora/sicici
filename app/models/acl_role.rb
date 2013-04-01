class AclRole < ActiveRecord::Base
  AUTHENTICATION    = "Autenticação"
  CONTACT           = "Contatos"
  ORGANIZATION      = "Empresas"
  CONTAINER         = "Contâineres"
  PERSONAL_ACTIVITY = "Atuação (PF)"
  BUSINESS_ACTIVITY = "Atuação (PJ)"
  EVENT             = "Eventos"
  CAMPAIGN          = "Campanhas"
  CAMPAIGN_JOB      = "Disparo de Campanhas"
  PRINTABLE         = "Impressões"
  PRINTABLE_JOB     = "Compilador de Impressões"
  USER              = "Usuários"
  HISTORY           = "Históricos"

  SECTIONS = {
    CONTACT           => "contact",
    ORGANIZATION      => "organization",
    CONTAINER         => "container",
    PERSONAL_ACTIVITY => "personal_activity",
    BUSINESS_ACTIVITY => "business_activity",
    EVENT             => "eventz",
    CAMPAIGN          => "campaign",
    CAMPAIGN_JOB      => "campaign_job",
    PRINTABLE         => "printable",
    PRINTABLE_JOB     => "printable_job",
    USER              => "user",
    HISTORY           => "history" }


  has_many :acl_histories
  has_many :acl_permissions
  has_many :acl_users, :through => :acl_permissions

  validates_presence_of :name
  validates_uniqueness_of :name
end
