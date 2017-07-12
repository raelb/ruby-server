class AddSalts < ActiveRecord::Migration[5.0]
  def change
    change_table(:users) do |t|
      t.string :pw_auth
      t.string :pw_salt
    end

    User.all.each do |user|
      user.pw_salt = Digest::SHA1.hexdigest(user.email + "SN" + user.pw_nonce)
      user.save
    end
  end
end
