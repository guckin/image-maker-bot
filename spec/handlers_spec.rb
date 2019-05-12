@content_type = nil
module TestHandlers
  include Handlers
  def content_type(type)
    @content_type = type
  end
end

describe Handlers do
  include TestHandlers

  context '#health_check' do

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
end