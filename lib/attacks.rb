require "nokogiri"
require "open-uri"
require "pry"

class Attacks
	attr_accessor :name, :desc, :type, :pp, :power, :acc, :pokemon

	include Concerns::Basics
	extend Concerns::ClassMods

	#Should have a list of which pokemon this move belongs and can look up

	@@all=[]

	def initialize(args)
		@pokemon = []
		super(args)
	end

	def self.all
		@@all
	end

	def add_pokemon(pokemon)
		if !@pokemon.include?(pokemon)
			@pokemon << pokemon
		end
	end

	def self.create_from_url(url="http://www.psypokes.com/rby/attacks.php")
		# http://www.psypokes.com/rby/attacks.php
		html = open(url, :read_timeout => 10)
		doc = Nokogiri::HTML(html)
		# tr~tr means tr preceeded by a tr (avoids the header)
		doc.css("table.psypoke tr~tr").each do |row|
			attack=row.css("td").collect do |column|
				column.text
			end
			self.find_or_create({name:attack[0], desc:attack[1], type:attack[2], pp:attack[3], power:attack[4], acc:attack[5]})
		end
		all
	end

end
