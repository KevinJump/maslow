require_relative '../../test_helper'

class NeedHelperTest < ActiveSupport::TestCase
  include NeedHelper

  context "format_need_goal" do
    should "capitalize the first letter of a need goal" do
      assert_equal "Pay my car tax", format_need_goal("pay my car tax")
    end

    should "not modify the remainder of the string" do
      assert_equal "Find out about VAT", format_need_goal("find out about VAT")
      assert_equal "Apply for Carers' Allowance", format_need_goal("apply for Carers' Allowance")
    end

    should "return an empty string if provided with one" do
      assert_equal "", format_need_goal("")
    end
  end

  context "format_field_value" do
    should "return the field value when present" do
      assert_equal "foo", format_field_value("foo")
    end

    should "return 'blank' when empty" do
      output = format_field_value("")

      assert_equal "<em>blank</em>", output
      assert output.html_safe?
    end

    should "return 'blank' when nil" do
      output = format_field_value(nil)

      assert_equal "<em>blank</em>", output
      assert output.html_safe?
    end
  end

  context "format_field_name" do
    should "return a humanized and capitalized field name" do
      assert_equal "Organisation Ids", format_field_name("organisation_ids")
    end
  end

  context "criteria_with_blank_value" do
    should "return an array with a blank string if criteria is empty" do
      assert_equal [""], criteria_with_blank_value([])
    end

    should "return the criteria if values are present" do
      assert_equal ["1","2"], criteria_with_blank_value(["1","2"])
    end
  end

  context "format_need_impact" do
    should "lookup the translation for the provided impact string" do
      expects(:t)
        .with("needs.show.impact.has_serious_consequences_for_the_majority_of_your_users")
        .returns("it would have serious consequences")

      output = format_need_impact("has serious consequences for the majority of your users")
      assert_equal "If GOV.UK didn't meet this need it would have serious consequences.", output
    end
  end

  context "calculate_percentage" do
    should "accept two integers and return the percentage as a string with one decimal place" do
      assert_equal "65.4%", calculate_percentage(6.543, 10)
    end

    should "return the percentage as a string with no decimal places when first decimal place is zero" do
      assert_equal "50%", calculate_percentage(5, 10)
    end

    should "return nil if any provided values are nil" do
      assert_nil calculate_percentage(10, nil)
      assert_nil calculate_percentage(nil, 10)
    end

    should "return nil if the denominator is zero" do
      assert_nil calculate_percentage(10, 0)
    end
  end

  context "format_friendly_integer" do
    should "return a number under 10000 in its original form" do
      assert_equal "999", format_friendly_integer(999)
      assert_equal "1500", format_friendly_integer(1500)
      assert_equal "2837", format_friendly_integer(2837)
      assert_equal "9999", format_friendly_integer(9999)
    end

    should "return numbers above 10000 using 'k' and up to three significant figures" do
      assert_equal "10k", format_friendly_integer(10000)
      assert_equal "15k", format_friendly_integer(15000)
      assert_equal "25.3k", format_friendly_integer(25336)
      assert_equal "720k", format_friendly_integer(720123)
    end

    should "return numbers above 1 million using 'm' and up to three significant figures" do
      assert_equal "6m", format_friendly_integer(6000000)
      assert_equal "6.1m", format_friendly_integer(6100000)
      assert_equal "6.32m", format_friendly_integer(6320303)
      assert_equal "63.5m", format_friendly_integer(63541234)
      assert_equal "635m", format_friendly_integer(635412340)
    end
  end

  context "paginate_needs" do
    should "return nil when the need parameter is nil" do
      assert_nil paginate_needs(nil)
    end

    should "return nil when the pagination metadata is missing from the response" do
      need = OpenStruct.new(current_page: nil, pages: 5, page_size: 10)
      assert_nil paginate_needs(need)

      need = OpenStruct.new(current_page: 1, pages: nil, page_size: 10)
      assert_nil paginate_needs(need)

      need = OpenStruct.new(current_page: 1, pages: 5, page_size: nil)
      assert_nil paginate_needs(need)
    end

    should "initialize an paginator with the correct values" do
      stub_paginator = stub(:to_s => "pagination")
      Kaminari::Helpers::Paginator.expects(:new)
        .with(self, has_entries(
            current_page: 3,
            total_pages: 5,
            per_page: 10,
            param_name: "page",
            remote: false
          ))
        .returns(stub_paginator)

      need = OpenStruct.new(current_page: 3, pages: 5, page_size: 10)
      assert_equal "pagination", paginate_needs(need)
    end
  end
end
