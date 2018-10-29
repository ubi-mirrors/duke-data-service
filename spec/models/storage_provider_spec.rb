require 'rails_helper'

RSpec.describe StorageProvider, type: :model do
  subject { StorageProvider.new }
  let(:project) { instance_double("Project") }
  let(:upload) { instance_double("Upload") }
  let(:chunk) { instance_double("Chunk") }

  it_behaves_like 'A StorageProvider'

  it {
    expect {
      subject.initialize_project(project)
    }.to raise_error(NotImplementedError)
  }
  it {
    expect {
      subject.single_file_upload_url(upload)
    }.to raise_error(NotImplementedError)
  }
  it {
    expect {
      subject.initialize_chunked_upload(upload)
    }.to raise_error(NotImplementedError)
  }
  it {
    expect {
      subject.endpoint
    }.to raise_error(NotImplementedError)
  }
  it {
    expect {
      subject.chunk_upload_url(chunk)
    }.to raise_error(NotImplementedError)
  }
  it {
    expect {
      subject.chunk_max_exceeded?(chunk)
    }.to raise_error(NotImplementedError)
  }
  it {
    expect {
      subject.max_chunked_upload_size
    }.to raise_error(NotImplementedError)
  }
  it {
    expect {
      subject.suggested_minimum_chunk_size(upload)
    }.to raise_error(NotImplementedError)
  }
  it {
    expect {
      subject.complete_chunked_upload(upload)
    }.to raise_error(NotImplementedError)
  }
  it {
    expect {
      subject.download_url(upload)
    }.to raise_error(NotImplementedError)
  }
  it {
    expect {
      subject.purge(upload)
    }.to raise_error(NotImplementedError)
  }
  it {
    expect {
      subject.purge(chunk)
    }.to raise_error(NotImplementedError)
  }
end
