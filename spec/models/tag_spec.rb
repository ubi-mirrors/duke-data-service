require 'rails_helper'

RSpec.describe Tag, type: :model do
  subject { FactoryGirl.create(:tag) }

  it_behaves_like 'an audited model'

  describe 'associations' do
    it { is_expected.to belong_to(:taggable) }
    it { is_expected.to have_many(:project_permissions).through(:taggable) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:label) }
    it { is_expected.to validate_presence_of(:taggable) }
  end

  it 'should set default attribute' do
    expect(subject.taggable_type).to eq('DataFile')
  end

  describe '::label_count' do
    it { expect(described_class).to respond_to(:label_count) }
    it { expect(described_class.label_count).to be_a Array }
    context 'with tags' do
      let(:tag_label) { TagLabel.new(label: 'Foo', count: 2) }
      before { FactoryGirl.create_list(:tag, 2, label: 'Foo') }
      it { expect(described_class.label_count).to include(tag_label) }
    end
  end
end
