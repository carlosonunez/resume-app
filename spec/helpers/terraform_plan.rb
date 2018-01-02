# frozen_string_literal: true

require 'json'

module RSpecHelpers
  module TerraformPlan
    STRING_ARGUMENT_PATTERN ||= /^\w+$/
    ARRAY_ARGUMENT_PATTERN ||= /^\w+\.\d+$/
    ENUMERABLE_COUNT_PATTERN ||= '^\w+\.\#$' # messes up vim

    # Convert a JSON formatted Terraform plan into a Ruby hash.
    def self.from_json(serialized_json)
      plan_hash = Hash.new { |hash, key| hash[key] = {} }
      plan_json = JSON.parse(serialized_json)
      plan_json.each_key do |terraform_resource|
        resource_values = plan_json[terraform_resource]
        if resource_values.is_a? Hash
          plan_hash[terraform_resource].merge!(expand(resource_values))
        else
          plan_hash[terraform_resource] = resource_values
        end
      end
      plan_hash
    end

    # Expand arrays and maps inside of Terraform plans into actual Ruby
    # Arrays and Maps.
    def self.expand(resource_hash)
      new_resource_hash = {}
      new_resource_hash.merge!(get_arguments_with_string_values(resource_hash))
      new_resource_hash.merge!(get_arguments_with_array_values(resource_hash))
      new_resource_hash.merge!(get_arguments_with_map_values(resource_hash))
      new_resource_hash
    end

    # Filter arguments within a Terraform resource JSON by those that
    # accept strings.
    def self.get_arguments_with_string_values(resource_hash)
      resource_hash.select do |argument|
        argument.match?(TerraformPlan::STRING_ARGUMENT_PATTERN)
      end.clone
    end

    # Convert Terraform resource Array arguments into Ruby arguments.
    # e.g. 'parameter.0 = bar' => 'parameter = [ 'bar' ]
    def self.get_arguments_with_array_values(resource_hash)
      subhash = {}
      array_arguments = resource_hash.select do |argument_key|
        argument_key.match?(TerraformPlan::ARRAY_ARGUMENT_PATTERN)
      end
      array_arguments.each_key do |argument_key_with_id|
        argument_key = argument_key_with_id.split('.')[0]
        argument_value = resource_hash.delete(argument_key_with_id)
        subhash[argument_key] ||= []
        subhash[argument_key].push(argument_value)
      end
      subhash
    end

    # Convert Terraform resource Map arguments into Ruby Map arrays.
    # e.g. 'parameter.0.foo = bar, parmaeter.1.foo = bar' =>
    # parameter [ { id: 0, foo: bar }, { id: 1, foo: bar } ]
    def self.get_arguments_with_map_values(resource_hash)
      subhash = {}
      map_arguments = resource_hash.select do |argument_key|
        !argument_key.match?(TerraformPlan::STRING_ARGUMENT_PATTERN) &&
          !argument_key.match?(TerraformPlan::ARRAY_ARGUMENT_PATTERN) &&
          !argument_key.match?(TerraformPlan::ENUMERABLE_COUNT_PATTERN)
      end
      map_arguments.each_key do |argument_key_with_ids|
        expand_argument_map!(argument_key_with_ids, resource_hash, subhash)
      end
      subhash
    end

    # Expand Terraform resource argument maps into Arrays of Maps.
    # NOTE: Because of the difficulty involved in dealing with nested arrays
    # and Maps inside of Maps, this level of expansion is not supported
    # at the moment.
    def self.expand_argument_map!(argument_key_with_ids,
                                  resource_hash,
                                  subhash)
      fail_if_resource_argument_is_deeply_nested!(argument_key_with_ids)
      argument_key, argument_key_id, argument_hash_parameter =
        argument_key_with_ids.split('.')[0..2]
      argument_value = resource_hash[argument_key_with_ids]
      subhash[argument_key] ||= []
      target_argument = find_map_arg_to_manipulate(subhash,
                                                   argument_key,
                                                   argument_key_id)
      if target_argument.empty?
        subhash[argument_key].push(id: argument_key_id,
                                   argument_hash_parameter => argument_value)
      else
        target_argument[0][argument_hash_parameter] = argument_value
      end
    end

    def self.find_map_arg_to_manipulate(hash, argument_key, argument_key_id)
      hash[argument_key].select do |parameter|
        parameter[:id] == argument_key_id
      end
    end

    def self.fail_if_resource_argument_is_deeply_nested!(argument_key_with_ids)
      error_message = "Argument #{argument_key_with_ids} has nested maps. " \
        'This is not currently supported'
      raise error_message if argument_key_with_ids.split('.').count > 3
    end

    private_class_method :expand,
                         :get_arguments_with_string_values,
                         :get_arguments_with_array_values,
                         :expand_argument_map!,
                         :fail_if_resource_argument_is_deeply_nested!,
                         :find_map_arg_to_manipulate
  end
end
