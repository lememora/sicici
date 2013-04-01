# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

ConnectionType.create(:name => ConnectionType::EMAIL)
ConnectionType.create(:name => ConnectionType::PHONE_HOME)
ConnectionType.create(:name => ConnectionType::PHONE_BUSINESS)
ConnectionType.create(:name => ConnectionType::PHONE_MOBILE)
ConnectionType.create(:name => ConnectionType::PHONE_FAX)
ConnectionType.create(:name => ConnectionType::FAX_ONLY)
ConnectionType.create(:name => ConnectionType::MSN)
ConnectionType.create(:name => ConnectionType::SKYPE)
ConnectionType.create(:name => ConnectionType::GOOGLE_TALK)
ConnectionType.create(:name => ConnectionType::ICQ)
ConnectionType.create(:name => ConnectionType::WEBSITE)
ConnectionType.create(:name => ConnectionType::FACEBOOK)
ConnectionType.create(:name => ConnectionType::LINKEDIN)
ConnectionType.create(:name => ConnectionType::TWITTER)

# should be overwriten by data migration
PersonalActivity.create(:name => "Advogado")
PersonalActivity.create(:name => "Arquiteto")
PersonalActivity.create(:name => "Cientista")
PersonalActivity.create(:name => "Engenheiro")
PersonalActivity.create(:name => "Estudante")
PersonalActivity.create(:name => "Geógrafo")
PersonalActivity.create(:name => "Matemático")
PersonalActivity.create(:name => "Mecânico")
PersonalActivity.create(:name => "Músico")
PersonalActivity.create(:name => "Nutricionista")
PersonalActivity.create(:name => "Publicitário")
PersonalActivity.create(:name => "Terapeuta")

# should be overwriten by data migration
BusinessActivity.create(:name => "Administração")
BusinessActivity.create(:name => "Advocacia")
BusinessActivity.create(:name => "Arquitetura")
BusinessActivity.create(:name => "Comércio")
BusinessActivity.create(:name => "Ensino")
BusinessActivity.create(:name => "Indústria")

ContainerType.create(:name => ContainerType::PRIVATE, 
  :public => false, :removable => true)
ContainerType.create(:name => ContainerType::PUBLIC, 
  :public => true, :removable => true)
ContainerType.create(:name => ContainerType::EVENT, 
  :public => false, :removable => false)
ContainerType.create(:name => ContainerType::TEMPORARY_FAILURE, 
  :public => false, :removable => false)
ContainerType.create(:name => ContainerType::PERMANENT_FAILURE, 
  :public => false, :removable => false)

container_type_public = ContainerType.find_by_name(ContainerType::PUBLIC)

Container.create(:name => "Geral",
                 :container_type => container_type_public)
Container.create(:name => "Notícias",
                 :container_type => container_type_public)
Container.create(:name => "Programação",
                 :container_type => container_type_public)

CampaignTemplate.create(:name => "Programação do mês")
CampaignTemplate.create(:name => "Eventos em destaque")
CampaignTemplate.create(:name => "Novidades midiateca")
CampaignTemplate.create(:name => "Comunicado")
CampaignTemplate.create(:name => "CCE Convida")
CampaignTemplate.create(:name => "Atualizações da semana")

PrintableTemplate.create(:name => "Lista de pessoas")
PrintableTemplate.create(:name => "Crachá Pimaco 6095")
PrintableTemplate.create(:name => "Correspondência Pimaco 6082")

auth_role = AclRole.create(:name => AclRole::AUTHENTICATION)
AclRole.create(:name => AclRole::CONTACT)
AclRole.create(:name => AclRole::ORGANIZATION)
AclRole.create(:name => AclRole::CONTAINER)
AclRole.create(:name => AclRole::PERSONAL_ACTIVITY)
AclRole.create(:name => AclRole::BUSINESS_ACTIVITY)
AclRole.create(:name => AclRole::EVENT)
AclRole.create(:name => AclRole::CAMPAIGN)
AclRole.create(:name => AclRole::CAMPAIGN_JOB)
AclRole.create(:name => AclRole::PRINTABLE)
AclRole.create(:name => AclRole::PRINTABLE_JOB)
AclRole.create(:name => AclRole::USER)
AclRole.create(:name => AclRole::HISTORY)


service_user = AclUser.create(:username => "ccebrasil",
               :hash_password => "dc5bc6060d0f16b962a5996e0a32ae9d1874e231",
               :enabled => true)

AclPermission.create(:acl_user => service_user, :acl_role => auth_role, :writable => true)


## development users ##
if ENV["RAILS_ENV"] = "development"
  { "castilho"   => "8d9a74c710d376aff07c8ff5d732e0cb68974a31",
    "bardella"   => "995cef71d58e1c9e7336722f3f1018e9b13d1023",
    "agomes"     => "a872cbf134d610bf962b4cbd22da6bad31538dba",
    "eva"        => "9355aa235f1e83e4c4b14c020f5b9545cd9aa58a",
    "vania"      => "48468ab3513e5e5da5b8406ca002e2a7370992c0",
    "alessandra" => "89299d1ce8afa07b0460f2d4fe1ecbb29c90b9eb",
    "luiz"       => "efda7955fc063e1169cf0510d5a3d950210ce486",
    "daniel"     => "de64f3c9f272b4e4527f9491e5cb3225706f0953",
    "fb"         => "f2acb5f11d03187c4cd2cc9c82b8936f7d54286f" }.each do |u,h|
    acl_user = AclUser.create(:username => u, :hash_password => h, :enabled => true)
    AclRole.all.each do |r|
      AclPermission.create(:acl_user => acl_user, :acl_role => r, :writable => true)
    end
  end
end

if ENV["RAILS_ENV"] = "production"
  AclUser.create(:username => "admin", 
                 :hash_password => "admin", 
                 :enabled => true)
end
