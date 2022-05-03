class User < ApplicationRecord

  has_many :user_stocks
  has_many :stocks, through: :user_stocks
  has_many :friendships
  has_many :friends, through: :friendships
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  def under_stock_limit?
    stocks.count < 10
  end

  def stock_already_tracked?(ticker_symbol)
    stock = Stock.check_db(ticker_symbol) #check that stock exists in db of stocks
    return false unless stock
    stocks.where(id: stock.id).exists? #check that stock already belongs to the user
  end

  def can_track_stock?(ticker_symbol)
    under_stock_limit? && !(stock_already_tracked?(ticker_symbol))
  end
  
  def full_name
    return "#{first_name} #{last_name}" if first_name || last_name
    "Anonymous"
  end

  def self.matches(field_name, param)
    where("#{field_name} like ?", "%#{param}%")
  end

  def self.first_name_matches(param)
    matches('first_name', param)
  end

  def self.last_name_matches(param)
    matches('last_name', param)
  end

  def self.email_matches(param)
    matches('email', param)
  end

  def self.search(param)
    param.strip!
    matches_arr = first_name_matches(param) + last_name_matches(param) + email_matches(param)
    matches_arr.uniq!
    return nil unless matches_arr
    matches_arr
  end

  def except_current_user(users)
    users.reject{ |user| user.id == self.id}
  end
  def not_friends_with?(id_of_friend)
    !self.friends.where(id: id_of_friend).exists?
  end
  
end
