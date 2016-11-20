class Player
  attr_accessor :token, :currentPokemon
  attr_reader :party

  def party=(party)
    @party = party
    @currentPokemon = @party[0]
  end

  def partyHP
    party.collect {|pokemon| pokemon.hp.to_i}.reduce(:+)
  end

  def partyPP
    party.collect {|pokemon| pokemon.pp.to_i}.reduce(:+)
  end
  # def viewParty
  #   @party.each do |pokemon|
  #     puts '------------------'
  #     pokemon.instance_variables.each do |key|
  #       if key != :@moveset
  #         puts "#{key.to_s.gsub!("@","").upcase}: #{pokemon.instance_variable_get(key)}"
  #       else
  #         movesetString = pokemon.instance_variable_get(key).collect {|attack| " #{attack.name},"}.join.strip.gsub(/,$/,"")
  #         puts "#{key.to_s.gsub!("@","").upcase}: #{movesetString}"
  #       end
  #     end
  #     puts '------------------'
  #   end
  #   nil
  # end
end
