class User < ActiveRecord::Base
	has_many :summoners
	has_secure_password
end

