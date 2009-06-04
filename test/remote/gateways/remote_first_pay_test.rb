require File.dirname(__FILE__) + '/../../test_helper'

# TIMEOUT
# If the amount is 7.18
#       Simulator will sleep for 31 seconds causing a timeout
#  
# RESPONSE CODE
# CVV = 321
#        N7 - DECLINE FOR CVV2 FAILURE
# Amount > 500.00
#        51 - INSUFFICIENT FUNDS
# else
#        00
#  
# CVV RESPONSE      
# CVV = 123
#       N
# CVV < 200
#       M
# CVV < 400
#       N
# CVV < 600
#       P
# CVV < 800
#       S
# ELSE
#       U
#  
# AVS RESPONSE
# zip = 12345
#       N
# ELSE
#       X
# 

class RemoteFirstPayTest < Test::Unit::TestCase
  def setup
    # PTODO - clear credentials
    @gateway = FirstPayGateway.new(:login => '38-1000', :password => '80350243')
    
    @amount = 100
    @credit_card = credit_card('4111111111111111', {:first_name => 'Test', :last_name => 'Person'})
    @declined_card = credit_card('4111111111111111')
    
    @options = { 
      :order_id => '1',
      :billing_address => address({:name => 'Test Person', :city => 'New York', :state => 'NY', :zip => '10002', :country => 'US'}),
      :description => 'Test Purchase'
    }
  end
  
  def test_successful_purchase
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_success response
    assert_equal('CAPTURED', response.message)
  end

  def test_unsuccessful_purchase
    # > $500 results in decline
    @amount = 51000
    assert response = @gateway.purchase(@amount, @declined_card, @options)
    assert_failure response
    assert_equal("51-INSUFFICIENT FUNDS", response.message)
  end
  
  def test_invalid_login
    gateway = FirstPayGateway.new(:login => '', :password => '')
    assert response = gateway.purchase(@amount, @credit_card, @options)
    assert_failure response
    assert_equal '703-INVALID VENDOR ID AND PASS CODE', response.message
  end
  
  def test_successful_credit
    # purchase first
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_success response
    assert_equal('CAPTURED', response.message)
    assert_not_nil(response.transactionid)
    assert_not_nil(response.authorization)
    
    
  end
  
end
