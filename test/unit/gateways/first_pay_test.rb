require File.dirname(__FILE__) + '/../../test_helper'

class FirstPayTest < Test::Unit::TestCase
  def setup
    @gateway = FirstPayGateway.new(:login => 'login', :password => 'password')
    
    @credit_card = credit_card
    @amount = 100
    
    @options = { 
      :order_id => '1',
      :billing_address => address,
      :description => 'Store Purchase',
      :ip => '127.0.0.1',
      :email => 'test@test.com'
    }
  end
  
  def test_successful_purchase
    @gateway.expects(:ssl_post).returns(successful_purchase_response)
    
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_success response
    
    # Replace with authorization number from the successful response
    assert_equal '056708', response.authorization
    assert response.test?
  end

  def test_unsuccessful_request
    @gateway.expects(:ssl_post).returns(failed_purchase_response)
    
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_failure response
    assert_equal('DECLINE', response.message)
    assert response.test?
  end
  
  def test_error_on_purchase_request
    @gateway.expects(:ssl_post).returns(error_response)
    
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert ! response.success?
    assert_equal('704-MISSING BASIC DATA TYPE:card, exp, zip, addr, member, amount', response.message)
    assert response.test?
  end
  
  
  private
  
  def successful_purchase_response
    "CAPTURED:056708:NA:X:Jun 02 2009:241:NLS:NLS:NLS:57097598:9999:NA:NA:NA:NA:NA:NA:NA"
  end
  
  def failed_purchase_response
    "NOT CAPTURED:DECLINE:NA:NA:Dec 11 2003:278654:NLS:NLS:NLS:53147611:200312111612:NA:NA:NA:NA:NA:NA"
  end
  
  def error_response
    '!ERROR! 704-MISSING BASIC DATA TYPE:card, exp, zip, addr, member, amount'
  end
end
