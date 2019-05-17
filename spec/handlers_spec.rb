TestRequestClass = Struct.new(:body)
TestBodyClass = Struct.new(:read)
@content_type = nil
@status = nil
@message = nil
@request = nil

module TestHandlers
  include Handlers

  def content_type(type)
    @content_type = type
  end

  def halt(status, message = nil)
    @status = status
    @message = message
  end

  def request
    @request
  end

  def body(hash)
    response_body = TestBodyClass.new(hash.to_json)
    @request = TestRequestClass.new(response_body)
  end

end

describe Handlers do
  include TestHandlers

  before :each do
    body foo: :bar
  end

  describe '#health_check' do

    before :each do
      @content_type = nil
    end

    it 'return parsable health check json' do
      expect(JSON.parse(health_check)).to eq({ 'health_check' => 'ok' })
    end

    it 'sets the content type to Json' do
      health_check
      expect(@content_type).to eq :json
    end
  end

  describe '#page_subscription' do

    it 'halts 404 if the event was not from a page subscription' do
      page_subscription({})
      expect(@status).to eq 404
    end
  end

  describe '#handle_message_entries' do

    it 'yields the entries' do
      test_data = [1,2]
      actual_entries = []
      body entry: test_data
      handle_message_entries { |entry| actual_entries << entry }
      expect(actual_entries).to eq test_data
    end
  end
end