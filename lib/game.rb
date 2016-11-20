require "pry"

class Game
  attr_accessor :player1, :player2, :turnNum

  def initialize(play1, play2)
    if !play1.is_a?(Player) || !play2.is_a?(Player)
      raise PlayerError
    else
      Pokedex.new
      @player1=play1
      @player1.token="1"
      @player1.party = randParty

      @player2=play2
      @player2.token = "2"
      @player2.party = randParty
      set_players_by_speed
    end
  end

  class PlayerError < StandardError
  end

  def anyFainted?
    @player1.currentPokemon.hp.to_i == 0 || @player2.currentPokemon.hp.to_i == 0
  end

  def randParty
    #return a random Array of 6 TempPokemon
    if Pokemon.all.size < 1
      Pokemon.create_from_url
    end

    temp = []
    6.times do
      temp << TempPokemon.new(Pokemon.all[rand(Pokemon.all.size)])
    end
    temp
  end

  def set_players_by_speed
    if @player1.currentPokemon.spd.to_i == @player2.currentPokemon.spd.to_i
        if rand > 0.5
            @turnNum = 1
        end
    else
        @player1.currentPokemon.spd.to_i > @player2.currentPokemon.spd.to_i ? @turnNum = 1 : @turnNum = 2
    end
  end

  def currentPlayer
    @turnNum.odd? ? @player1 : @player2
  end

  def humanPlayer
    @player1.is_a?(Human) ? @player1 : @player2
  end

  def aiPlayer
    @player1.is_a?(AI) ? @player1 : @player2
  end

  def over?
    @player1.partyHP < 1 ||  @player2.partyHP < 1
  end

  def winner
    if over?
      @player1.partyHP < 1 ? @player2 : @player1
    else
      nil
    end
  end

  def addTurn
    @turnNum += 1
  end

  def pauseTurn
    @turnNum -= 1
  end
end
