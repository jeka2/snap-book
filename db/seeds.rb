1.upto(10) do |i| 
    User.create(username: "user_#{i}", password_hash: BCrypt::Password.create('password'), first_name: "First Name #{i}", last_name: "Last Name #{i}", info: "A little about me")
end