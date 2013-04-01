# application initializer
# thanks to http://railscasts.com/episodes/85-yaml-configuration-file
APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/application.yml")[RAILS_ENV]
