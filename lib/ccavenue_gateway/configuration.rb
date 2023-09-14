module CcavenueGateway
  class Configuration
    include Env

    def initialize(tenant_id)
      @tenant_id = tenant_id
      @pg_settings = load_pg_setting
    end

    def merchant_id
      @pg_settings&.dig(:merchant_id)
    end

    def access_code
      @pg_settings&.dig(:access_code)
    end

    def working_key
      @pg_settings&.dig(:working_key)
    end

    def mode
      find_value_by_name(:ccavenue_gateway, :env) || 'TEST' # TEST or LIVE
    end

    private

    def default?
      @tenant_id == 'default'
    end

    def load_pg_setting
      pg_credentials = default? ? load_default_pg_setting : load_tenant_pg_setting
      raise ConfigNotFoundError, "Invalid PG settings" unless valid_pg_credentials?(pg_credentials)
      pg_credentials
    end

    def load_default_pg_setting
      {
        merchant_id: find_value_by_name(:ccavenue_gateway, :merchant_id),
        access_code: find_value_by_name(:ccavenue_gateway, :access_code),
        working_key: find_value_by_name(:ccavenue_gateway, :working_key)
      }
    end

    def load_tenant_pg_setting
      account = Account.find_by(id: @tenant_id)
      raise ConfigNotFoundError, "Account not found" unless account

      idp_setting = account.id_p_setup
      raise ConfigNotFoundError, "IDP setting not found for the Account" unless idp_setting

      {
        merchant_id: idp_setting.pg_public_key,
        access_code: idp_setting.pg_public_key,
        working_key: idp_setting.pg_private_key
      }
    end

    def valid_pg_credentials?(pg_credentials)
      pg_credentials[:merchant_id] && pg_credentials[:access_code] && pg_credentials[:working_key]
    end
  end
end
