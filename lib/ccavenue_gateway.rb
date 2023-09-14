# frozen_string_literal: true

require_relative "ccavenue_gateway/version"
require 'ccavenue_gateway/env'
require 'ccavenue_gateway/configuration'
require 'ccavenue_gateway/instance'
require 'ccavenue_gateway/client'
require 'ccavenue_gateway/entity'
require 'ccavenue_gateway/payment'

module CcavenueGateway
  class Error < StandardError; end
  class SignatureVerificationFailureError < Error; end
  class ConfigNotFoundError < Error; end
  
  class << self

    def create_instance(tenant_id='default')
      @instances ||= {}
      @instances[tenant_id] ||= Instance.new(tenant_id)
    end

  end

end
