require 'rails_helper'

RSpec.describe Event, type: :model do
  describe '#name' do
    it { is_expected.to validate_presence_of(:name) }
    # it { should ensure_length_of(:name).is_at_most(50) }
    it { is_expected.to validate_length_of(:name).is_at_most(50) }
  end

  describe '#created_by?' do
    let(:event) { create(:event) }
    subject { event.created_by?(user) }

    context '引数が nil のとき' do
      let(:user) { nil }
      it { is_expected.to be_falsey }
    end

    context '#owner_id と 引数の#id が同じとき' do
      let(:user) { double('hoge_user', id: event.owner_id) }
      it { is_expected.to be_truthy }
    end
  end
end
