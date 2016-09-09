require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'association' do
    it { is_expected.to have_many(:created_events).class_name('Event').with_foreign_key(:owner_id) }
    it { is_expected.to have_many(:tickets).dependent(:nullify) }
    it { is_expected.to have_many(:participating_events).through(:tickets).source(:event) }
  end

  describe 'クラスメソッド find_or_create_from_auth_hash' do
    let(:auth_hash) do
      {
        provider: 'twitter',
        uid: 'uid',
        info: {
          nickname: 'nwebcraft',
          image: 'https://www.example.com/hoge/nwebcraft.jpg'
        }
      }
    end

    context 'authハッシュのproviderとuidのユーザーが存在していない場合' do
      example 'authハッシュの属性のユーザーオブジェクトが返ること' do
        user = User.find_or_create_from_auth_hash(auth_hash)
        expect(user.uid).to eq 'uid'
        expect(user.provider).to eq 'twitter'
        expect(user.nickname).to eq 'nwebcraft'
        expect(user.image_url).to eq 'https://www.example.com/hoge/nwebcraft.jpg'
        expect(user).to be_persisted
      end

      example 'Userモデル(usersテーブルのレコード)が１件増えること' do
        expect { User.find_or_create_from_auth_hash(auth_hash) }.
          to change { User.count }.by(1)
      end
    end

    context 'authハッシュのproviderとuidのユーザーが存在している場合' do
      let!(:user1) { create(:user, uid: 'uid') }
      let!(:user2) { create(:user, uid: 'other_uid') }

      example '正しいユーザーオブジェクトが返ること' do
        found_user = User.find_or_create_from_auth_hash(auth_hash)
        expect(found_user).to eq user1
      end

      example 'Userモデル(usersテーブルのレコード)の数が変わらないこと' do
        expect { User.find_or_create_from_auth_hash(auth_hash) }.
         not_to change { User.count }
      end
    end
  end

  describe 'private method' do
    describe '#check_all_events_finished' do
      let(:user) { create(:user) }

      context '終了していない作成イベント、終了していない参加イベントがともにないとき' do
        before do
          create(:event, owner: user, start_time: 10.days.ago, end_time: 1.day.ago)
          create(:ticket, user: user, event: create(:event, start_time: 3.days.ago, end_time: 1.day.ago))
        end

        example 'true が返ること' do
          expect(user.send(:check_all_events_finished)).to eq true
        end

        example 'user.errors が空なこと' do
          user.send(:check_all_events_finished)
          expect(user.errors).to be_blank
        end
      end

      context '終了していない作成イベントが存在するとき' do
        before do
          create(:event, owner: user, start_time: 1.day.ago, end_time: 2.day.from_now)
        end

        example 'false が返ること' do
          expect(user.send(:check_all_events_finished)).to eq false
        end

        example 'user.errors[:base] に message.error.not_end_created_event_exists の文字列が含まれること' do
          user.send(:check_all_events_finished)
          expect(user.errors[:base]).to be_include(I18n.t('message.error.not_end_created_event_exists'))
        end
      end

      context '終了していない参加イベントが存在するとき' do
        before do
          create(:ticket, user: user, event: create(:event, start_time: 3.day.ago, end_time: 1.day.from_now))
        end

        example 'false が返ること' do
          expect(user.send(:check_all_events_finished)).to eq false
        end

        example 'user.errors[:base] に message.error.not_end_joined_event_exists の文字列が含まれること' do
          user.send(:check_all_events_finished)
          expect(user.errors[:base]).to be_include(I18n.t('message.error.not_end_joined_event_exists'))
        end
      end
    end
  end

end
