require 'spec_helper'
require 'command_mapper/types'

describe CommandMapper::Types do
  it "must define a Str type" do
    expect(subject.const_defined?('Str')).to be(true)
  end

  it "must define a Num type" do
    expect(subject.const_defined?('Num')).to be(true)
  end

  it "must define a Hex type" do
    expect(subject.const_defined?('Hex')).to be(true)
  end

  it "must define a Map type" do
    expect(subject.const_defined?('Map')).to be(true)
  end

  it "must define a Enum type" do
    expect(subject.const_defined?('Enum')).to be(true)
  end

  it "must define a List type" do
    expect(subject.const_defined?('List')).to be(true)
  end

  it "must define a KeyValue type" do
    expect(subject.const_defined?('KeyValue')).to be(true)
  end

  it "must define a KeyValueList type" do
    expect(subject.const_defined?('KeyValueList')).to be(true)
  end

  it "must define a InputPath type" do
    expect(subject.const_defined?('InputPath')).to be(true)
  end

  it "must define a InputFile type" do
    expect(subject.const_defined?('InputFile')).to be(true)
  end

  it "must define a InputDir type" do
    expect(subject.const_defined?('InputDir')).to be(true)
  end
end
