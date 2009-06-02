module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class FirstPayGateway < Gateway
      # both URLs are IP restricted
      TEST_URL = 'https://apgcert.first-pay.com/AcqENGIN/SecureCapture'
      LIVE_URL = 'https://acqengin.first-pay.com/AcqENGIN/SecureCapture'
      
      # The countries the gateway supports merchants from as 2 digit ISO country codes
      self.supported_countries = ['US']
      
      # The card types supported by the payment gateway
      self.supported_cardtypes = [:visa, :master, :american_express, :discover]
      
      # The homepage URL of the gateway
      self.homepage_url = 'http://www.first-pay.com'
      
      # The name of the gateway
      self.display_name = 'First Pay'
      
      # all transactions are in cents
      self.money_format = :cents
      
      ACTIONS = {
        'sale' => 1

#        :authorization => 'auth',
#        :purchase => 'sale',
#        :capture => 'capture',
#        :void => 'void',
#        :credit => 'credit',
#        :refund => 'refund'
      }
      
      def initialize(options = {})
        requires!(options, :login, :password)
        @options = options
        super
      end  
      
      def authorize(money, creditcard, options = {})
        post = {}
        add_invoice(post, options)
        add_creditcard(post, creditcard)        
        add_address(post, creditcard, options)        
        add_customer_data(post, options)
        
        commit('authonly', money, post)
      end
      
      def purchase(money, creditcard, options = {})
        post = {}
        add_invoice(post, options)
        add_creditcard(post, creditcard)
        add_address(post, creditcard, options)
        add_customer_data(post, options)
        
        commit('sale', money, post)
      end                       
    
      def capture(money, authorization, options = {})
        commit('capture', money, post)
      end
      
      
      private
      
      def add_customer_data(post, options)
        post[:cardip] = options[:ip]
        post[:email] = options[:email]
      end
      
      def add_address(post, creditcard, options)
        if billing_address = options[:billing_address] || options[:address]
          post[:addr]     = billing_address[:address1] + ' ' + billing_address[:address2].to_s
          post[:city]     = billing_address[:city]
          post[:state]    = billing_address[:state]
          post[:zip]      = billing_address[:zip]                             
          post[:country]  = billing_address[:country]
        end
      end
      
      def add_invoice(post, options)
        post[:trackid] = rand(Time.now)
      end
      
      def add_creditcard(post, creditcard)
        post[:member] = creditcard.first_name + " " + creditcard.last_name
        post[:card] = creditcard.number
        post[:exp] = expdate(creditcard)
      end
      
      def expdate(credit_card)
        year  = sprintf("%.4i", credit_card.year)
        month = sprintf("%.2i", credit_card.month)

        "#{month}#{year[-2..-1]}"
      end
      
      def commit(action, money, post)
        response = parse( ssl_post(test? ? TEST_URL : LIVE_URL, post_data(action, post, money)) )
                
        Response.new(response[:response] == 'CAPTURED', response[:message], response,
          :test => test?,
          :authorization => response[:authorization],
          :avs_result => { :code => response[:avsresponse] },
          :cvv_result => response[:cvvresponse])
      end
      
      def parse(body)
        response = {}
        
        # check for an error first
        if body.include?('!ERROR!')
          response[:response] = 'ERROR'
          response[:message] = error_message_from(body)
        else
          # a capture / not captured response will be : delimited
          split = body.split(':')
          response[:response] = split[0]
          
          # a CAPTURED response will have an auth number
          # see pg 16 of docs
          if response[:response] == 'CAPTURED'
            response[:message] = 'CAPTURED'
            response[:authorization] = split[1]
            response[:transactionid] = split[9]
            response[:avsresponse] = split[3]
            response[:cvvresponse] = split[17]
          else
            # NOT CAPTURED response
            response[:message] = split[1]
            response[:transactionid] = split[9]
          end
        end
        
        return response
      end
      
      def error_message_from(response)
        # error messages use this format - '!ERROR! 704-MISSING BASIC DATA TYPE:card, exp, zip, addr, member, amount\n'
        response.split("! ")[1].chomp
      end
      
      def post_data(action, post, money)
        post[:vid]        = @options[:login]  
        post[:password]   = @options[:password]
        post[:type]       = ACTIONS[action]
        post[:amount]     = amount(money)
        
        return post.collect { |key, value| "#{key}=#{CGI.escape(value.to_s)}" unless value.nil? }.join("&")
      end
    end
  end
end

