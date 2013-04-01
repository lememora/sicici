class Database < ActiveRecord::Migration
  def self.up
    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `individuals` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `name_first` VARCHAR(50) NOT NULL ,
  `name_last` VARCHAR(50) NOT NULL ,
  `birthdate` DATE NULL ,
  `gender` ENUM('male','female') NULL ,
  `citizenship_country` VARCHAR(2) NULL ,
  `document` VARCHAR(50) NULL ,
  `prefered_localization_context` ENUM('home','business','office') NULL ,
  `prefered_phone` VARCHAR(50) NULL ,
  `description` TEXT NOT NULL DEFAULT '' ,
  `created_at` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' ,
  `updated_at` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' ,
  PRIMARY KEY (`id`) ,
  INDEX `individual_name` (`name_first`(4) ASC, `name_last`(8) ASC) )
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `subscribers` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `individual_id` INT UNSIGNED NOT NULL ,
  `hash_id` VARCHAR(40) NOT NULL ,
  `email_local` VARCHAR(50) NOT NULL ,
  `email_domain` VARCHAR(50) NOT NULL ,
  `validated` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 ,
  `unsubscribed` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 ,
  `rejected` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 ,
  `bounces` INT UNSIGNED NOT NULL DEFAULT 0 ,
  `created_at` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' ,
  `updated_at` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' ,
  PRIMARY KEY (`id`) ,
  UNIQUE INDEX `u_subscriber_email` (`email_local` ASC, `email_domain` ASC) ,
  INDEX `k_subscriber_hash` (`hash_id`(4) ASC) ,
  UNIQUE INDEX `u_subscriber_hash` (`hash_id` ASC) ,
  INDEX `k_subscriber_email` (`email_local`(4) ASC, `email_domain`(4) ASC) ,
  INDEX `k_subscriber_individual` (`individual_id` ASC) ,
  CONSTRAINT `f_subscriber_individual`
    FOREIGN KEY (`individual_id` )
    REFERENCES `individuals` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `container_types` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(50) NOT NULL ,
  `public` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 ,
  `removable` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 ,
  PRIMARY KEY (`id`) ,
  INDEX `k_container_type_public` (`public` ASC) ,
  INDEX `k_container_type_removable` (`removable` ASC) )
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `containers` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `container_type_id` INT UNSIGNED NOT NULL ,
  `hash_id` VARCHAR(40) NOT NULL ,
  `name` VARCHAR(100) NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `k_container_hash` (`hash_id`(4) ASC) ,
  UNIQUE INDEX `u_container_hash` (`hash_id` ASC) ,
  INDEX `k_container_container_type` (`container_type_id` ASC) ,
  CONSTRAINT `f_container_container_type`
    FOREIGN KEY (`container_type_id` )
    REFERENCES `container_types` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `events` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `hash_id` VARCHAR(40) NOT NULL ,
  `container_id` INT UNSIGNED NOT NULL ,
  `name` VARCHAR(100) NOT NULL ,
  `permalink` VARCHAR(100) NOT NULL ,
  `tagline` VARCHAR(200) NULL ,
  `description` TEXT NULL ,
  `subscribing` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 ,
  `created_at` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' ,
  `updated_at` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' ,
  PRIMARY KEY (`id`) ,
  INDEX `k_event_container` (`container_id` ASC) ,
  UNIQUE INDEX `u_event_container` (`container_id` ASC) ,
  INDEX `k_event_permalink` (`permalink`(4) ASC) ,
  UNIQUE INDEX `u_event_permalink` (`permalink` ASC) ,
  CONSTRAINT `f_event_container`
    FOREIGN KEY (`container_id` )
    REFERENCES `containers` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `campaign_templates` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(100) NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `campaigns` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `hash_id` VARCHAR(40) NOT NULL ,
  `campaign_template_id` INT UNSIGNED NOT NULL ,
  `name` VARCHAR(100) NOT NULL ,
  `periodicity` INT UNSIGNED NOT NULL DEFAULT 0 ,
  `content_title` VARCHAR(200) NOT NULL DEFAULT '',
  `content_subtitle` TEXT NOT NULL DEFAULT '' ,
  `content_body` TEXT NOT NULL DEFAULT '' ,
  `enabled` TINYINT(1) NOT NULL DEFAULT '1' ,
  `deleted` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 ,
  `created_at` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' ,
  `updated_at` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' ,
  PRIMARY KEY (`id`) ,
  INDEX `k_campaign_template` (`campaign_template_id` ASC) ,
  INDEX `k_campaign_periodicity` (`periodicity` ASC) ,
  INDEX `k_campaign_enabled` (`enabled` ASC) ,
  CONSTRAINT `f_campaign_jobs_campaign_template`
    FOREIGN KEY (`campaign_template_id` )
    REFERENCES `campaign_templates` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `printable_templates` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(100) NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `printables` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `printable_template_id` INT UNSIGNED NOT NULL ,
  `name` VARCHAR(100) NOT NULL ,
  `created_at` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' ,
  `updated_at` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' ,
  PRIMARY KEY (`id`) ,
  INDEX `k_printable_template` (`printable_template_id` ASC) ,
  CONSTRAINT `f_printables_printable_template`
    FOREIGN KEY (`printable_template_id` )
    REFERENCES `printable_templates` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `acl_users` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `individual_id` INT UNSIGNED NULL ,
  `username` VARCHAR(100) NOT NULL ,
  `hash_password` VARCHAR(40) NOT NULL ,
  `enabled` TINYINT(1) UNSIGNED NOT NULL DEFAULT 1 ,
  PRIMARY KEY (`id`) ,
  INDEX `k_acl_user_authentication` (`username`(4) ASC, `hash_password`(4) ASC) ,
  UNIQUE INDEX `u_username` (`username` ASC) ,
  INDEX `k_acl_user_individual` (`individual_id` ASC) ,
  CONSTRAINT `f_acl_user_individual`
    FOREIGN KEY (`individual_id` )
    REFERENCES `individuals` (`id` )
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `acl_roles` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(100) NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `acl_permissions` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `acl_user_id` INT UNSIGNED NOT NULL ,
  `acl_role_id` INT UNSIGNED NOT NULL ,
  `writable` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 ,
  PRIMARY KEY (`id`) ,
  INDEX `k_acl_permission_role` (`acl_role_id` ASC) ,
  INDEX `k_acl_permission_user` (`acl_user_id` ASC) ,
  UNIQUE INDEX `u_acl_permission_user_role` (`acl_user_id` ASC, `acl_role_id` ASC) ,
  CONSTRAINT `f_acl_permissions_role`
    FOREIGN KEY (`acl_role_id` )
    REFERENCES `acl_roles` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `f_acl_permissions_user`
    FOREIGN KEY (`acl_user_id` )
    REFERENCES `acl_users` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `campaign_containers` (
  `campaign_id` INT UNSIGNED NOT NULL ,
  `container_id` INT UNSIGNED NOT NULL ,
  PRIMARY KEY (`campaign_id`, `container_id`) ,
  INDEX `k_campaign_campaign_containers` (`campaign_id` ASC) ,
  INDEX `k_container_campaign_containers` (`container_id` ASC) ,
  CONSTRAINT `f_campaign_campaigns_containers`
    FOREIGN KEY (`campaign_id` )
    REFERENCES `campaigns` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `f_container_campaigns_containers`
    FOREIGN KEY (`container_id` )
    REFERENCES `containers` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `campaign_jobs` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `campaign_id` INT UNSIGNED NOT NULL ,
  `subject` VARCHAR(100) NOT NULL ,
  `status` ENUM('new','running','stopped', 'finished') NOT NULL DEFAULT 'new' ,
  `pid` INT NOT NULL DEFAULT 0 ,
  `scheduled` TIMESTAMP NULL ,
  `template` TEXT NOT NULL DEFAULT '' ,
  `created_at` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' ,
  `updated_at` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' ,
  PRIMARY KEY (`id`) ,
  INDEX `k_campaign_job_campaign` (`campaign_id` ASC) ,
  INDEX `k_campaign_job_status` (`status` ASC) ,
  INDEX `k_campaign_job_scheduled` (`scheduled` ASC) ,
  CONSTRAINT `f_campaign_jobs_campaign`
    FOREIGN KEY (`campaign_id` )
    REFERENCES `campaigns` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `campaign_dispatches` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `subscriber_id` INT UNSIGNED NOT NULL ,
  `campaign_job_id` INT UNSIGNED NOT NULL ,
  `status` ENUM('unsent', 'sent', 'bounced', 'rejected', 'failed') NOT NULL DEFAULT 'unsent' ,
  `pid` INT UNSIGNED NOT NULL DEFAULT 0 ,
  `created_at` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' ,
  `updated_at` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' ,
  PRIMARY KEY (`id`) ,
  INDEX `k_campaign_dispatch_job` (`campaign_job_id` ASC) ,
  INDEX `k_campaign_dispatch_subscriber` (`subscriber_id` ASC) ,
  INDEX `k_campaign_dispatch_status` (`status` ASC) ,
  INDEX `k_campaign_dispatch_pid` (`pid` ASC) ,
  CONSTRAINT `f_campaign_dispatches_campaign_job`
    FOREIGN KEY (`campaign_job_id` )
    REFERENCES `campaign_jobs` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `f_campaign_dispatches_subscriber`
    FOREIGN KEY (`subscriber_id` )
    REFERENCES `subscribers` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `printable_containers` (
  `printable_id` INT UNSIGNED NOT NULL ,
  `container_id` INT UNSIGNED NOT NULL ,
  PRIMARY KEY (`printable_id`, `container_id`) ,
  INDEX `k_printable_container_printable` (`printable_id` ASC) ,
  INDEX `k_printable_container_container` (`container_id` ASC) ,
  CONSTRAINT `f_printable_containers_printable`
    FOREIGN KEY (`printable_id` )
    REFERENCES `printables` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `f_printable_containers_container`
    FOREIGN KEY (`container_id` )
    REFERENCES `containers` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `printable_jobs` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `printable_id` INT UNSIGNED NOT NULL ,
  `created_at` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' ,
  PRIMARY KEY (`id`) ,
  INDEX `k_printable_job_printable` (`printable_id` ASC) ,
  CONSTRAINT `f_printable_jobs_printable`
    FOREIGN KEY (`printable_id` )
    REFERENCES `printables` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `organizations` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(100) NOT NULL ,
  `document` VARCHAR(50) NULL ,
  `description` TEXT NOT NULL DEFAULT '' ,
  `created_at` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' ,
  `updated_at` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' ,
  PRIMARY KEY (`id`) ,
  INDEX `k_organization_name` (`name`(6) ASC) )
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `connection_types` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(50) NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `organization_connections` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `organization_id` INT UNSIGNED NOT NULL ,
  `connection_type_id` INT UNSIGNED NOT NULL ,
  `position` INT UNSIGNED NOT NULL ,
  `value` VARCHAR(200) NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `k_organization_connection_organization` (`organization_id` ASC) ,
  INDEX `k_organization_connection_type` (`connection_type_id` ASC) ,
  CONSTRAINT `f_organization_connections_organization`
    FOREIGN KEY (`organization_id` )
    REFERENCES `organizations` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `f_organization_connections_connection_type`
    FOREIGN KEY (`connection_type_id` )
    REFERENCES `connection_types` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `individual_connections` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `individual_id` INT UNSIGNED NOT NULL ,
  `connection_type_id` INT UNSIGNED NOT NULL ,
  `position` INT UNSIGNED NOT NULL ,
  `value` VARCHAR(200) NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `k_individual_connection_individual` (`individual_id` ASC) ,
  INDEX `k_individual_connection_type` (`connection_type_id` ASC) ,
  CONSTRAINT `f_individual_connections_individual`
    FOREIGN KEY (`individual_id` )
    REFERENCES `individuals` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `f_individual_connections_connection_type`
    FOREIGN KEY (`connection_type_id` )
    REFERENCES `connection_types` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `business_activities` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(100) NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `organization_activities` (
  `organization_id` INT UNSIGNED NOT NULL ,
  `business_activity_id` INT UNSIGNED NOT NULL ,
  PRIMARY KEY (`organization_id`, `business_activity_id`) ,
  INDEX `k_organization_activity_organization` (`organization_id` ASC) ,
  INDEX `k_organization_activity_business_activity` (`business_activity_id` ASC) ,
  CONSTRAINT `f_organization_activities_organization`
    FOREIGN KEY (`organization_id` )
    REFERENCES `organizations` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `f_organization_activities_business_activity`
    FOREIGN KEY (`business_activity_id` )
    REFERENCES `business_activities` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `acl_histories` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `acl_user_id` INT UNSIGNED NOT NULL ,
  `acl_role_id` INT UNSIGNED NOT NULL ,
  `action` ENUM('create','restore','update','delete') NOT NULL ,
  `record_id` INT UNSIGNED NOT NULL DEFAULT 0 ,
  `message` VARCHAR(200) NOT NULL ,
  `created_at` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' ,
  PRIMARY KEY (`id`) ,
  INDEX `k_acl_history_user` (`acl_user_id` ASC) ,
  INDEX `k_acl_history_role` (`acl_role_id` ASC) ,
  CONSTRAINT `f_acl_histories_user`
    FOREIGN KEY (`acl_user_id` )
    REFERENCES `acl_users` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `f_acl_histories_role`
    FOREIGN KEY (`acl_role_id` )
    REFERENCES `acl_roles` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `employments` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `individual_id` INT UNSIGNED NOT NULL ,
  `organization_id` INT UNSIGNED NOT NULL ,
  `job_position` VARCHAR(100),
  PRIMARY KEY (`id`) ,
  INDEX `k_employment_organization` (`organization_id` ASC) ,
  INDEX `k_employment_individual` (`individual_id` ASC) ,
  UNIQUE INDEX `u_employment_individual` (`individual_id` ASC) ,
  CONSTRAINT `f_employments_organization`
    FOREIGN KEY (`organization_id` )
    REFERENCES `organizations` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `f_employment_individual`
    FOREIGN KEY (`individual_id` )
    REFERENCES `individuals` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `localizations` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `country` VARCHAR(2) NOT NULL ,
  `state` VARCHAR(100) NULL ,
  `city` VARCHAR(100) NOT NULL ,
  `district` VARCHAR(100) NULL ,
  `code` VARCHAR(50) NULL ,
  `address` VARCHAR(200) NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `individual_localizations` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `individual_id` INT UNSIGNED NOT NULL ,
  `localization_id` INT UNSIGNED NOT NULL ,
  `context` ENUM('home','business') NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `k_individual_localization_individual` (`individual_id` ASC) ,
  INDEX `k_individual_localization_localization` (`localization_id` ASC) ,
  INDEX `u_individual_localization_individual_context` (`context` ASC, `individual_id` ASC) ,
  CONSTRAINT `f_individual_localizations_individual`
    FOREIGN KEY (`individual_id` )
    REFERENCES `individuals` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `f_individual_localization_localization`
    FOREIGN KEY (`localization_id` )
    REFERENCES `localizations` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `organization_localizations` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `localization_id` INT UNSIGNED NOT NULL ,
  `organization_id` INT UNSIGNED NOT NULL ,
  `context` ENUM('office') NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `k_organization_localization_localization` (`localization_id` ASC) ,
  INDEX `k_organization_localizations_organization` (`organization_id` ASC) ,
  UNIQUE INDEX `u_organization_localization_organization_context` (`organization_id` ASC, `context` ASC) ,
  CONSTRAINT `f_organization_localization_localization`
    FOREIGN KEY (`localization_id` )
    REFERENCES `localizations` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `f_organization_localizations_organization`
    FOREIGN KEY (`organization_id` )
    REFERENCES `organizations` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `personal_activities` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(100) NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `individual_activities` (
  `individual_id` INT UNSIGNED NOT NULL ,
  `personal_activity_id` INT UNSIGNED NOT NULL ,
  PRIMARY KEY (`individual_id`, `personal_activity_id`) ,
  INDEX `k_individual_activity_individual` (`individual_id` ASC) ,
  INDEX `k_individual_activity_personal_activity` (`personal_activity_id` ASC) ,
  UNIQUE INDEX `u_individual_activity` (`individual_id` ASC, `personal_activity_id` ASC) ,
  CONSTRAINT `f_individual_activities_individual`
    FOREIGN KEY (`individual_id` )
    REFERENCES `individuals` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `f_individual_activities_personal_activity`
    FOREIGN KEY (`personal_activity_id` )
    REFERENCES `personal_activities` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `individual_containers` (
  `individual_id` INT UNSIGNED NOT NULL ,
  `container_id` INT UNSIGNED NOT NULL ,
  PRIMARY KEY (`individual_id`, `container_id`) ,
  INDEX `k_individual_container_individual` (`individual_id` ASC) ,
  INDEX `k_individual_container_container` (`container_id` ASC) ,
  CONSTRAINT `f_individual_containers_individual`
    FOREIGN KEY (`individual_id` )
    REFERENCES `individuals` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `f_individual_containers_container`
    FOREIGN KEY (`container_id` )
    REFERENCES `containers` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `printable_dispatches` (
  `id` INT NOT NULL ,
  `printable_job_id` INT UNSIGNED NOT NULL ,
  `individual_id` INT UNSIGNED NOT NULL ,
  `accomplished` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 ,
  PRIMARY KEY (`id`) ,
  INDEX `k_printable_dispatch_job` (`printable_job_id` ASC) ,
  INDEX `k_printable_dispatch_individual` (`individual_id` ASC) ,
  UNIQUE INDEX `u_printable_dispatch_job_individual` (`printable_job_id` ASC, `individual_id` ASC) ,
  CONSTRAINT `f_printable_dispatches_printable_job`
    FOREIGN KEY (`printable_job_id` )
    REFERENCES `printable_jobs` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `f_printable_dispatches_individual`
    FOREIGN KEY (`individual_id` )
    REFERENCES `individuals` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS

    execute <<-EOS
CREATE  TABLE IF NOT EXISTS `event_subscribers` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `event_id` INT UNSIGNED NOT NULL ,
  `subscriber_id` INT UNSIGNED NOT NULL ,
  `data` TEXT NOT NULL DEFAULT '' ,
  `created_at` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' ,
  `updated_at` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' ,
  PRIMARY KEY (`id`) ,
  INDEX `k_event_subscriber_event` (`event_id` ASC) ,
  INDEX `k_event_subscriber_subscriber` (`subscriber_id` ASC) ,
  INDEX `k_event_subscriber_created_at` (`created_at` ASC) ,
  CONSTRAINT `f_event_subscriber_event`
    FOREIGN KEY (`event_id` )
    REFERENCES `events` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `f_event_subscriber_subscriber`
    FOREIGN KEY (`subscriber_id` )
    REFERENCES `subscribers` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
    EOS
  end

  def self.down
    execute "DROP  TABLE  `subscribers`"
    execute "DROP  TABLE  `printable_jobs`"
    execute "DROP  TABLE  `printable_dispatches`"
    execute "DROP  TABLE  `printable_templates`"
    execute "DROP  TABLE  `printables`"
    execute "DROP  TABLE  `printable_containers`"
    execute "DROP  TABLE  `personal_activities`"
    execute "DROP  TABLE  `organizations`"
    execute "DROP  TABLE  `organization_localizations`"
    execute "DROP  TABLE  `organization_connections`"
    execute "DROP  TABLE  `organization_activities`"
    execute "DROP  TABLE  `localizations`"
    execute "DROP  TABLE  `individuals`"
    execute "DROP  TABLE  `individual_localizations`"
    execute "DROP  TABLE  `individual_containers`"
    execute "DROP  TABLE  `individual_connections`"
    execute "DROP  TABLE  `individual_activities`"
    execute "DROP  TABLE  `event_subscribers`"
    execute "DROP  TABLE  `events`"
    execute "DROP  TABLE  `employments`"
    execute "DROP  TABLE  `container_types`"
    execute "DROP  TABLE  `containers`"
    execute "DROP  TABLE  `connection_types`"
    execute "DROP  TABLE  `campaign_templates`"
    execute "DROP  TABLE  `campaigns`"
    execute "DROP  TABLE  `campaign_jobs`"
    execute "DROP  TABLE  `campaign_dispatches`"
    execute "DROP  TABLE  `campaign_containers`"
    execute "DROP  TABLE  `business_activities`"
    execute "DROP  TABLE  `acl_users`"
    execute "DROP  TABLE  `acl_roles`"
    execute "DROP  TABLE  `acl_permissions`"
    execute "DROP  TABLE  `acl_histories`"
  end
end
