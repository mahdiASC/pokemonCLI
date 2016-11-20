require "pry"
module Concerns
    module Basics
        def initialize (hash)
          hash.each{|key, val| send("#{key}=", val)}
      		self.class.all << self
      	end
    end

    module ClassMods
        def clear
            all.clear
        end


        class CategoryError < StandardError
          def message
            puts "The category was not a proper instance variable of the #{self} class"
          end
        end

        #find or create by name?
        def find_by(search, category="name")
            #category is a string
            #search is a string
            output = all.select do |item|
              if category == "moveset" || category == "type"
                nil #forces partial matching
              else
                item.instance_variable_get("@#{category}").downcase.gsub(/\s+/, "") == search.downcase.gsub(/\s+/, "")
              end
            end

            #returns the item or nil if not found

            if output.size < 1
                output = find_partial(search, category)
            end
            output
        end

        def find_partial(search, category="name")
            #category is a string
            #search is a string
            all.select do |item|
              if category == "moveset"
                # binding.pry
                item.moveset.moves.any?{|key, move| move[:move].name.downcase.gsub(/\s+/, "").include?(search.downcase.gsub(/\s+/, ""))}
              elsif category == "type"
                item.type.any?{|type| type.downcase.gsub(/\s+/, "").include?(search.downcase.gsub(/\s+/, ""))}
              else
                item.instance_variable_get("@#{category}").downcase.gsub(/\s+/, "").include?(search.downcase.gsub(/\s+/, ""))
              end
            end
            #returns the item or nil if not found
        end

        def find_by_name(name)
          all.detect do |item|
              #Inconsistent naming -.-
            #   binding.pry
              item.instance_variable_get("@name").downcase.gsub(/\s+/, "") == name.downcase.gsub(/\s+/, "")
          end
        end

        def find_or_create(hash)
            find_by_name(hash[:name]).nil? ? new(hash) : find_by_name(hash[:name])
        end
    end
end
