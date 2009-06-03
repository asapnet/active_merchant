require File.dirname(__FILE__) + '/../../test_helper'

class RemoteFirstPayTest < Test::Unit::TestCase
  def setup
    # PTODO - clear credentials
    @gateway = FirstPayGateway.new(:login => '38-1000', :password => '80350243')
    
    @amount = 100
    @credit_card = credit_card('4111111111111111', {:first_name => 'Test', :last_name => 'Person'})
    @declined_card = credit_card('4000300011112220')
    
    @options = { 
      :order_id => '1',
      :billing_address => address({:name => 'Test Person', :city => 'New York', :state => 'NY', :zip => '10002', :country => 'US'}),
      :description => 'Test Purchase'
    }
  end
  
  def test_successful_purchase
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_success response
    assert_equal 'CAPTURED', response.message
  end

  def xtest_unsuccessful_purchase
    assert response = @gateway.purchase(@amount, @declined_card, @options)
    assert_failure response
    assert_equal 'REPLACE WITH FAILED PURCHASE MESSAGE', response.message
  end

#  def test_authorize_and_capture
#    amount = @amount
#    assert auth = @gateway.authorize(amount, @credit_card, @options)
#    assert_success auth
#    assert_equal 'Success', auth.message
#    assert auth.authorization
#    assert capture = @gateway.capture(amount, auth.authorization)
#    assert_success capture
#  end

#  def test_failed_capture
#    assert response = @gateway.capture(@amount, '')
#    assert_failure response
#    assert_equal 'REPLACE WITH GATEWAY FAILURE MESSAGE', response.message
#  end

  def xtest_invalid_login
    gateway = FirstPayGateway.new(:login => '', :password => '')
    assert response = gateway.purchase(@amount, @credit_card, @options)
    assert_failure response
    assert_equal '703-INVALID VENDOR ID AND PASS CODE', response.message
  end
end
