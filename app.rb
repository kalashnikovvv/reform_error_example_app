require "bundler"
Bundler.require

require "json"
require "disposable/twin/property/struct"
require "disposable/twin/property/hash"
require "reform/form/coercion"
require "reform/form/dry"

class Tournament
  attr_accessor :prizes, :prize_amounts

  def initialize
    @prizes = []
    @prize_amounts = []
  end
end

class CurrencyAmountForm < Reform::Form
  include Disposable::Twin::Property::Struct
  feature Reform::Form::Coercion
  feature Reform::Form::Dry

  property :currency_id, type: Types::Form::Int
  property :value
end

class PrizeForm < Reform::Form
  include Disposable::Twin::Property::Struct
  feature Reform::Form::Dry

  property :type
  collection :amounts, field: :hash, populate_if_empty: Hash, form: CurrencyAmountForm
end

class TournamentForm < Reform::Form
  include Disposable::Twin::Property::Hash
  feature Reform::Form::Dry

  collection :prizes, field: :hash, populate_if_empty: Hash, form: PrizeForm
end

params_filepath = File.expand_path("params.json", __dir__)
params = JSON.parse(File.read(params_filepath))

form = TournamentForm.new(Tournament.new)
form.validate(params)
