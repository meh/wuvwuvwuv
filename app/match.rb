#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

require 'browser/http'
require 'time'

class Match
	WORLDS = {
		1008 => 'Jade Quarry',
		2006 => 'Underworld',
		1023 => 'Devona’s Rest',
		2105 => 'Arborstone',
		1014 => 'Crystal Desert',
		1022 => 'Kaineng',
		2001 => 'Fissure of Woe',
		1001 => 'Anvil Rock',
		2003 => 'Gandara',
		1003 => 'Yak’s Bend',
		2007 => 'Far Shiverpeaks',
		1011 => 'Stormbluff Isle',
		2013 => 'Aurora Glade',
		1016 => 'Sea of Sorrows',
		2005 => 'Ring of Fire',
		2012 => 'Piken Square',
		1012 => 'Darkhaven',
		1005 => 'Maguuma',
		2204 => 'Abaddon’s Mouth',
		2203 => 'Elona Reach',
		2010 => 'Seafarer’s Rest',
		2104 => 'Vizunah Square',
		2207 => 'Dzagonur',
		2009 => 'Ruins of Surmia',
		1002 => 'Borlis Pass',
		2002 => 'Desolation',
		1010 => 'Ehmry Bay',
		1024 => 'Eredon Terrace',
		1004 => 'Henge of Denravi',
		1007 => 'Gate of Madness',
		2205 => 'Drakkar Lake',
		2008 => 'Whiteside Ridge',
		1017 => 'Tarnished Coast',
		2101 => 'Jade Sea',
		1013 => 'Sanctum of Rall',
		2014 => 'Gunnar’s Hold',
		1021 => 'Dragonbrand',
		2301 => 'Baruch Bay',
		2102 => 'Fort Ranik',
		2103 => 'Augury Rock',
		2201 => 'Kodash',
		2202 => 'Riverside',
		2206 => 'Miller’s Sound',
		1018 => 'Northern Shiverpeaks',
		1015 => 'Isle of Janthir',
		2004 => 'Blacktide',
		1006 => 'Sorrow’s Furnace',
		2011 => 'Vabbi',
		1009 => 'Fort Aspenwood',
		1020 => 'Ferguson’s Crossing',
		1019 => 'Blackgate'
	}

	def self.find(world)
		if world.is_a?(String)
			world = WORLDS.key(world)
		end

		Browser::HTTP.get('https://api.guildwars2.com/v1/wvw/matches.json') {|req|
			req.headers.clear
		}.then {|res|
			match = res.json[:wvw_matches].find {|m|
				m[:blue_world_id] == world or
				m[:red_world_id] == world or
				m[:green_world_id] == world
			}

			new(match)
		}.rescue {|err|
			$console.log err
		}
	end

	attr_reader :id, :start, :end
	attr_reader :blue, :red, :green

	def initialize(data)
		@id    = data[:wvw_match_id]
		@start = Time.parse(data[:start_time])
		@end   = Time.parse(data[:end_time])

		@blue  = World.new(data[:blue_world_id], WORLDS[data[:blue_world_id]])
		@red   = World.new(data[:red_world_id], WORLDS[data[:red_world_id]])
		@green = World.new(data[:green_world_id], WORLDS[data[:green_world_id]])
	end

	def details
		Browser::HTTP.get("https://api.guildwars2.com/v1/wvw/match_details.json?match_id=#@id") {|req|
			req.headers.clear
		}.then {|res|
			Details.new(self, res.json)
		}
	end

	World = Struct.new(:id, :name)

	class Details
		attr_reader :scores, :red, :blue, :green, :eternal

		def initialize(match, data)
			@scores  = Scores.new(*data[:scores])
			@red     = Map.new(data[:maps].find { |m| m[:type] == "RedHome" })
			@blue    = Map.new(data[:maps].find { |m| m[:type] == "BlueHome" })
			@green   = Map.new(data[:maps].find { |m| m[:type] == "GreenHome" })
			@eternal = Map.new(data[:maps].find { |m| m[:type] == "Center" })
		end

		Scores = Struct.new(:red, :blue, :green)

		class Map
			Objective = Struct.new(:id, :owner, :guild)
			Bonus     = Struct.new(:type, :owner)

			def initialize(data)
				@scores = Scores.new(*data[:scores])

				@bonuses = data[:bonuses].map {|b|
					Bonus.new(b[:type], b[:owner])
				}

				@hash = Hash[data[:objectives].map {|o|
					[o.id, Objective.new(o[:id], o[:owner].downcase, o[:owner_guild])]
				}]
			end

			def [](id)
				@hash[id]
			end

			include Enumerable

			def each(&block)
				return enum_for :each unless block

				@hash.each {|_, objective|
					block.call(objective)
				}

				self
			end
		end
	end
end
