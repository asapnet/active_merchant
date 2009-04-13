require File.dirname(__FILE__) + '/../../test_helper'

class JetpayTest < Test::Unit::TestCase
  def setup
    @gateway = JetpayGateway.new(:login => 'login')
    
    @credit_card = credit_card
    @amount = 100
    
    @options = {
      :order_id => '1',
      :billing_address => address(:country => 'USA'),
      :shipping_address => address(:country => 'USA'),
      :email => 'test@test.com',
      :ip => '127.0.0.1',
      :order_id => '12345',
      :tax => '7'
    }
  end
  
  def test_successful_purchase
    @gateway.expects(:ssl_post).returns(successful_purchase_response)
    
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_success response
    
    assert_equal 'TEST10', response.authorization
    assert_equal('aa26f0722b49237194', response.params["transaction_id"])
    assert response.test?
  end

  def test_unsuccessful_request
    @gateway.expects(:ssl_post).returns(failed_purchase_response)
    
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_failure response
    assert_equal('7605f7c5d6e8f74deb', response.params["transaction_id"])
    assert response.test?
  end
  
  def test_successful_authorize
    @gateway.expects(:ssl_post).returns(successful_authorize_response)
    
    assert response = @gateway.authorize(@amount, @credit_card, @options)
    assert_success response
    
    assert_equal('502F6B', response.authorization)
    assert_equal('010327153017T10018', response.params["transaction_id"])
    assert response.test?
  end
  
  def test_successful_capture
    @gateway.expects(:ssl_post).returns(successful_capture_response)
    
    assert response = @gateway.capture("010327153017T10018")
    assert_success response
    
    assert_equal('502F6B', response.authorization)
    assert_equal('010327153017T10018', response.params["transaction_id"])
    assert response.test?
  end
  
  def test_successful_void
    # no need for csv
    card = credit_card('4242424242424242', :verification_value => nil)
    
    @gateway.expects(:ssl_post).returns(successful_void_response)
    
    assert response = @gateway.void(9900, card, '010327153x17T10418', '502F7B')
    assert_success response
    
    assert_equal('502F7B', response.authorization)
    assert_equal('010327153x17T10418', response.params["transaction_id"])
    assert response.test?
  end
  
  def test_successful_credit
    # no need for csv
    card = credit_card('4242424242424242', :verification_value => nil)

    @gateway.expects(:ssl_post).returns(successful_credit_response)
    
    # linked credit
    assert response = @gateway.credit(9900, card, '010327153017T10017')
    assert_success response
    
    assert_equal('002F6B', response.authorization)
    assert_equal('010327153017T10017', response.params['transaction_id'])
    assert response.test?
    
    # unlinked credit
    @gateway.expects(:ssl_post).returns(successful_credit_response)
    
    assert response = @gateway.credit(9900, card)
    assert_success response    
  end
  
  
  private
  
  def successful_purchase_response
    <<-EOF
      <JetPayResponse>
        <TransactionID>aa26f0722b49237194</TransactionID>
        <ActionCode>000</ActionCode>
        <Approval>TEST10</Approval>
        <ResponseText>APPROVED</ResponseText>
      </JetPayResponse>
    EOF
  end
  
  def failed_purchase_response
    <<-EOF
      <JetPayResponse>
        <TransactionID>7605f7c5d6e8f74deb</TransactionID>
        <ActionCode>005</ActionCode>
        <ResponseText>DECLINED</ResponseText>
      </JetPayResponse>
    EOF
  end
  
  def successful_authorize_response
    <<-EOF
      <JetPayResponse>
        <TransactionID>010327153017T10018</TransactionID>
        <ActionCode>000</ActionCode>
        <Approval>502F6B</Approval>
        <ResponseText>APPROVED</ResponseText>
      </JetPayResponse>
    EOF
  end
  
  def successful_capture_response
    <<-EOF
      <JetPayResponse>
        <TransactionID>010327153017T10018</TransactionID>
        <ActionCode>000</ActionCode>
        <Approval>502F6B</Approval>
        <ResponseText>APPROVED</ResponseText>
      </JetPayResponse>
    EOF
  end
  
  def successful_void_response
    <<-EOF
      <JetPayResponse>
        <TransactionID>010327153x17T10418</TransactionID>
        <ActionCode>000</ActionCode>
        <Approval>502F7B</Approval>
        <ResponseText>VOID PROCESSED</ResponseText>
      </JetPayResponse>
    EOF
  end
  
  def successful_credit_response
    <<-EOF
      <JetPayResponse>
        <TransactionID>010327153017T10017</TransactionID>
        <ActionCode>000</ActionCode>
        <Approval>002F6B</Approval>
        <ResponseText>APPROVED</ResponseText>
      </JetPayResponse>
    EOF
  end
end
