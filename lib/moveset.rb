require "nokogiri"
require "open-uri"
require "pry"

class Moveset
	attr_accessor :moves
	attr_writer :pokemon
	# to prevent circular references, pokemon will be a string, but will make an
	# reader method that will find the pokemon
	# thought Ruby GC could handle this...

	include Concerns::Basics

	def pokemon
		Pokemon.find_by_name(@pokemon)
	end

	def self.find_by_pokemon(name)
		all.detect {|moveset| moveset.pokemon.name.downcase.gsub(/\s+/, "") == name.downcase.gsub(/\s+/, "")}
	end

	@@all=[]

	# def view
	# 	puts "POKEMON: #{@pokemon}"
	# 	puts "MOVE: LEVEL LEARNED"
	# 	puts "-------------------"
	# 	@moves.each do |move|
	# 		puts "#{move[1][:move].name.upcase}: #{move[1][:level]}"
	# 	end
	# 	nil
	# end

	def initialize(args)
		super(args)
		Pokemon.find_by_name(@pokemon).moveset = self
		@moves.each do |key, attack|
			if attack[:move].nil?
				binding.pry
				begin
					AttackError
				rescue AttackError => error
					puts error.message
				end
			end
			attack[:move].add_pokemon(@pokemon)
		end
	end

	class AttackError < StandardError
		def message
			"The input was not a proper instance of the Attack class"
		end
	end

	def self.all
		@@all
	end

  def self.create_from_url(url1="http://www.angelfire.com/nb/rpg/moves.html", url2="http://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_National_Pok%C3%A9dex_number")
        # http://www.angelfire.com/nb/rpg/moves.html
		# http://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_National_Pok%C3%A9dex_number
		# First url has pokemon moves in proper pokemon order
		# Second url has pokemon names in proper pokemon order. THEY ALTERED THEIR WEBSITE DURING THIS PROJECT!

		#using list of pokemon moves in their correct pokemon order
		doc1 = Nokogiri::HTML(open(url1, :read_timeout => 10))
		rawContent=doc1.css("body #lycosFooterAd~*")

		#using correct order list of pokemon (cannot be parsed from first url)
		doc2 = Nokogiri::HTML(open(url2, :read_timeout => 10))
		pokemonList=doc2.css("table")[1].css("tr~tr")

		counter = 0
		pokemonCounter = 0

		while counter < rawContent.length do
			moveset= {}
			if rawContent[counter].text.strip.downcase.include?("level learned") || rawContent[counter].text.strip.split(": ")[1] == "-"
				#getting name of pokemon, used for connecting pokemon w/moves
				pokemonName = correctPokeName(pokemonList[pokemonCounter].css("td")[3].text.strip)
				# encoding issues
				# binding.pry
				until find_by_pokemon(pokemonName).nil? #had to add after websie changed
					pokemonCounter += 1
					pokemonName = correctPokeName(pokemonList[pokemonCounter].css("td")[3].text.strip)
				end

				moveset[:pokemon] = pokemonName
				#adding in pokemon Type
				Pokemon.find_by_name(pokemonName).type = pokemonList[pokemonCounter].css("td").drop(4).collect{|column| column.text.strip}
				pokemonCounter += 1

				#getting moves for next pokemon in list order
				moveset[:moves] = {}
				moveNum = 1

				#Very annoying website to parse!
				if rawContent[counter].text.strip.downcase.include?("moves")
					counter += 1
				end

				until rawContent[counter].text.strip.downcase == "" || rawContent[counter].text.strip.downcase.include?("ratings") do
					temp = {}

					moveName = rawContent[counter].text.strip.split(": ")[0]
					level = rawContent[counter].text.strip.split(": ")[1]

					#website corrections: mispelling
					if moveName.downcase.gsub(/\s+/, "")=="hijumpkick"
						moveName="Hi Jump Kick"
					elsif moveName.downcase.gsub(/\s+/, "") == "pinmissle"
						moveName="Pin Missile"
					elsif moveName.downcase.gsub(/\s+/, "") == "sandattack"
						moveName="Sand-Attack"
					elsif moveName.downcase.gsub(/\s+/, "") == "dorndrill"
						moveName="Horn Drill"
					elsif moveName.downcase.gsub(/\s+/, "") == "sctratch"
						moveName="Scratch"
					end

					#more corrections: inconsistent formatting on website
					if level.nil?
						level = "-"
						moveName = moveName.gsub(" -", "").gsub(":","")
					end
					temp[:move] = Attacks.find_by_name(moveName)
					temp[:level] = level
					moveset[:moves][moveNum.to_s.to_sym] = temp
					counter += 1
					moveNum += 1
				end
				new(moveset)
			end
			counter += 1
		end
		nil
	end

	private
	def self.correctPokeName(pokemonName)
		if pokemonName == "Nidoran\u2640"
			pokemonName = "Nidoran F"
		elsif pokemonName == "Nidoran\u2642"
			pokemonName = "Nidoran M"
		end
		pokemonName
	end

end
