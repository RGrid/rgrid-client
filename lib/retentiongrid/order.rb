module Retentiongrid
  # Retentiongrid Order
  #
  # To create a new Retentiongrid::Order object:
  #   order = Retentiongrid::Order.new(order_id: "A123", customer_id: 'C123', currency: 'EUR', total_price: 12.00, order_created_at: Time.now).save
  #
  # To get a order from the API:
  #   order = Retentiongrid::Order.find('A123')
  #
  class Order < Resource

    BASE_PATH = '/orders'.freeze

    # The set of attributes defined by the API documentation
    ATTRIBUTES_NAMES = [  :order_id, :customer_id, :status, :total_price, :total_discounts,
                          :currency, :canceled_shipped, :canceled_shop_fault, :order_created_at
                       ].freeze

    ATTRIBUTES_NAMES.each do |attrib|
      attr_accessor attrib
    end

    attr_accessor :customer

    def initialize(attribs={})
      super
      if order_created_at.class == String && !order_created_at.nil?
        @order_created_at = Time.parse(order_created_at)
      end
    end

    # relations

    def customer=(customer)
      @customer_id = customer.customer_id
      @customer = customer
    end

    # API Stuff here

    # Find an order with given id
    # @param [Fixnum] order_id the order id to be found
    # @return [Order] if found any
    def self.find(order_id)
      begin
        result = Api.get("#{BASE_PATH}/#{order_id}")
        new(result.parsed_response["rg_order"])
      rescue NotFound
        nil
      end
    end

    # Create or update an order with given id
    # @return [Order] if successfully created or updated
    # @raise [Httparty::Error] for all sorts of HTTP statuses.
    def save!
      result = Api.post("#{BASE_PATH}/#{order_id}", { body: attributes.to_json })
      Order.new(result.parsed_response["rg_order"])
    end

    # Delete this order at retention grid
    # @return [Boolean] successfully deleted?
    def destroy
      Api.delete("#{BASE_PATH}/#{order_id}")
      true
    end
  end
end
