class User < ApplicationRecord

  has_many :items, -> { order 'created_at desc' }, :foreign_key => "user_uuid"

  def serializable_hash(options = {})
    result = super(options.merge({only: ["email", "uuid"]}))
    result
  end


  def auth_params
    params = {:pw_salt => self.pw_salt, :pw_cost => self.pw_cost}

    if self.pw_func
      params[:pw_func] = self.pw_func
      params[:pw_alg] = self.pw_alg
      params[:pw_key_size] = self.pw_key_size
    end

    return params
  end

end
