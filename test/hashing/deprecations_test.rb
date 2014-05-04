require "stringio"

describe "Hashing - Deprecation warnings" do
  before do
    @original_stderror = $stderr
    $stderr = StringIO.new
  end

  after do
    $stderr = @original_stderror
  end

  it "deprecates the :from_hash option" do
    Class.new do
      include Hashing
      hasherize :xpto, from_hash: ->(value){}
    end

    $stderr.string.must_match /option :from_hash is deprecated; use :from/
  end

  it "deprecates the :to_hash option" do
    Class.new do
      include Hashing
      hasherize :xpto, to_hash: ->(value){}
    end

    $stderr.string.must_match /option :to_hash is deprecated; use :to/
  end
end
