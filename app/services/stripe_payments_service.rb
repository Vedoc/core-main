class StripePaymentsService
  attr_reader :amount, :token, :description

  def initialize( amount:, token:, description: 'Vedoc Stripe' )
    @amount = amount
    @token = token
    @description = description
  end

  def call
    return OpenStruct.new( paid: true ) if Setting.service_request_fee.zero?

    Stripe::Charge.create(
      amount: amount,
      source: token,
      description: description,
      currency: 'usd'
    )
  end
end
