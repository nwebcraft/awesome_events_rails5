class Event < ApplicationRecord
  mount_uploader :event_image, EventImageUploader

  has_many :tickets, dependent: :destroy
  belongs_to :owner, class_name: 'User'

  validates :name, length: { maximum: 50 }, presence: true
  validates :place, length: { maximum: 100}, presence: true
  validates :content, length: { maximum: 2000 }, presence: true
  validates :start_time, presence: true
  validates :end_time,   presence: true
  validate :start_time_should_be_before_end_time

  def self.ransackable_attributes(auth_object = nil)
    %w(name start_time)
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  def created_by?(user)
    return false unless user
    owner_id == user.id
  end

  private

  def start_time_should_be_before_end_time
    return unless start_time && end_time

    if start_time >= end_time
      errors.add :start_time, I18n.t('message.error.start_time_should_be_before_end_time')
    end
  end
end
