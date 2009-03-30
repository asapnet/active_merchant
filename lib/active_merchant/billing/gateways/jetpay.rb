module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class JetpayGateway < Gateway
      TEST_URL = 'https://test1.jetpay.com/jetpay'
      LIVE_URL = 'https://gateway17.jetpay.com/jetpay'
      
      # The countries the gateway supports merchants from as 2 digit ISO country codes
      self.supported_countries = ['US']
      
      # The card types supported by the payment gateway
      self.supported_cardtypes = [:visa, :master, :american_express]
      
      # The homepage URL of the gateway
      self.homepage_url = 'http://www.jetpay.com/'
      
      # The name of the gateway
      self.display_name = 'JetPay'
      
      # all transactions are in cents
      self.money_format = :cents
      
      def initialize(options = {})
        requires!(options, :login)
        @options = options
        super
      end  
      
      def purchase(money, credit_card, options = {})
        commit('sale', build_sale_request(money, credit_card, options))
      end
      
      def authorize(money, creditcard, options = {})
        post = {}
        add_invoice(post, options)
        add_creditcard(post, creditcard)        
        add_address(post, creditcard, options)        
        add_customer_data(post, options)
        
        commit('authonly', money, post)
      end
      
      def capture(money, authorization, options = {})
        commit('capt', money, post)
      end
      
      def void(identification, options = {})
        
      end
      
      def credit(money, identification, options = {})
        
      end
      
      
      private
      
      
      def build_xml_request(&block)
        xml = Builder::XmlMarkup.new
        xml.tag! 'JetPay' do
          # The basic values needed for any request
          xml.tag! 'TerminalID', @options[:login]
          xml.tag! 'TransactionID', Utils.generate_unique_id.slice(0, 18)
          
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
      
      def commit(action, request)
        response = parse(ssl_post(test? ? TEST_URL : LIVE_URL, request))
        
        puts response
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






      def add_customer_data(post, options)
      end

      def add_address(post, creditcard, options)
      end
      
      def add_invoice(post, options)
      end
      
      def message_from(response)
      end
      
    end
  end
end

