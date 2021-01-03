1.upto(10) do |i| 
    User.create(username: "name_#{i}", password_hash: 'password')
end