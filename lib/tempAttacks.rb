require "pry"

class TempAttacks
  attr_accessor :name, :desc, :type, :pp, :power, :acc

  ATTACKTYPES={
    "normal"=>{
      :immune=>["ghost"],
      :half=>["rock"],
      :double=>[]
    },
    "fire"=>{
      :immune=>[],
      :half=>["fire","water","rock","dragon"],
      :double=>["grass","ice","bug"]
    },
    "water"=>{
      :immune=>[],
      :half=>["water","grass","dragon"],
      :double=>["fire","ground","rock"]
    },
    "electric"=>{
      :immune=>["ground"],
      :half=>["electric","grass","dragon"],
      :double=>["water","flying"]
    },
    "grass"=>{
      :immune=>[],
      :half=>["fire","grase","poison", "flying", "bug","dragon"],
      :double=>["water", "ground","rock"]
    },
    "ice"=>{
      :immune=>[],
      :half=>["water","ice"],
      :double=>["grass",'flying','dragon']
    },
    "fighting"=>{
      :immune=>['ghost'],
      :half=>['poison', 'flying','psychic','bug'],
      :double=>['normal','ice','rock']
    },
    "poison"=>{
      :immune=>[],
      :half=>['poison','ground','rock','ghost'],
      :double=>['grass','bug']
    },
    "ground"=>{
      :immune=>['flying'],
      :half=>['grass','bug'],
      :double=>['fire','electric','poison','rock']
    },
    "flying"=>{
      :immune=>[],
      :half=>['electric','rock'],
      :double=>['grass','poison','bug']
    },
    "psychic"=>{
      :immune=>[],
      :half=>['psychic'],
      :double=>['fighting','poison']
    },
    "bug"=>{
      :immune=>[],
      :half=>['fire','fighting','flying','ghost'],
      :double=>['grass','poison','psychic']
    },
    "rock"=>{
      :immune=>[],
      :half=>['fighting','ground'],
      :double=>['fire','ice','flying','bug']
    },
    "ghost"=>{
      :immune=>[],
      :half=>[],
      :double=>['ghost']
    },
    "dragon"=>{
      :immune=>[],
      :half=>[],
      :double=>['dragon']
    }
  }

  def initialize(attack)
    #Takes a Pokedex Attack and converts it into a temporary one for use in game by Players
    if !attack.is_a?(Attacks)
      begin
        raise AttacksError
      rescue AttacksError => error
        error.message
      end
    end

    attack.instance_variables.each do |var|
      if var.to_s != "@pokemon"
        self.instance_variable_set(var, attack.instance_variable_get(var))
      end
    end
    nil
  end

  class AttacksError < StandardError
    def message
      "The input was not a proper instance of the Attacks class"
    end
  end

  def specialMove?
      ["water","grass","fire","ice",'electric','psychic','dragon'].include?(@type.downcase)
  end

  def crit?(selfPokemon)
      selfPokemon.spd.to_i/512.0>=rand
  end

  def calcMatchMult(selfPokemon)
    # multiplier when pokemon type matches move Type
    if selfPokemon.type.any? {|type| type == @type}
      1.5
    else
      1
    end
  end

  def calcCritMult(selfPokemon)
    # crit
    crit?(selfPokemon) ? 2 : 1
  end

  def calcTypeMult(selfPokemon,opponentPokemon)
    # Type matching
    typeM = opponentPokemon.type.collect do |oppType|
      if ATTACKTYPES[@type.downcase][:immune].include?(oppType.downcase)
        0
      elsif ATTACKTYPES[@type.downcase][:half].include?(oppType.downcase)
        0.5
      elsif ATTACKTYPES[@type.downcase][:double].include?(oppType.downcase)
        2
      else
        1
      end
    end
    typeM.reduce(:*)
  end

  def miss?
    @acc.to_i<rand(100)
  end

  def attackDeterminer(selfPokemon,opponentPokemon)
      #returns a string or and array of what happened
    @pp = (@pp.to_i-1).to_s
    if miss?
      {}
    else
      doDamage(selfPokemon,opponentPokemon)
    end
  end

  def offensiveAttack?
    @power.to_i > 0
  end

  def makeAttack(selfPokemon,opponentPokemon)
    #determines if this attack is a regular damaging move or requires special
    #stat changes
    if offensiveAttack?
      attackDeterminer(selfPokemon,opponentPokemon)
    else
      doUnique(selfPokemon,opponentPokemon)
    end
  end

  def struggle?
    @pp.to_i<1
  end

  def doUnique(selfPokemon,opponentPokemon)
    #should return array for CLI
    {}
  end

  def doDamage(selfPokemon,opponentPokemon, justCalcFlag=false)
  # opponent is a tempPokemon instance
  # Formula
  # https://www.gamefaqs.com/gameboy/367023-pokemon-red-version/faqs/54432

  # damage = ((0.84 * aPower * bPower / dPower) + 2) * multipliers * randomNum / 255
  # aPower - Attack power if you use a Physical attack, Special power if you use a
  # Special attack.
  aPower = specialMove? ?  selfPokemon.spec.to_i : selfPokemon.atk.to_i
  # bPower - Base power of the move, such as 120 for Hydro Pump, 100 for Earthquake etc.
  # You can find these numbers in Appendix B.
  bPower = @power.to_i #bit redundant, but keeps things organized!
  # dPower - Defense power of the opponent if you use a Physical attack, Special power
  # if you’re using a Special attack.
  dPower = specialMove? ?  opponentPokemon.spec.to_i : opponentPokemon.atk.to_i
  # multipliers - All multipliers including 1.5 for an attack matching your Pokemon's type, 2
  # for each weakness, 0.5 for each resistance, 0 for immunities, and 2 for Critical
  # Hits. Apply all of these as they occur, and multiply them all together. The
  # result is M. The highest this can be is 12 if you use an attacking matching your
  # Pokemon's type, which is Super Effective against both types of the opponent, and
  # also is a Critical Hit.

  myCrit = calcCritMult(selfPokemon)

  multipliers = calcTypeMult(selfPokemon,opponentPokemon)*myCrit*calcMatchMult(selfPokemon)

  # randomNum - A random number from 217 to 255. This creates the minimum and maximum each
  # attack can do. Roughly, the attack can do anywhere from ~85% to 100% of its
  # expected damage.
  randomNum = rand(217..255)
  damage = ((0.84 * aPower * bPower / dPower) + 2) * multipliers * randomNum / 255
  if !justCalcFlag
    opponentPokemon.takeDamage(damage.floor)
    if @name == "Struggle"
      selfPokemon.takeDamage((damage.floor/4).floor)
    end
  end
  #Returns array of pertinent information for the CLI
  # [critical multiplyer, type multiplier, damage, move name]
  {:crit=> myCrit, :typeMult=>calcTypeMult(selfPokemon,opponentPokemon), :dmg => damage, :name => @name}
  end
end
