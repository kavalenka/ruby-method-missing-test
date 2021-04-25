# frozen_string_literal: true

require 'json'
require_relative './common_methods'

class JsonDb
  include CommonMethods

  def initialize(json_filename)
    @json_filename = json_filename
  end

  attr_reader :json_filename

  def data
    @data ||= JSON.parse(IO.read(json_filename))
  end

  private

  # Use this method to store updated properties on disk
  def serialize
    IO.write(json_filename, data.to_json)
  end

  def method_missing(method_name, *args)
    method_str = method_name.to_s

    if method_str.end_with? '='
      data[method_str.gsub('=', '')] = args.first
      serialize

      args.first
    else
      add_class_attribute(method_str, data)

      updated_data = data[method_str]
      serialize

      updated_data
    end
  end
end

class Hash
  include CommonMethods

  undef_method :class

  private

  def method_missing(method_name, *args)
    method_str = method_name.to_s

    if method_str == 'class'
      create_class(self['class_name'])
    elsif method_str.include? '='
      self[method_str.gsub('=', '')] = args.first
    else
      add_class_attribute(method_str, self)

      self[method_str]
    end
  end

  def create_class(class_name)
    Object.const_set(class_name, Class.new) unless Object.const_defined?(class_name)

    Object.const_get(class_name)
  end
end
