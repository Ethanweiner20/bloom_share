# Stores the data for a given plant
require_relative 'image_search.rb'
require_relative 'usda_plants_api.rb'

class Plant
  attr_reader :data, :image_src

  def initialize(data)
    @data = data
    @image_src = ImageSearch.find_image_source([data["ScientificName"], data["CommonName"]])
  end

  def [](key)
    return nil unless data[key]
    data[key].empty? || data[key] == '0' ? nil : data[key]
  end

  def id
    data["SpeciesID"]
  end

  def states
    str = self["State"]
    return nil unless str
    str.index('(') ? str[str.index('(') + 1...str.index(')')] : nil
  end

  # Provides a representative color of the plant
  # Used in various display areas
  def colors
    [self["FlowerColor"], self["FoliageColor"], self["FruitColor"]].compact.reject(&:empty?)
  end
end

class UserPlant < Plant
  attr_reader :id, :quantity

  def initialize(id, quantity: 0, data: nil)
    data ||= USDAPlants.find_by_id(id).data
    @id = id
    super(data)
    @quantity = quantity
  end

  def quantity=(new_quantity)
    @quantity = new_quantity
    plant_to_update = session[:user]["inventory"]["plants"].find do |plant|
      plant.id == id
    end
    plant_to_update["quantity"] = new_quantity
  end
end
