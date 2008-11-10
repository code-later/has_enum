require 'renum'
require 'pkwde/has_enum'

ActiveRecord::Base.send :include, Pkwde::HasEnum
