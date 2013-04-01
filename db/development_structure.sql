CREATE TABLE `acl_histories` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `acl_user_id` int(10) unsigned NOT NULL,
  `acl_role_id` int(10) unsigned NOT NULL,
  `action` enum('create','restore','update','delete') COLLATE utf8_unicode_ci NOT NULL,
  `record_id` int(10) unsigned NOT NULL DEFAULT '0',
  `message` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `k_acl_history_user` (`acl_user_id`),
  KEY `k_acl_history_role` (`acl_role_id`),
  CONSTRAINT `f_acl_histories_role` FOREIGN KEY (`acl_role_id`) REFERENCES `acl_roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `f_acl_histories_user` FOREIGN KEY (`acl_user_id`) REFERENCES `acl_users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `acl_permissions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `acl_user_id` int(10) unsigned NOT NULL,
  `acl_role_id` int(10) unsigned NOT NULL,
  `writable` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_acl_permission_user_role` (`acl_user_id`,`acl_role_id`),
  KEY `k_acl_permission_role` (`acl_role_id`),
  KEY `k_acl_permission_user` (`acl_user_id`),
  CONSTRAINT `f_acl_permissions_role` FOREIGN KEY (`acl_role_id`) REFERENCES `acl_roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `f_acl_permissions_user` FOREIGN KEY (`acl_user_id`) REFERENCES `acl_users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `acl_roles` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `acl_users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `individual_id` int(10) unsigned DEFAULT NULL,
  `username` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `hash_password` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `enabled` tinyint(1) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_username` (`username`),
  KEY `k_acl_user_authentication` (`username`(4),`hash_password`(4)),
  KEY `k_acl_user_individual` (`individual_id`),
  CONSTRAINT `f_acl_user_individual` FOREIGN KEY (`individual_id`) REFERENCES `individuals` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `business_activities` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `campaign_containers` (
  `campaign_id` int(10) unsigned NOT NULL,
  `container_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`campaign_id`,`container_id`),
  KEY `k_campaign_campaign_containers` (`campaign_id`),
  KEY `k_container_campaign_containers` (`container_id`),
  CONSTRAINT `f_campaign_campaigns_containers` FOREIGN KEY (`campaign_id`) REFERENCES `campaigns` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `f_container_campaigns_containers` FOREIGN KEY (`container_id`) REFERENCES `containers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `campaign_dispatches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `subscriber_id` int(10) unsigned NOT NULL,
  `campaign_job_id` int(10) unsigned NOT NULL,
  `status` enum('unsent','sent','bounced','rejected','failed') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'unsent',
  `pid` int(10) unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  KEY `k_campaign_dispatch_job` (`campaign_job_id`),
  KEY `k_campaign_dispatch_subscriber` (`subscriber_id`),
  KEY `k_campaign_dispatch_status` (`status`),
  KEY `k_campaign_dispatch_pid` (`pid`),
  CONSTRAINT `f_campaign_dispatches_campaign_job` FOREIGN KEY (`campaign_job_id`) REFERENCES `campaign_jobs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `f_campaign_dispatches_subscriber` FOREIGN KEY (`subscriber_id`) REFERENCES `subscribers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `campaign_jobs` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `campaign_id` int(10) unsigned NOT NULL,
  `subject` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `status` enum('new','running','stopped','finished') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'new',
  `pid` int(11) NOT NULL DEFAULT '0',
  `scheduled` timestamp NULL DEFAULT NULL,
  `template` text COLLATE utf8_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  KEY `k_campaign_job_campaign` (`campaign_id`),
  KEY `k_campaign_job_status` (`status`),
  KEY `k_campaign_job_scheduled` (`scheduled`),
  CONSTRAINT `f_campaign_jobs_campaign` FOREIGN KEY (`campaign_id`) REFERENCES `campaigns` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `campaign_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `campaigns` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `campaign_template_id` int(10) unsigned NOT NULL,
  `name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `periodicity` int(10) unsigned NOT NULL DEFAULT '0',
  `data` text COLLATE utf8_unicode_ci NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  KEY `k_campaign_template` (`campaign_template_id`),
  KEY `k_campaign_periodicity` (`periodicity`),
  KEY `k_campaign_enabled` (`enabled`),
  CONSTRAINT `f_campaign_jobs_campaign_template` FOREIGN KEY (`campaign_template_id`) REFERENCES `campaign_templates` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `connection_types` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `container_types` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `public` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `removable` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `k_container_type_public` (`public`),
  KEY `k_container_type_removable` (`removable`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `containers` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `container_type_id` int(10) unsigned NOT NULL,
  `hash_id` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_container_hash` (`hash_id`),
  KEY `k_container_hash` (`hash_id`(4)),
  KEY `k_container_container_type` (`container_type_id`),
  CONSTRAINT `f_container_container_type` FOREIGN KEY (`container_type_id`) REFERENCES `container_types` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `employments` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `individual_id` int(10) unsigned NOT NULL,
  `organization_id` int(10) unsigned NOT NULL,
  `job_position_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_employment_individual` (`individual_id`),
  KEY `k_employment_job_position` (`job_position_id`),
  KEY `k_employment_organization` (`organization_id`),
  KEY `k_employment_individual` (`individual_id`),
  CONSTRAINT `f_employments_job_position` FOREIGN KEY (`job_position_id`) REFERENCES `job_positions` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `f_employments_organization` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `f_employment_individual` FOREIGN KEY (`individual_id`) REFERENCES `individuals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `event_subscribers` (
  `event_id` int(10) unsigned NOT NULL,
  `subscriber_id` int(10) unsigned NOT NULL,
  `data` text COLLATE utf8_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`event_id`,`subscriber_id`),
  KEY `k_event_subscriber_event` (`event_id`),
  KEY `k_event_subscriber_subscriber` (`subscriber_id`),
  KEY `k_event_subscriber_created_at` (`created_at`),
  CONSTRAINT `f_event_subscriber_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `f_event_subscriber_subscriber` FOREIGN KEY (`subscriber_id`) REFERENCES `subscribers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `events` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `container_id` int(10) unsigned NOT NULL,
  `name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `permalink` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `tagline` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `subscribing` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_event_container` (`container_id`),
  UNIQUE KEY `u_event_permalink` (`permalink`),
  KEY `k_event_container` (`container_id`),
  KEY `k_event_permalink` (`permalink`(4)),
  CONSTRAINT `f_event_container` FOREIGN KEY (`container_id`) REFERENCES `containers` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `individual_activities` (
  `individual_id` int(10) unsigned NOT NULL,
  `personal_activity_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`individual_id`,`personal_activity_id`),
  UNIQUE KEY `u_individual_activity` (`individual_id`,`personal_activity_id`),
  KEY `k_individual_activity_individual` (`individual_id`),
  KEY `k_individual_activity_personal_activity` (`personal_activity_id`),
  CONSTRAINT `f_individual_activities_individual` FOREIGN KEY (`individual_id`) REFERENCES `individuals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `f_individual_activities_personal_activity` FOREIGN KEY (`personal_activity_id`) REFERENCES `personal_activities` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `individual_connections` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `individual_id` int(10) unsigned NOT NULL,
  `connection_type_id` int(10) unsigned NOT NULL,
  `position` int(10) unsigned NOT NULL,
  `value` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `k_individual_connection_individual` (`individual_id`),
  KEY `k_individual_connection_type` (`connection_type_id`),
  CONSTRAINT `f_individual_connections_connection_type` FOREIGN KEY (`connection_type_id`) REFERENCES `connection_types` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `f_individual_connections_individual` FOREIGN KEY (`individual_id`) REFERENCES `individuals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `individual_containers` (
  `individual_id` int(10) unsigned NOT NULL,
  `container_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`individual_id`,`container_id`),
  KEY `k_individual_container_individual` (`individual_id`),
  KEY `k_individual_container_container` (`container_id`),
  CONSTRAINT `f_individual_containers_container` FOREIGN KEY (`container_id`) REFERENCES `containers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `f_individual_containers_individual` FOREIGN KEY (`individual_id`) REFERENCES `individuals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `individual_localizations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `individual_id` int(10) unsigned NOT NULL,
  `localization_id` int(10) unsigned NOT NULL,
  `context` enum('home','business') COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `k_individual_localization_individual` (`individual_id`),
  KEY `k_individual_localization_localization` (`localization_id`),
  KEY `u_individual_localization_individual_context` (`context`,`individual_id`),
  CONSTRAINT `f_individual_localizations_individual` FOREIGN KEY (`individual_id`) REFERENCES `individuals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `f_individual_localization_localization` FOREIGN KEY (`localization_id`) REFERENCES `localizations` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=132 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `individuals` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name_first` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `name_last` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `birthdate` date DEFAULT NULL,
  `gender` enum('male','female') COLLATE utf8_unicode_ci DEFAULT NULL,
  `citizenship_country` varchar(2) COLLATE utf8_unicode_ci DEFAULT NULL,
  `document` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `prefered_localization_context` enum('home','business','office') COLLATE utf8_unicode_ci DEFAULT NULL,
  `prefered_phone` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  KEY `individual_name` (`name_first`(4),`name_last`(8))
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `job_positions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `localizations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `country` varchar(2) COLLATE utf8_unicode_ci NOT NULL,
  `state` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `district` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `code` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=165 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `organization_activities` (
  `organization_id` int(10) unsigned NOT NULL,
  `business_activity_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`organization_id`,`business_activity_id`),
  KEY `k_organization_activity_organization` (`organization_id`),
  KEY `k_organization_activity_business_activity` (`business_activity_id`),
  CONSTRAINT `f_organization_activities_business_activity` FOREIGN KEY (`business_activity_id`) REFERENCES `business_activities` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `f_organization_activities_organization` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `organization_connections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(10) unsigned NOT NULL,
  `connection_type_id` int(10) unsigned NOT NULL,
  `position` int(10) unsigned NOT NULL,
  `value` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `k_organization_connection_organization` (`organization_id`),
  KEY `k_organization_connection_type` (`connection_type_id`),
  CONSTRAINT `f_organization_connections_connection_type` FOREIGN KEY (`connection_type_id`) REFERENCES `connection_types` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `f_organization_connections_organization` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `organization_localizations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `localization_id` int(10) unsigned NOT NULL,
  `organization_id` int(10) unsigned NOT NULL,
  `context` enum('office') COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_organization_localization_organization_context` (`organization_id`,`context`),
  KEY `k_organization_localization_localization` (`localization_id`),
  KEY `k_organization_localizations_organization` (`organization_id`),
  CONSTRAINT `f_organization_localizations_organization` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `f_organization_localization_localization` FOREIGN KEY (`localization_id`) REFERENCES `localizations` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `organizations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `document` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  KEY `k_organization_name` (`name`(6))
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `personal_activities` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `printable_containers` (
  `printable_id` int(10) unsigned NOT NULL,
  `container_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`printable_id`,`container_id`),
  KEY `k_printable_container_printable` (`printable_id`),
  KEY `k_printable_container_container` (`container_id`),
  CONSTRAINT `f_printable_containers_container` FOREIGN KEY (`container_id`) REFERENCES `containers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `f_printable_containers_printable` FOREIGN KEY (`printable_id`) REFERENCES `printables` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `printable_dispatches` (
  `id` int(11) NOT NULL,
  `printable_job_id` int(10) unsigned NOT NULL,
  `individual_id` int(10) unsigned NOT NULL,
  `accomplished` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_printable_dispatch_job_individual` (`printable_job_id`,`individual_id`),
  KEY `k_printable_dispatch_job` (`printable_job_id`),
  KEY `k_printable_dispatch_individual` (`individual_id`),
  CONSTRAINT `f_printable_dispatches_individual` FOREIGN KEY (`individual_id`) REFERENCES `individuals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `f_printable_dispatches_printable_job` FOREIGN KEY (`printable_job_id`) REFERENCES `printable_jobs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `printable_jobs` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `printable_id` int(10) unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `k_printable_job_printable` (`printable_id`),
  CONSTRAINT `f_printable_jobs_printable` FOREIGN KEY (`printable_id`) REFERENCES `printables` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `printable_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `printables` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `printable_template_id` int(10) unsigned NOT NULL,
  `name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  KEY `k_printable_template` (`printable_template_id`),
  CONSTRAINT `f_printables_printable_template` FOREIGN KEY (`printable_template_id`) REFERENCES `printable_templates` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `subscribers` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `individual_id` int(10) unsigned NOT NULL,
  `hash_id` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `email_local` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `email_domain` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `validated` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `unsubscribed` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `rejected` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `bounces` int(10) unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_subscriber_email` (`email_local`,`email_domain`),
  UNIQUE KEY `u_subscriber_hash` (`hash_id`),
  KEY `k_subscriber_hash` (`hash_id`(4)),
  KEY `k_subscriber_email` (`email_local`(4),`email_domain`(4)),
  KEY `k_subscriber_individual` (`individual_id`),
  CONSTRAINT `f_subscriber_individual` FOREIGN KEY (`individual_id`) REFERENCES `individuals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO schema_migrations (version) VALUES ('20100824001114');