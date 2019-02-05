class WifiUser::Repository::UserDbUser < Sequel::Model(USER_DB[:userdetails])
  self.unrestrict_primary_key
end
