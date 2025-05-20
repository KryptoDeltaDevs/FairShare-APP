# frozen_string_literal: true

require_relative '../spec_helper'
require 'webmock/minitest'

describe 'Test Service Objects' do
  before do
    @credentials = { email: 'jane@gmail.com', password: 'jane123' }
    @mal_credentials = { email: 'jane@nthu.edu.tw', password: 'jane' }
    @api_account = { id: '9d5c6162-0336-483b-ad81-8bc350015e08', name: 'Jane', email: 'jane@gmail.com' }
  end

  after do
    WebMock.reset!
  end

  describe 'Find authenticated account' do
    it 'HAPPY: should find an authenticated account' do
      auth_account_file = 'spec/fixtures/auth_account.json'
      auth_return_json = File.read(auth_account_file)

      WebMock.stub_request(:post, "#{API_URL}/auth/authenticate")
             .with(body: @credentials.to_json)
             .to_return(body: auth_return_json,
                        headers: { 'content-type' => 'application/json' })

      auth = FairShare::AuthenticateAccount.new(app.config).call(**@credentials)
      account = auth[:account]
      _(account).wont_be_nil
      _(account['id']).must_equal @api_account[:id]
      _(account['name']).must_equal @api_account[:name]
      _(account['email']).must_equal @api_account[:email]
    end

    it 'BAD: should not find a false authenticated account' do
      WebMock.stub_request(:post, "#{API_URL}/auth/authenticate")
             .with(body: @mal_credentials.to_json)
             .to_return(status: 403)
      _(proc {
        FairShare::AuthenticateAccount.new(app.config).call(**@mal_credentials)
      }).must_raise FairShare::AuthenticateAccount::UnauthorizedError
    end
  end
end
