require 'rails_helper'

RSpec.describe Ticket, type: :model do

  describe 'association' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:event) }
  end

  describe '#comment' do
    it { is_expected.to validate_length_of(:comment).is_at_most(30) }
    it { is_expected.to allow_value('', nil, ' ').for(:comment) }
  end

end
