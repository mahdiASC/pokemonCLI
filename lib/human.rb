class Human < Player
  attr_accessor :token, :currentPokemon
  attr_reader :party

  def changePokemon(index)
    @currentPokemon = party[index.to_i-1]
  end

end
