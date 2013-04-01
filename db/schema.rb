# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100824001114) do

  create_table "acl_histories", :force => true do |t|
    t.integer   "acl_user_id",                               :null => false
    t.integer   "acl_role_id",                               :null => false
    t.string    "action",      :limit => 0,                  :null => false
    t.integer   "record_id",                  :default => 0, :null => false
    t.string    "message",     :limit => 200,                :null => false
    t.timestamp "created_at",                                :null => false
  end

  add_index "acl_histories", ["acl_role_id"], :name => "k_acl_history_role"
  add_index "acl_histories", ["acl_user_id"], :name => "k_acl_history_user"

  create_table "acl_permissions", :force => true do |t|
    t.integer "acl_user_id",                    :null => false
    t.integer "acl_role_id",                    :null => false
    t.boolean "writable",    :default => false, :null => false
  end

  add_index "acl_permissions", ["acl_role_id"], :name => "k_acl_permission_role"
  add_index "acl_permissions", ["acl_user_id", "acl_role_id"], :name => "u_acl_permission_user_role", :unique => true
  add_index "acl_permissions", ["acl_user_id"], :name => "k_acl_permission_user"

  create_table "acl_roles", :force => true do |t|
    t.string "name", :limit => 100, :null => false
  end

  create_table "acl_users", :force => true do |t|
    t.integer "individual_id"
    t.string  "username",      :limit => 100,                   :null => false
    t.string  "hash_password", :limit => 40,                    :null => false
    t.boolean "enabled",                      :default => true, :null => false
  end

  add_index "acl_users", ["individual_id"], :name => "k_acl_user_individual"
  add_index "acl_users", ["username", "hash_password"], :name => "k_acl_user_authentication", :length => {"hash_password"=>"4", "username"=>"4"}
  add_index "acl_users", ["username"], :name => "u_username", :unique => true

  create_table "business_activities", :force => true do |t|
    t.string "name", :limit => 100, :null => false
  end

  create_table "campaign_containers", :id => false, :force => true do |t|
    t.integer "campaign_id",  :null => false
    t.integer "container_id", :null => false
  end

  add_index "campaign_containers", ["campaign_id"], :name => "k_campaign_campaign_containers"
  add_index "campaign_containers", ["container_id"], :name => "k_container_campaign_containers"

  create_table "campaign_dispatches", :force => true do |t|
    t.integer   "subscriber_id",                                      :null => false
    t.integer   "campaign_job_id",                                    :null => false
    t.string    "status",          :limit => 0, :default => "unsent", :null => false
    t.integer   "pid",                          :default => 0,        :null => false
    t.timestamp "created_at",                                         :null => false
    t.timestamp "updated_at",                                         :null => false
  end

  add_index "campaign_dispatches", ["campaign_job_id"], :name => "k_campaign_dispatch_job"
  add_index "campaign_dispatches", ["pid"], :name => "k_campaign_dispatch_pid"
  add_index "campaign_dispatches", ["status"], :name => "k_campaign_dispatch_status"
  add_index "campaign_dispatches", ["subscriber_id"], :name => "k_campaign_dispatch_subscriber"

  create_table "campaign_jobs", :force => true do |t|
    t.integer   "campaign_id",                                   :null => false
    t.string    "subject",     :limit => 100,                    :null => false
    t.string    "status",      :limit => 0,   :default => "new", :null => false
    t.integer   "pid",                        :default => 0,     :null => false
    t.timestamp "scheduled"
    t.text      "template",                                      :null => false
    t.timestamp "created_at",                                    :null => false
    t.timestamp "updated_at",                                    :null => false
  end

  add_index "campaign_jobs", ["campaign_id"], :name => "k_campaign_job_campaign"
  add_index "campaign_jobs", ["scheduled"], :name => "k_campaign_job_scheduled"
  add_index "campaign_jobs", ["status"], :name => "k_campaign_job_status"

  create_table "campaign_templates", :force => true do |t|
    t.string "name", :limit => 100, :null => false
  end

  create_table "campaigns", :force => true do |t|
    t.string    "hash_id",              :limit => 40,                    :null => false
    t.integer   "campaign_template_id",                                  :null => false
    t.string    "name",                 :limit => 100,                   :null => false
    t.integer   "periodicity",                         :default => 0,    :null => false
    t.string    "content_title",        :limit => 200, :default => "",   :null => false
    t.text      "content_subtitle",                                      :null => false
    t.text      "content_body",                                          :null => false
    t.boolean   "enabled",                             :default => true, :null => false
    t.timestamp "created_at",                                            :null => false
    t.timestamp "updated_at",                                            :null => false
  end

  add_index "campaigns", ["campaign_template_id"], :name => "k_campaign_template"
  add_index "campaigns", ["enabled"], :name => "k_campaign_enabled"
  add_index "campaigns", ["periodicity"], :name => "k_campaign_periodicity"

  create_table "connection_types", :force => true do |t|
    t.string "name", :limit => 50, :null => false
  end

  create_table "container_types", :force => true do |t|
    t.string  "name",      :limit => 50,                    :null => false
    t.boolean "public",                  :default => false, :null => false
    t.boolean "removable",               :default => false, :null => false
  end

  add_index "container_types", ["public"], :name => "k_container_type_public"
  add_index "container_types", ["removable"], :name => "k_container_type_removable"

  create_table "containers", :force => true do |t|
    t.integer "container_type_id",                :null => false
    t.string  "hash_id",           :limit => 40,  :null => false
    t.string  "name",              :limit => 100, :null => false
  end

  add_index "containers", ["container_type_id"], :name => "k_container_container_type"
  add_index "containers", ["hash_id"], :name => "k_container_hash", :length => {"hash_id"=>"4"}
  add_index "containers", ["hash_id"], :name => "u_container_hash", :unique => true

  create_table "employments", :force => true do |t|
    t.integer "individual_id",   :null => false
    t.integer "organization_id", :null => false
    t.integer "job_position_id"
  end

  add_index "employments", ["individual_id"], :name => "k_employment_individual"
  add_index "employments", ["individual_id"], :name => "u_employment_individual", :unique => true
  add_index "employments", ["job_position_id"], :name => "k_employment_job_position"
  add_index "employments", ["organization_id"], :name => "k_employment_organization"

  create_table "event_subscribers", :force => true do |t|
    t.integer   "event_id",      :null => false
    t.integer   "subscriber_id", :null => false
    t.text      "data",          :null => false
    t.timestamp "created_at",    :null => false
    t.timestamp "updated_at",    :null => false
  end

  add_index "event_subscribers", ["created_at"], :name => "k_event_subscriber_created_at"
  add_index "event_subscribers", ["event_id"], :name => "k_event_subscriber_event"
  add_index "event_subscribers", ["subscriber_id"], :name => "k_event_subscriber_subscriber"

  create_table "events", :force => true do |t|
    t.string    "hash_id",      :limit => 40,                     :null => false
    t.integer   "container_id",                                   :null => false
    t.string    "name",         :limit => 100,                    :null => false
    t.string    "permalink",    :limit => 100,                    :null => false
    t.string    "tagline",      :limit => 200
    t.text      "description"
    t.boolean   "subscribing",                 :default => false, :null => false
    t.timestamp "created_at",                                     :null => false
    t.timestamp "updated_at",                                     :null => false
  end

  add_index "events", ["container_id"], :name => "k_event_container"
  add_index "events", ["container_id"], :name => "u_event_container", :unique => true
  add_index "events", ["permalink"], :name => "k_event_permalink", :length => {"permalink"=>"4"}
  add_index "events", ["permalink"], :name => "u_event_permalink", :unique => true

  create_table "individual_activities", :id => false, :force => true do |t|
    t.integer "individual_id",        :null => false
    t.integer "personal_activity_id", :null => false
  end

  add_index "individual_activities", ["individual_id", "personal_activity_id"], :name => "u_individual_activity", :unique => true
  add_index "individual_activities", ["individual_id"], :name => "k_individual_activity_individual"
  add_index "individual_activities", ["personal_activity_id"], :name => "k_individual_activity_personal_activity"

  create_table "individual_connections", :force => true do |t|
    t.integer "individual_id",                     :null => false
    t.integer "connection_type_id",                :null => false
    t.integer "position",                          :null => false
    t.string  "value",              :limit => 200, :null => false
  end

  add_index "individual_connections", ["connection_type_id"], :name => "k_individual_connection_type"
  add_index "individual_connections", ["individual_id"], :name => "k_individual_connection_individual"

  create_table "individual_containers", :id => false, :force => true do |t|
    t.integer "individual_id", :null => false
    t.integer "container_id",  :null => false
  end

  add_index "individual_containers", ["container_id"], :name => "k_individual_container_container"
  add_index "individual_containers", ["individual_id"], :name => "k_individual_container_individual"

  create_table "individual_localizations", :force => true do |t|
    t.integer "individual_id",                :null => false
    t.integer "localization_id",              :null => false
    t.string  "context",         :limit => 0, :null => false
  end

  add_index "individual_localizations", ["context", "individual_id"], :name => "u_individual_localization_individual_context"
  add_index "individual_localizations", ["individual_id"], :name => "k_individual_localization_individual"
  add_index "individual_localizations", ["localization_id"], :name => "k_individual_localization_localization"

  create_table "individuals", :force => true do |t|
    t.string    "name_first",                    :limit => 50, :null => false
    t.string    "name_last",                     :limit => 50, :null => false
    t.date      "birthdate"
    t.string    "gender",                        :limit => 0
    t.string    "citizenship_country",           :limit => 2
    t.string    "document",                      :limit => 50
    t.string    "prefered_localization_context", :limit => 0
    t.string    "prefered_phone",                :limit => 50
    t.timestamp "created_at",                                  :null => false
    t.timestamp "updated_at",                                  :null => false
  end

  add_index "individuals", ["name_first", "name_last"], :name => "individual_name", :length => {"name_last"=>"8", "name_first"=>"4"}

  create_table "job_positions", :force => true do |t|
    t.string "name", :limit => 100, :null => false
  end

  create_table "localizations", :force => true do |t|
    t.string "country",  :limit => 2,   :null => false
    t.string "state",    :limit => 100
    t.string "city",     :limit => 100, :null => false
    t.string "district", :limit => 100
    t.string "code",     :limit => 50
    t.string "address",  :limit => 200, :null => false
  end

  create_table "organization_activities", :id => false, :force => true do |t|
    t.integer "organization_id",      :null => false
    t.integer "business_activity_id", :null => false
  end

  add_index "organization_activities", ["business_activity_id"], :name => "k_organization_activity_business_activity"
  add_index "organization_activities", ["organization_id"], :name => "k_organization_activity_organization"

  create_table "organization_connections", :force => true do |t|
    t.integer "organization_id",                   :null => false
    t.integer "connection_type_id",                :null => false
    t.integer "position",                          :null => false
    t.string  "value",              :limit => 200, :null => false
  end

  add_index "organization_connections", ["connection_type_id"], :name => "k_organization_connection_type"
  add_index "organization_connections", ["organization_id"], :name => "k_organization_connection_organization"

  create_table "organization_localizations", :force => true do |t|
    t.integer "localization_id",              :null => false
    t.integer "organization_id",              :null => false
    t.string  "context",         :limit => 0, :null => false
  end

  add_index "organization_localizations", ["localization_id"], :name => "k_organization_localization_localization"
  add_index "organization_localizations", ["organization_id", "context"], :name => "u_organization_localization_organization_context", :unique => true
  add_index "organization_localizations", ["organization_id"], :name => "k_organization_localizations_organization"

  create_table "organizations", :force => true do |t|
    t.string    "name",       :limit => 100, :null => false
    t.string    "document",   :limit => 50
    t.timestamp "created_at",                :null => false
    t.timestamp "updated_at",                :null => false
  end

  add_index "organizations", ["name"], :name => "k_organization_name", :length => {"name"=>"6"}

  create_table "personal_activities", :force => true do |t|
    t.string "name", :limit => 100, :null => false
  end

  create_table "printable_containers", :id => false, :force => true do |t|
    t.integer "printable_id", :null => false
    t.integer "container_id", :null => false
  end

  add_index "printable_containers", ["container_id"], :name => "k_printable_container_container"
  add_index "printable_containers", ["printable_id"], :name => "k_printable_container_printable"

  create_table "printable_dispatches", :force => true do |t|
    t.integer "printable_job_id",                    :null => false
    t.integer "individual_id",                       :null => false
    t.boolean "accomplished",     :default => false, :null => false
  end

  add_index "printable_dispatches", ["individual_id"], :name => "k_printable_dispatch_individual"
  add_index "printable_dispatches", ["printable_job_id", "individual_id"], :name => "u_printable_dispatch_job_individual", :unique => true
  add_index "printable_dispatches", ["printable_job_id"], :name => "k_printable_dispatch_job"

  create_table "printable_jobs", :force => true do |t|
    t.integer   "printable_id", :null => false
    t.timestamp "created_at",   :null => false
  end

  add_index "printable_jobs", ["printable_id"], :name => "k_printable_job_printable"

  create_table "printable_templates", :force => true do |t|
    t.string "name", :limit => 100, :null => false
  end

  create_table "printables", :force => true do |t|
    t.integer   "printable_template_id",                :null => false
    t.string    "name",                  :limit => 100, :null => false
    t.timestamp "created_at",                           :null => false
    t.timestamp "updated_at",                           :null => false
  end

  add_index "printables", ["printable_template_id"], :name => "k_printable_template"

  create_table "subscribers", :force => true do |t|
    t.integer   "individual_id",                                  :null => false
    t.string    "hash_id",       :limit => 40,                    :null => false
    t.string    "email_local",   :limit => 50,                    :null => false
    t.string    "email_domain",  :limit => 50,                    :null => false
    t.boolean   "validated",                   :default => false, :null => false
    t.boolean   "unsubscribed",                :default => false, :null => false
    t.boolean   "rejected",                    :default => false, :null => false
    t.integer   "bounces",                     :default => 0,     :null => false
    t.timestamp "created_at",                                     :null => false
    t.timestamp "updated_at",                                     :null => false
  end

  add_index "subscribers", ["email_local", "email_domain"], :name => "k_subscriber_email", :length => {"email_domain"=>"4", "email_local"=>"4"}
  add_index "subscribers", ["email_local", "email_domain"], :name => "u_subscriber_email", :unique => true
  add_index "subscribers", ["hash_id"], :name => "k_subscriber_hash", :length => {"hash_id"=>"4"}
  add_index "subscribers", ["hash_id"], :name => "u_subscriber_hash", :unique => true
  add_index "subscribers", ["individual_id"], :name => "k_subscriber_individual"

end
