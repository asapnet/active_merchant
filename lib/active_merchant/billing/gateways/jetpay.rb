module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class JetpayGateway < Gateway
      TEST_URL = 'https://test1.jetpay.com/jetpay'
      LIVE_URL = 'https://gateway17.jetpay.com/jetpay'
      
      # The countries the gateway supports merchants from as 2 digit ISO country codes
      self.supported_countries = ['US']
      
      # The card types supported by the payment gateway
      self.supported_cardtypes = [:visa, :master, :american_express, :discover]
      
      # The homepage URL of the gateway
      self.homepage_url = 'http://www.jetpay.com/'
      
      # The name of the gateway
      self.display_name = 'JetPay'
      
      # all transactions are in cents
      self.money_format = :cents
      
      ACTION_CODE_MESSAGES = {
        "001" =>  "Refer to card issuer.",
        "002" =>  "Refer to card issuer, special condition.",
        "003" =>  "Pick up card.",
        "200" =>  "Deny - Pick up card.",
        "005" =>  "Do not honor.",
        "100" =>  "Deny.",
        "006" =>  "Error.",
        "181" =>  "Format error.",
        "007" =>  "Pickup card, special condition.",
        "104" =>  "Deny - New card issued.",
        "110" =>  "Invalid amount.",
        "014" =>  "Invalid account number (no such number).",
        "111" =>  "Invalid account.",
        "015" =>  "No such issuer.",
        "103" =>  "Deny - Invalid manual Entry 4DBC.",
        "182" =>  "Please wait.",
        "109" =>  "Invalid merchant.",
        "041" =>  "Pick up card (lost card).",
        "043" =>  "Pick up card (stolen card).",
        "051" =>  "Insufficient funds.",
        "052" =>  "No checking account.",
        "105" =>  "Deny - Account Cancelled.",
        "054" =>  "Expired Card.",
        "101" =>  "Expired Card.",
        "183" =>  "Invalid currency code.",
        "057" =>  "Transaction not permitted to cardholder.",
        "115" =>  "Service not permitted.",
        "062" =>  "Restricted card.",
        "189" =>  "Deny - Cancelled or Closed Merchant/SE.",
        "188" =>  "Deny - Expiration date required.",
        "125" =>  "Invalid effective date.",
        "122" =>  "Invalid card (CID) security code.",
        "400" =>  "Reversal accepted.",
        "992" =>  "DECLINE/TIMEOUT.",
        "107" =>  "Please Call Issuer.",
        "025" =>  "Transaction Not Found.",
        "981" =>  "AVS Error.",
        "913" =>  "Invalid Card Type.",
        "996" =>  "Terminal ID Not Found."
      }
      
      def initialize(options = {})
        requires!(options, :login)
        @options = options
        super
      end  
      
      def purchase(money, credit_card, options = {})
        commit(build_sale_request(money, credit_card, options))
      end
      
      def authorize(money, credit_card, options = {})
        commit(build_authonly_request(money, credit_card, options))
      end
      
      def capture(transaction_id)
        commit(build_capture_request(transaction_id))
      end
      
      def void(money, credit_card, transaction_id, authorization)
        commit(build_void_request(money, credit_card, transaction_id, authorization))
      end
      
      def credit(money, identification, options = {})
        
      end
      
      
      private
      
      def build_xml_request(transaction_id = nil, &block)
        xml = Builder::XmlMarkup.new
        xml.tag! 'JetPay' do
          # The basic values needed for any request
          xml.tag! 'TerminalID', @options[:login]
          xml.tag! 'TransactionID', transaction_id.nil? ? Utils.generate_unique_id.slice(0, 18) : transaction_id
          
          yield xml
        end
      end
      
      def build_sale_request(money, credit_card, options)
        build_xml_request do |xml|
          xml.tag! 'TransactionType', 'SALE'
          xml.tag! 'CardNum', credit_card.number
          xml.tag! 'CardExpMonth', format_exp(credit_card.month)
          xml.tag! 'CardExpYear', format_exp(credit_card.year)
          xml.tag! 'TotalAmount', amount(money)
          
          xml.target!
        end
      end
      
      def build_authonly_request(money, credit_card, options)
        build_xml_request do |xml|
          xml.tag! 'TransactionType', 'AUTHONLY'
          xml.tag! 'CardNum', credit_card.number
          xml.tag! 'CardExpMonth', format_exp(credit_card.month)
          xml.tag! 'CardExpYear', format_exp(credit_card.year)
          xml.tag! 'TotalAmount', amount(money)
          
          xml.target!
        end
      end
      
      def build_capture_request(transaction_id)
        build_xml_request(transaction_id) do |xml|
          xml.tag! 'TransactionType', 'CAPT'
        end        
      end
      
      def build_void_request(money, credit_card, transaction_id, authorization)
        build_xml_request(transaction_id) do |xml|
          xml.tag! 'TransactionType', 'VOID'
          xml.tag! 'CardNum', credit_card.number
          xml.tag! 'CardExpMonth', format_exp(credit_card.month)
          xml.tag! 'CardExpYear', format_exp(credit_card.year)
          xml.tag! 'Approval', authorization
          xml.tag! 'TotalAmount', amount(money)
          
          xml.target!
        end        
      end
      
      def commit(request)
        response = parse(ssl_post(test? ? TEST_URL : LIVE_URL, request))
        
        success = success?(response)
        Response.new(success, 
          success ? 'APPROVED' : message_from(response), 
          response, 
          :test => test?, 
          :authorization => authorization_from(response))
      end
      
      def parse(body)
        xml = REXML::Document.new(body)
        
        response = {}
        xml.root.elements.to_a.each do |node|
          parse_element(response, node)
        end
        response
      end
      
      def parse_element(response, node)
        if node.has_elements?
          node.elements.each{|element| parse_element(response, element) }
        else
          response[node.name.underscore.to_sym] = node.text
        end
      end
      
      def format_exp(value)
        "#{format(value, :two_digits)}"
      end
      
      def success?(response)
        response[:action_code] == "000"
      end
      
      def message_from(response)
        ACTION_CODE_MESSAGES[response[:action_code]]
      end
      
      def authorization_from(response)
        response[:approval]
      end
      




      def add_customer_data(post, options)
      end

      def add_address(post, creditcard, options)
      end
      
    end
  end
end

