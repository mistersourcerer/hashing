describe Hashing do
  it "adds the method hasherize to a class" do
    # if in doubt about the absense of assertions in this test, please
    # refer to:
    # - http://blog.zenspider.com/blog/2012/01/assert_nothing_tested.html
    # and https://github.com/seattlerb/minitest/issues/159
    Class.new do
      include Hashing
      hasherize :ivar
    end
  end
end
