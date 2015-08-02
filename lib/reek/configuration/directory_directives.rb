require_relative './configuration_validator'

module Reek
  module Configuration
    #
    # Hash extension for directory directives.
    #
    module DirectoryDirectives
      include ConfigurationValidator

      # Returns the directive for a given source.
      #
      # @param source_via [String] - the source of the code inspected
      #
      # @return [Hash | nil] the configuration for the source or nil
      def directive_for(source_via)
        return unless source_via
        source_base_dir = Pathname.new(source_via).dirname
        hit = best_match_for source_base_dir
        self[hit]
      end

      # Adds a directive.
      #
      # @param path [Pathname] - the path
      # @param config [Hash] - the configuration
      #
      # @return [nil]
      def add(path, config)
        with_valid_directory(path) do |directory|
          self[directory] = config.each_with_object({}) do |(key, value), hash|
            abort(error_message_for_invalid_smell_type(key)) unless smell_type?(key)
            hash[Reek::Smells.const_get(key)] = value
          end
        end
      end

      private

      def best_match_for(source_base_dir)
        keys.
          select { |pathname| source_base_dir.to_s =~ /#{pathname}/ }.
          max_by { |pathname| pathname.to_s.length }
      end

      def error_message_for_invalid_smell_type(klass)
        "You are trying to configure smell type #{klass} but we can't find one with that name.\n" \
          "Please make sure you spelled it right (see 'config/defaults.reek' in the reek\n" \
          'repository for a list of all available smell types.'
      end
    end
  end
end
