class User < ApplicationRecord

  has_many :items, -> { order 'created_at desc' }, :foreign_key => "user_uuid"

  def serializable_hash(options = {})
    result = super(options.merge({only: ["email", "uuid"]}))
    result
  end


  def auth_params
    params = {:pw_cost => self.pw_cost, :version => self.version, :identifier => self.email}

    if self.pw_nonce
      params[:pw_nonce] = self.pw_nonce
    end

    if self.pw_salt
      params[:pw_salt] = self.pw_salt
    end

    if self.pw_func
      params[:pw_func] = self.pw_func
      params[:pw_alg] = self.pw_alg
      params[:pw_key_size] = self.pw_key_size
    end

    return params
  end

  def export_archive
    data = {:items => self.items.where(:deleted => false), :auth_params => self.auth_params}
    # This will write restore.txt in your application's root directory.
    File.open("tmp/#{self.email}-restore.txt", 'w') { |file| file.write(JSON.pretty_generate(data.as_json({}))) }
  end

end
