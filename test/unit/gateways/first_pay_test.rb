require File.dirname(__FILE__) + '/../../test_helper'

class FirstPayTest < Test::Unit::TestCase
  def setup
    @gateway = FirstPayGateway.new(:login => 'login', :password => 'password')
    
    @credit_card = credit_card
    @amount = 100
    
    @options = { 
      :order_id => '1',
      :billing_address => address,
      :description => 'Store Purchase'
    }
  end
  
  def test_successful_purchase
    @gateway.expects(:ssl_post).returns(successful_purchase_response)
    
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_instance_of 
    assert_success response
    
    # Replace with authorization number from the successful response
    assert_equal '', response.authorization
    assert response.test?
  end

  def test_unsuccessful_request
    @gateway.expects(:ssl_post).returns(failed_purchase_response)
    
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_failure response
    assert response.test?
  end
  
  
  private
  
  # Place raw successful response from gateway here
  def successful_purchase_response
    # from API docs pg 16
    "CAPTURED:199641568:NA:A:Dec 11 2003:278653:NLS:NLS:NLS:53147609:200312111612:NA:NA:NA:NA:NA"
  end
  
  # Place raw failed response from gateway here
  def failed_purcahse_response
    # from API docs pg 16
    "NOT CAPTURED:DECLINE:NA:NA:Dec 11 2003:278654:NLS:NLS:NLS:53147611:200312111612:NA:NA:NA:NA:NA:NA"
  end
end
