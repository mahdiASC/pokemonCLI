require "pry"
class TempPokemon < Pokemon
  attr_accessor :name, :hp, :type, :atk, :def, :spec, :spd, :moveset

  def initialize(pokemon)
    #copies almost everything from a pokedex pokemon
    if !pokemon.is_a?(Pokemon)
      begin
        raise PokemonError
      rescue PokemonError => error
        error.message
      end
    end

    # parsing data from pokedex pokemon
    pokemon.instance_variables.each do |item|
      if item != :@moveset
        temp = pokemon.instance_variable_get(item)
      else
        #Using just the 4 most advanced moves (not caring about linking attacks to pokemon)
        if pokemon.instance_variable_get(item).moves.length <4
            temp = pokemon.instance_variable_get(item).moves.collect do |key,move|
                TempAttacks.new(move[:move])
            end
        else
          moves=pokemon.instance_variable_get(item).moves
          temp=((moves.length-3)..(moves.length)).to_a.collect do |index|
            TempAttacks.new(moves[index.to_s.to_sym][:move])
          end
        end
      end
      self.instance_variable_set(item,temp)
    end
    nil
  end

  class PokemonError < StandardError
		def message
			"The input was not a proper instance of the Pokemon class"
		end
	end

  def takeDamage(num)
    temp = @hp.to_i
    temp = temp - num
    if temp <0
      temp = 0
    end
    @hp = temp
  end

  def totalPP
      @moveset.collect {|move| move.pp.to_i}.reduce(:+)
  end
end
