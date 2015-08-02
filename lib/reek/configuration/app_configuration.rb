require 'pathname'
require 'private_attr/everywhere'
require_relative './configuration_file_finder'
require_relative './configuration_validator'
require_relative './default_directive'
require_relative './directory_directives'
require_relative './excluded_paths'

module Reek
  # @api private
  module Configuration
    # @api private
    #
    # Reek's singleton configuration instance.
    #
    # @api private
    class AppConfiguration
      include ConfigurationValidator
      EXCLUDE_PATHS_KEY = 'exclude_paths'
      private_attr_accessor :directory_directives, :default_directive, :excluded_paths
      # Instantiate a configuration via given path.
      #
      # @param  path [Pathname] the path to the config file
      #
      # @return [AppConfiguration]
      def self.from_path(path: nil)
        instance = allocate
        instance.instance_eval do
          self.directory_directives = {}.extend(DirectoryDirectives)
          self.default_directive    = {}.extend(DefaultDirective)
          self.excluded_paths       = [].extend(ExcludedPaths)

          find_and_load(path: path)
        end
        instance
      end

      # Instantiate a configuration by passing everything in.
      #
      # @param  directory_directives [Hash] for instance:
      #   { Pathname("spec/samples/three_clean_files/") =>
      #     { Reek::Smells::UtilityFunction => { "enabled" => false } } }
      # @param  default_directive [Hash] for instance:
      #   { Reek::Smells::IrresponsibleModule => { "enabled" => false } }
      # @param  excluded_paths [Array] for instance:
      #   [ Pathname('spec/samples/two_smelly_files') ]
      #
      # @return [AppConfiguration]
      def self.from_map(directory_directives: {},
                        default_directive: {},
                        excluded_paths: [])
        instance = allocate
        instance.instance_eval do
          self.directory_directives = directory_directives.extend(DirectoryDirectives)
          self.default_directive    = default_directive.extend(DefaultDirective)
          self.excluded_paths       = excluded_paths.extend(ExcludedPaths)
        end
        instance
      end

      def self.default
        from_path path: nil
      end

      def initialize(*)
        raise NotImplementedError,
              'Calling `new` is not supported, please use one of the factory methods'
      end

      # Returns the directive for a given directory.
      #
      # @param source_via [String] - the source of the code inspected
      #
      # @return [Hash] the directory directive for the source or, if there is
      # none, the default directive
      def directive_for(source_via)
        directory_directives.directive_for(source_via) || default_directive
      end

      def path_excluded?(path)
        excluded_paths.include?(path)
      end

      private

      def find_and_load(path: nil)
        configuration_file = ConfigurationFileFinder.find_and_load(path: path)

        configuration_file.each do |key, value|
          case
          when key == EXCLUDE_PATHS_KEY
            excluded_paths.add value
          when smell_type?(key)
            default_directive.add_smell_configuration key, value
          else
            directory_directives.add key, value
          end
        end
      end
    end
  end
end
