require 'rails_helper'

RSpec.describe DataFileSerializer, type: :serializer do
  let(:root_file) { FactoryGirl.create(:data_file, :root) }
  let(:child_file) { FactoryGirl.create(:data_file, :with_parent) }
  it_behaves_like 'a serialized DataFile', :child_file
end
