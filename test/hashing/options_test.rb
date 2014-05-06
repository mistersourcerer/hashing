describe Hashing::Options do
  before do
    @original_stderror = $stderr
    $stderr = StringIO.new
  end

  after do
    $stderr = @original_stderror
  end

  describe "#filter" do
    it "shows warning for unrecognized option" do
      Hashing::Options.new(omg_lol_bbq: 'unrecognized').filter('x:1')
      $stderr.string.must_match /invoked with unrecognized :omg_lol_bbq option/
      $stderr.string.must_match /It will be ignored/
    end

    it "replaces a deprecation by their replacement" do
      some_callable = ->(){}
      options = Hashing::Options.new(to_hash: some_callable).filter('x:1')
      # well, for some reason I can't use lambda.must_be_same_as..., maybe a bug?
      options.strategies[:to].equal?(some_callable).must_equal true
    end
  end
end
