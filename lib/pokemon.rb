require "nokogiri"
require "open-uri"
require "pry"

class Pokemon
	attr_accessor :name, :hp, :type, :atk, :def, :spec, :spd, :moveset

	include Concerns::Basics
	extend Concerns::ClassMods

	@@all=[]

	def self.all
		@@all
	end

	def self.create_from_url(url="http://www.psypokes.com/rby/maxstats.php")
        # http://www.psypokes.com/rby/maxstats.php
		html = open(url, :read_timeout => 10)
		doc = Nokogiri::HTML(html)
		# tr~tr means tr preceeded by a tr (avoids the header)
		doc.css("#stats_table tr~tr").each do |row|
			pokemon=row.css("td").collect do |column|
				column.text
			end
			self.find_or_create({name:pokemon[1], hp:pokemon[3], atk:pokemon[4], def:pokemon[5], spec:pokemon[6], spd:pokemon[7]})
		end
		all
	end

	# def find_by_move(search)
	# 	#seach is a string
	# 	#This function searches all pokemon for attacks matching the search string
	# 	#and returns an array of pokemon with a match or partial match to the search parameter
	#
	# end
end
