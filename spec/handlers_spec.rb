include Handlers
describe Handlers do
  context '#health_check' do
    it 'return parsable health check json' do
      expect(JSON.parse(health_check)).to eq({ 'health_check' => 'ok' })
    end
  end
end