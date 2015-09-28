require 'yaml'

module Config
  def self.config
    @conf ||= YAML.load_file(File.expand_path('../../config/config.yaml', __FILE__))
  end
end