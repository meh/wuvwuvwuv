#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

require 'lissio/adapter/rest'
require 'time'

class REST < Lissio::Adapter::REST
	def initialize(model, point = nil, options = {}, &block)
		super(model, options) {|_|
			_.base 'http://api.guildwars2.com/v1'
			_.endpoint point if point

			_.http do |req|
				req.headers.clear
			end

			if block.arity == 0
				instance_exec(&block)
			else
				block.call(_)
			end if block
		}
	end
end

class Match < Lissio::Model
	class World < Struct.new(:id, :name, :region)
		def initialize(id)
			super(id, ::World.name(id), id.to_s[0] == ?1 ? :na : :eu)
		end
	end

	property :id, primary: true, key: :wvw_match_id

	property :blue,  as: World, key: :blue_world_id
	property :green, as: World, key: :green_world_id
	property :red,   as: World, key: :red_world_id

	property :start, as: Time, key: :start_time
	property :end,   as: Time, key: :end_time

	def region
		red.region
	end

	def hash
		"#@id:#{blue.id}-#{green.id}-#{red.id}"
	end

	def details
		Details.fetch(id)
	end

	class Details < Lissio::Model
		class Scores < Lissio::Model
			property :green, as: Integer
			property :blue,  as: Integer
			property :red,   as: Integer

			def initialize(red, blue, green)
				super(red: red, blue: blue, green: green)
			end
		end

		class Guild < Lissio::Model
			property :id, as: String, primary: true, key: :guild_id
			property :name, key: :guild_name
			property :tag

			adapter REST, fetch: -> id { "/guild_details.json?guild_id=#{id}" }
		end

		class Map < Lissio::Model
			class Objective < Lissio::Model
				property :id, as: Integer
				property :owner, as: :downcase.to_proc
				property :guild, as: Guild, key: :owner_guild
			end

			class Bonus < Lissio::Model
				property :type
				property :owner, as: :downcase.to_proc
			end

			property :name, key: :type, as: -> type {
				case type
				when 'RedHome'   then :red
				when 'BlueHome'  then :blue
				when 'GreenHome' then :green
				when 'Center'    then :eternal
				end
			}

			property :scores, as: Scores
			property :bonuses, as: [Bonus]
			property :objectives, as: [Objective]

			include Enumerable
			
			def each(&block)
				return enum_for :each unless block

				objectives.each(&block)

				self
			end
		end

		property :scores, as: Scores

		property :green,   as: Map
		property :blue,    as: Map
		property :red,     as: Map
		property :eternal, as: Map

		def maps
			[green!, blue!, red!, eternal!]
		end

		adapter REST do |_|
			_.endpoint fetch: -> id {
				"/wvw/match_details.json?match_id=#{id}"
			}

			_.parse do |data|
				new scores:  data[:scores],
				    red:     data[:maps].find { |m| m[:type] == "RedHome" },
				    blue:    data[:maps].find { |m| m[:type] == "BlueHome" },
				    green:   data[:maps].find { |m| m[:type] == "GreenHome" },
				    eternal: data[:maps].find { |m| m[:type] == "Center" }
			end
		end
	end
end

class Matches < Lissio::Collection
	model Match

	adapter REST, '/wvw/matches.json' do |_|
		_.parse do |data|
			new data[:wvw_matches]
		end
	end

	def self.find(world)
		if world.is_a? String
			world = World.id(world)
		end

		Matches.fetch.then {|matches|
			matches.find {|match|
				match.blue.id  == world or
				match.green.id == world or
				match.red.id   == world
			}
		}
	end
end
