require 'support/delegate_support' # see http://groups.google.com/group/activemerchant/browse_thread/thread/03a56c0e4e29d1a0
require 'active_merchant'
require 'active_merchant/billing/integrations/action_view_helper'
ActionView::Base.send(:include, ActiveMerchant::Billing::Integrations::ActionViewHelper)
