require 'spec_helper'
require 'command_mapper/exceptions'

describe CommandMapper::ValidationError do
  it do
    expect(described_class).to be < CommandMapper::Error
  end
end

describe CommandMapper::ArgumentRequired do
  it do
    expect(described_class).to be < CommandMapper::Error
  end
end
