require "nokogiri"
require "open-uri"
require "pry"

class Pokedex
	attr_accessor :pokemon, :attacks

    def initialize
		# Loads all pokemon and all attacks into pokedex
		@pokemon = Pokemon.create_from_url
		@attacks = Attacks.create_from_url

		# Moveset handles bridginge the Pokemon with their moves
		Moveset.create_from_url
		end
end
