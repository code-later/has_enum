require File.dirname(__FILE__) + '/test_helper'

class HasEnumTest < Test::Unit::TestCase

  def setup
    setup_db
  end

  def teardown
    teardown_db
  end

  def test_should_have_enum
    assert ClassWithEnum.respond_to?(:has_enum)
    product_enum = ClassWithEnum.new(:product => Product::Silver)
    assert_equal Product::Silver, product_enum.product
  end

  def test_should_have_enum_column_value_set_to_enum_name
    product_enum = ClassWithEnum.new
    product_enum.product = Product::Gold
    assert_equal Product::Gold.name, product_enum.product_type
  end

  def test_should_accept_only_defined_enums
    product_enum = ClassWithEnum.new

    assert_raise(ArgumentError) { product_enum.product = Fakes::NOT_DEFINIED }
    assert_raise(ArgumentError) { product_enum.product = 1 }
    assert_raise(ArgumentError) { product_enum.product = "Product::Titanium" }
    assert_raise(ArgumentError) { product_enum.product = Product }
    assert_raise(ArgumentError) { product_enum.product = nil }
    assert_raise(ArgumentError) { product_enum.product = :symbol }
  end

  def test_should_not_set_enum_in_setter_if_new_enum_is_equal_to_current_enum
    product_enum = ClassWithEnum.new(:product => Product::Silver)
    assert product_enum.product=Product::Gold
  end

  def test_should_have_custom_column_name
    enum_with_custom_column_name = ClassWithCustomNameEnum.new
    enum_with_custom_column_name.product = Product::Gold
    assert_equal Product::Gold, enum_with_custom_column_name.product
  end

  def test_should_mark_enum_as_changed_if_enum_column_was_set_directly
    product_enum = ClassWithEnum.new
    assert !product_enum.product_has_changed?
    product_enum.product_type = "Gold"
    assert product_enum.product_has_changed?
  end

  def test_should_only_change_enum_column_if_other_value_is_set
    product_enum = ClassWithEnum.new
    product_enum.product_type = "Gold"
    product_enum.instance_variable_set("@enum_changed", false)
    product_enum.product_type = "Gold"
    assert !product_enum.product_has_changed?
  end

  def test_should_have_custom_column_value_set_to_enum_name
    enum_with_custom_column_name = ClassWithCustomNameEnum.new
    enum_with_custom_column_name.product = Product::Gold
    assert_equal Product::Gold.name, enum_with_custom_column_name.product_enum
  end

  def test_should_raise_class_not_found_exception_if_enum_class_not_found
    assert_raise(NameError) { ClassWithoutEnum.has_enum :foo }
  end

  def test_should_raise_argument_error_if_enum_is_no_renum_enum
    assert_raise(ArgumentError) { ClassWithoutEnum.has_enum :array }
  end
  
  def test_should_know_if_enum_has_changed
    product_enum = ClassWithEnum.new(:product => Product::Silver)
    assert product_enum.product_has_changed?
    product_enum.save
    product_enum.reload
    product_enum.product = Product::Gold
    assert product_enum.product_has_changed?
  end
  
  def test_should_not_fail_if_no_enum_was_set_yet
    enum_mixin = ClassWithEnum.new
    assert_nothing_raised(TypeError) { enum_mixin.product }
  end
  
  def test_should_not_change_if_same_enum_was_assigned
    enum_mixin = ClassWithEnum.new(:product => Product::Silver)
    enum_mixin.save
    enum_mixin.reload
    enum_mixin.product = Product::Silver
    assert !enum_mixin.product_has_changed?
  end
  
  def test_should_have_reset_changed_state_after_save
    enum_mixin = ClassWithEnum.new(:product => Product::Silver)
    enum_mixin.save
    enum_mixin.reload
    assert !enum_mixin.product_has_changed?
  end
  
  def test_should_not_be_able_to_set_invalid_enum
    enum_mixin = ClassWithEnum.new
    assert_raise(NameError) { enum_mixin.product = Product::Platin }
  end
  
  def test_should_not_be_able_to_set_invalid_enum
    enum_mixin = ClassWithEnum.new
    enum_mixin[:product_type] = "Platin"
    enum_mixin.valid?
    assert enum_mixin.errors.on(:product_type)
  end
  
  def test_should_not_return_validation_error_if_enum_is_nil
    enum_mixin = ClassWithEnum.new
    enum_mixin.valid?
    assert_nil enum_mixin.errors.on(:product_type)
  end
  
  def test_should_return_nil_if_enum_is_of_wrong_type
    enum_mixin = ClassWithEnum.new
    enum_mixin[:product_type] = "Platin"
    assert_nil enum_mixin.product
  end
  
end