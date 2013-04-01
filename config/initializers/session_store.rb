# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_sicici_session',
  :secret      => '436e729e636fade36993dc7832f9e3b7b94e8e378264bdcfaa37389876c666632d5aa7b2ba384798f2e0163e6fc0a257459907b1f7069a8f5a418ebaec7f182d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
