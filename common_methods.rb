# frozen_string_literal: true

require 'active_support/inflector'

module CommonMethods
  def add_class_attribute(method, data)
    return unless data[method].is_a? Array

    data[method].each do |object|
      object['class_name'] = method.singularize.capitalize
    end
  end
end
