require 'rails_helper'

RSpec.describe Event, type: :model do

  describe 'association' do
    it { is_expected.to have_many(:tickets).dependent(:destroy) }
    it { is_expected.to belong_to(:owner).class_name('User') }
  end

  describe '#name' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(50) }
  end

  describe '#place' do
    it { is_expected.to validate_presence_of(:place) }
    it { is_expected.to validate_length_of(:place).is_at_most(100) }
  end

  describe '#content' do
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_length_of(:content).is_at_most(2000) }
  end

  describe '#start_time' do
    it { is_expected.to validate_presence_of(:start_time) }
  end

  describe '#end_time' do
    it { is_expected.to validate_presence_of(:end_time) }
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

  describe 'private method' do
    describe '#start_time_should_be_before_end_time' do
      before :each do
        event.send(:start_time_should_be_before_end_time)
      end
      let(:event)      { build(:event, start_time: start_time, end_time: end_time) }
      let(:now) { Time.zone.now }

      subject { event.errors[:start_time] }

      context '#start_time が nilのとき' do
        let(:start_time) { nil }
        let(:end_time)   { now }

        it { is_expected.to be_empty }
      end

      context '#end_time が nilのとき' do
        let(:start_time) { now }
        let(:end_time)   { nil }

        it { is_expected.to be_empty }
      end

      context '#start_time と #end_time が nil のとき' do
        let(:start_time) { nil }
        let(:end_time)   { nil }

        it { is_expected.to be_empty }
      end

      context '#start_time と #end_time が同時刻のとき' do
        let(:start_time) { now }
        let(:end_time)   { now }

        it { is_expected.to be_present }
      end

      context '#start_time が #end_time より後のとき' do
        let(:start_time) { now + 1.day }
        let(:end_time)   { now }

        it { is_expected.to be_present }
      end

      context '#start_time が #end_time より前のとき' do
        let(:start_time) { now }
        let(:end_time)   { now + 10.day }

        it { is_expected.to be_empty }
      end
    end
  end
end
