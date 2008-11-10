module Pkwde
  module HasEnum
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

       # Use like this
       #
       #   class Furniture
       #     has_enum :colors, :column_name => :custom_color_type
       #   end
      def has_enum(enum_name, options={})

        # Reset changed-Flag after any save
        after_save '@enum_changed = false'

        enum_column = options.has_key?(:column_name) ? options[:column_name].to_s : "#{enum_name}_type"

        # throws a NameError if Enum Class doesn't exists
        enum_class = Object.const_get(enum_name.to_s.classify)

        # Enum must be a Renum::EnumeratedValue Enum
        raise ArgumentError, "expected Renum::EnumeratedValue" unless enum_class.superclass == Renum::EnumeratedValue

        define_method("#{enum_name}") do
          return self[enum_column] ? enum_class.const_get(self[enum_column]) : nil
        end

        define_method("#{enum_name}=") do |enum_to_set|
          if enum_to_set.kind_of?(enum_class) && enum_class.include?(enum_to_set)
            unless enum_to_set == self.send(enum_name)
              self[enum_column] = enum_to_set.name
              @enum_changed = true
            else
              @enum_changed = false
            end
          else
            raise ArgumentError, "expected #{enum_class}, got #{enum_to_set.class}"
          end
        end

        define_method("#{enum_name}_has_changed?") do
          !!@enum_changed
        end

      end

    end
  end
end