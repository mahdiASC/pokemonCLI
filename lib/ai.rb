class AI < Player
  attr_accessor :token, :currentPokemon, :difficulty
  attr_reader :party

  def initialize(difficulty)
    @difficulty = difficulty[0]
  end

  def make_move(enemyPokemon)
    if @difficulty=="easy"
      attack = easy_move(enemyPokemon)
    else
      attack = advanced_move(enemyPokemon)
    end

    if !attack.nil?
      attack.makeAttack(@currentPokemon , enemyPokemon)
    else
      struggle = TempAttacks.new(Attacks.find_by_name("struggle"))
      struggle.makeAttack(@currentPokemon , enemyPokemon)
    end
  end

  def random(array)
    #returns a random item of the array
    array[rand(array.size)]
  end

  def easy_move(enemyPokemon)
    #random move
    random(@currentPokemon.moveset.select {|move| move.power.to_i>0})
  end

  def advanced_move(enemyPokemon)
    #hardest hitting move
    moveset = @currentPokemon.moveset.select {|move| move.power.to_i>0}
    if moveset.size < 1
      nil
    else
      moveset.max {|move| move.doDamage(@currentPokemon,enemyPokemon, true)[:dmg]}
    end
  end

  def changePokemon
    @currentPokemon = @party.detect{|poke| poke.hp.to_i >0}
  end
end
