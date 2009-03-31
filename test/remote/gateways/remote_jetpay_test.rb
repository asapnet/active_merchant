require File.dirname(__FILE__) + '/../../test_helper'

class RemoteJetpayTest < Test::Unit::TestCase
  
  def setup
    @gateway = JetpayGateway.new(fixtures(:jetpay))
    
    @credit_card = credit_card('4000300020001000')
    @declined_card = credit_card('4000300020001000')
    
    @options = {}
    
#    @options = { 
#      :order_id => '1',
#      :billing_address => address,
#      :description => 'Store Purchase'
#    }
  end
  
  def test_successful_purchase
    assert response = @gateway.purchase(9900, @credit_card, @options)
    assert_success response
    assert_equal "APPROVED", response.message
    assert_not_nil response.authorization
    assert_not_nil response.params["transaction_id"]
  end
  
  def test_unsuccessful_purchase
    assert response = @gateway.purchase(5205, @declined_card, @options)
    assert_failure response
    assert_equal "Do not honor.", response.message
    assert_not_nil response.params["transaction_id"]
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
#
#  def test_failed_capture
#    assert response = @gateway.capture(@amount, '')
#    assert_failure response
#    assert_equal 'REPLACE WITH GATEWAY FAILURE MESSAGE', response.message
#  end
#
#  def test_invalid_login
#    gateway = JetpayGateway.new(
#                :login => '',
#                :password => ''
#              )
#    assert response = gateway.purchase(@amount, @credit_card, @options)
#    assert_failure response
#    assert_equal 'REPLACE WITH FAILURE MESSAGE', response.message
#  end
  
  
end
