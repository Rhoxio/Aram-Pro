class User < ActiveRecord::Base
	has_many :summoners
	has_many :matches
	has_secure_password
end

