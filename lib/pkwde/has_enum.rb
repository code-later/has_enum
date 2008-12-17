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

        self.send("validate", "#{enum_column}_check_for_valid_type_of_enum")
        
        # throws a NameError if Enum Class doesn't exists
        enum_class = options.has_key?(:class_name) ? Object.const_get(options[:class_name].to_s.classify) : Object.const_get(enum_name.to_s.classify)

        # Enum must be a Renum::EnumeratedValue Enum
        raise ArgumentError, "expected Renum::EnumeratedValue" unless enum_class.superclass == Renum::EnumeratedValue

        define_method("#{enum_name}") do
          begin
            return self[enum_column] ? enum_class.const_get(self[enum_column]) : nil
          rescue NameError => e
            return nil
          end
        end
        
        define_method("#{enum_column}=") do |enum_literal|
          unless enum_literal == self[enum_column]
            self[enum_column] = enum_literal
            @enum_changed = true
          end
        end

        define_method("#{enum_name}=") do |enum_to_set|
          # This ensures backwards compability with the renum gem. In the
          # +pkwde-renum+ gem this comparsion bug is already fixed.
          if enum_to_set.kind_of?(enum_class) && enum_class.include?(enum_to_set)
            unless enum_to_set == self.send(enum_name)
              self[enum_column] = enum_to_set.name
              @enum_changed = true
            end
          else
            raise ArgumentError, "expected #{enum_class}, got #{enum_to_set.class}"
          end
        end

        define_method("#{enum_name}_has_changed?") do
          !!@enum_changed
        end
        
        define_method("#{enum_column}_check_for_valid_type_of_enum") do
          return true if self[enum_column].nil?
          begin
            enum_class.const_get(self[enum_column])
          rescue NameError => e
            self.errors.add(enum_column.to_sym, "Wrong type '#{self[enum_column]}' for enum '#{enum_name}'")
            return false
          end
          return true
        end
        
      end

    end
  end
end