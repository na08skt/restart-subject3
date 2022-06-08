class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :profile_image

  has_many :books, dependent: :destroy
  has_many :book_comments, dependent: :destroy
  has_many :favorites, dependent: :destroy


  # user が　フォローしている人を表示
  # has_many :follower, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :relationships, foreign_key: :follower_id, dependent: :destroy
  has_many :following_users, through: :relationships, source: :followed

  # user を　フォローしてくれている人を表示
  has_many :followed, class_name: 'Relationship', foreign_key: :followed_id, dependent: :destroy
  has_many :follower_users, through: :followed, source: :follower


  validates :name, length: { minimum: 2, maximum: 20 }, uniqueness: true
  validates :introduction, length: {maximum: 50}


  def get_profile_image
    (profile_image.attached?) ? profile_image : 'no_image.jpg'
  end

  def followed_by?(user)
    # follower_users.find_by(followed_id: user.id).present?
    follower_users.include?(user)
  end

  def self.looks(search, word)
    if search == "perfect_match"
      User.where("name LIKE?", "#{word}")
    elsif search == "forward_match"
      User.where("name LIKE?","#{word}%")
    elsif search == "backward_match"
      User.where("name LIKE?","%#{word}")
    elsif search == "partial_match"
      User.where("name LIKE?","%#{word}%")
    else
      User.all
    end
  end

end
