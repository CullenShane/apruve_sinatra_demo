module Apruve
  class ApruveClient
    APRUVE_URL = "http://localhost:3000"
    APRUVE_PAYMENTS_URL = APRUVE_URL + "/api/v3/payment_requests/%s/payments"
    APRUVE_JS_URL = APRUVE_URL + '/js/apruve.js'

    def create_payment(token)
      url = APRUVE_PAYMENTS_URL % token
      puts url
    end
  end

  class ApruveObject
    require 'json'

    def initialize(args = {})
      args.each do |k, v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    def to_hash
      validate
      hash = {}
      instance_variables.each do |var|
        if instance_variable_get(var).kind_of?(Array)
          array = []
          instance_variable_get(var).each{|aryvar| array.push(aryvar.to_hash)}
          hash[var.to_s.delete("@")] = array
        else
          hash[var.to_s.delete("@")] = instance_variable_get(var)
        end
      end
      hash.reject! { |k, v| v.nil? }
      hash.reject! { |k, v| k == "api_key" }
      hash
    end

    def to_json(*a)
      to_hash.to_json
    end
  end

  class PaymentRequest < Apruve::ApruveObject
    require 'digest'
    attr_accessor :merchant_id, :amount, :currency, :line_items, :api_key

    def initialize(args = {})
      super args
      @line_items = [] if @line_items.nil?
    end

    def token_input
      token_string = to_hash.map do |k, v|
        str = ""
        if v.kind_of?(Array)
          v.each do |item|
            str = str + item.map{|q,r| r}.join
          end
        else
          str = v
        end
        str
      end
      token_string.join
    end

    def token
      if api_key.nil?
        raise "api_key has not been set."
      end
      Digest::SHA256.hexdigest(api_key+token_input)
    end

    def validate
      if merchant_id.nil? || amount.nil? || currency.nil? || line_items.size < 1
        raise "PaymentRequest must specify merchant_id, amount, currency, and at least one line item."
      end
      line_items.each { |line_item| line_item.validate }
    end
  end

  class LineItem < Apruve::ApruveObject
    attr_accessor :title, :price_total, :quantity, :description, :sku

    def validate
      if title.nil? || price_total.nil?
        raise "Line items must specifiy title and price_total."
      end
    end

  end
end