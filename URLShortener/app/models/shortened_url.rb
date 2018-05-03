# == Schema Information
#
# Table name: shortened_urls
#
#  id         :bigint(8)        not null, primary key
#  short_url  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  long_url   :string
#  user_id    :integer
#

class ShortenedUrl < ApplicationRecord

  validates :short_url, uniqueness: true, presence: true

  belongs_to :submitter,
  primary_key: :id,
  foreign_key: :user_id,
  class_name: :User

  has_many :visits,
  primary_key: :id,
  foreign_key: :url_id,
  class_name: :Visit

  has_many :visitors,
  Proc.new{distinct},
  through: :visits,
  source: :user


  def self.random_code
    while true
      code = SecureRandom::urlsafe_base64
      return code unless exists?(:short_url => code)
    end
  end

  def self.create!(user,url)
    ShortenedUrl.new({short_url:ShortenedUrl.random_code, user_id: user.id, long_url:url})
  end

  def num_clicks
    Visit.select(:user_id).count
  end

  def num_uniques
    visitors.count
  end

  def num_recent_uniques
    visitors.where({ created_at: ((10.minutes.ago)..Time.now)}).count
  end

end
