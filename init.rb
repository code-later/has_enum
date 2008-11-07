require 'renum'
require 'has_enum'

ActiveRecord::Base.send :include, HasEnum
