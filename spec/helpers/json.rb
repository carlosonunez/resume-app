module RSpecHelpers
  module JSONHelper
    def self.sort_objects_by_keys(objects)
      if objects.is_a?(Hash)
        sort_hash_by_keys(objects)
      elsif objects.is_a?(Array)
        sorted_array = []
        objects.each do |object|
          sorted_array.push sort_objects_by_keys(object)
        end
        sorted_array
      else
        raise "ERROR: Invalid type #{type(objects)} not supported."
      end
    end

    def self.sort_hash_by_keys(hash)
      sorted_hash = {}
      sorted_keys = hash.keys.sort
      sorted_keys.each do |key|
        sorted_hash[key] = hash[key]
      end
      sorted_hash
    end

    private_class_method :sort_hash_by_keys
  end
end
