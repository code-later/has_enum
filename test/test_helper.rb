require 'test/unit'

require 'rubygems'
require 'mocha'
require 'active_record'

$:.unshift File.dirname(__FILE__) + '/../lib'
require File.dirname(__FILE__) + '/../init'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
ActiveRecord::Migration.verbose = false

def setup_db
  ActiveRecord::Base.silence do
    ActiveRecord::Schema.define(:version => 1) do
      create_table :class_with_enums do |t|
        t.column :title, :string
        t.column :product_type, :string
        t.column :created_at, :datetime
        t.column :updated_at, :datetime
      end

      create_table :class_without_enums do |t|
        t.column :title, :string
        t.column :created_at, :datetime
        t.column :updated_at, :datetime
      end

      create_table :class_with_custom_name_enums do |t|
        t.column :title, :string
        t.column :product_enum, :string
        t.column :created_at, :datetime
        t.column :updated_at, :datetime
      end
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

enum :Fakes, [:NOT_DEFINIED]
enum :Product, [:Silver, :Gold, :Titanium]

setup_db # Init the database for class creation

class ClassWithEnum < ActiveRecord::Base
  has_enum :product
end

class ClassWithoutEnum < ActiveRecord::Base; end

class ClassWithCustomNameEnum < ActiveRecord::Base
  has_enum :product, :column_name => :product_enum
end

teardown_db # And drop them right afterwards
