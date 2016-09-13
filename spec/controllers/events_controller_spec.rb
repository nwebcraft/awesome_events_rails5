require 'rails_helper'

RSpec.describe EventsController, type: :controller do

  describe '#new' do

    context '未ログインユーザーがアクセスした場合' do
      example 'トップページにリダイレクトされること' do
        get :new
        expect(response).to redirect_to root_url
      end
    end

    context 'ログインユーザーがアクセスした場合' do
      let(:user) { create(:user) }
      let(:event) { assigns(:event) }
      before do
        session[:user_id] = user.id
        get :new
      end

      example 'ステータスコードが200が返る' do
        expect(response.status).to eq 200
      end

      example '@event に新規オブジェクトが格納されること' do
        expect(event).to be_a_new(Event)
        expect(event.owner).to eq user
      end

      example 'newテンプレートをレンダリングしていること' do
        expect(response).to render_template :new
      end
    end
  end

end
