# Facebooker2
require "mogli"
module Facebooker2
  class NotConfigured < Exception; end
  class << self
    attr_accessor :api_key, :secret, :app_id, :configuration, :tld, :default_tld, :tlds
  end
    
  def self.tld
    @tld || ApplicationController.top_level_domain.to_s
    @tld = @default_tld if @tlds.exclude?(@tld)
    @tld
  end
  
  def self.default_configuration
    @configuration ||= {} and @configuration[self.tld] ||= {}
  end
  
  def self.secret=(value)
    default_configuration
    @configuration[self.tld]['secret'] = value
  end
  
  def self.secret
    # @secret || raise_unconfigured_exception
    @configuration[self.tld] || raise_unconfigured_exception
    @configuration[self.tld]['secret'] || raise_unconfigured_exception
  end
  
  def self.app_id=(value)
    default_configuration
    @configuration[self.tld]['app_id'] = value
  end

  def self.app_id
    # @app_id || raise_unconfigured_exception
    @configuration[self.tld] || raise_unconfigured_exception
    @configuration[self.tld]['app_id'] || raise_unconfigured_exception
  end
  
  def self.api_key=(value)
    default_configuration
    @configuration[self.tld]['api_key'] = value
  end
  
  def self.api_key
    @configuration[self.tld] and @configuration[self.tld]['api_key']
  end
  
  def self.configuration=(hash)
    @configuration[self.tld] = hash.with_indifferent_access
  end
  
  def self.raise_unconfigured_exception
    raise NotConfigured.new("No configuration provided for Facebooker2. Either set the app_id and secret or call Facebooker2.load_facebooker_yaml in an initializer")
  end
  
  def self.load_facebooker_yaml
    config = YAML.load(File.read(File.join(::Rails.root,"config","facebooker.yml")))[::Rails.env]
    raise NotConfigured.new("Unable to load configuration for #{::Rails.env} from facebooker.yml. Is it set up?") if config.nil?
    @configuration = config.with_indifferent_access
  end
  
  def self.cast_to_facebook_id(object)
    if object.kind_of?(Mogli::Profile)
      object.id
    elsif object.respond_to?(:facebook_id)
      object.facebook_id
    else
      object
    end
  end
end


require "facebooker2/rails/controller"
require "facebooker2/rails/helpers/facebook_connect"
require "facebooker2/rails/helpers/javascript"
require "facebooker2/rails/helpers/request_forms"
require "facebooker2/rails/helpers/user"
require "facebooker2/rails/helpers"