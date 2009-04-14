module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module CreditCardFormatting
      
      # This method is used to format numerical information pertaining to credit cards. 
      # 
      #   format(2005, :two_digits)  # => "05"
      #   format(05,   :four_digits) # => "0005"
      def format(number, option)
        return '' if number.blank?
        
        case option
          when :two_digits
            return number.to_s if number.to_s.length == 2
            
            sprintf("%.2i", number)[-2..-1]
          when :four_digits
            return number.to_s if number.to_s.length == 4
            
            sprintf("%.4i", number)[-4..-1]
          else number
        end
      end
      
    end
  end
end