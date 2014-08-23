#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

class Map
	class Objective < Browser::Storage
		attr_reader :full, :common, :alias

		def initialize(map, block)
			@map = map

			instance_eval(&block)

			super(`window`, "#@map.#@id")
			no_autosave!
		end

		def clone
			copy = super
			copy.instance_variable_set :@data, @data.clone

			copy
		end

		%w[ruin camp tower keep castle].each {|type|
			define_method "#{type}?" do
				@type == type
			end
		}

		def name(common = nil, full = nil, aka = nil)
			return @name unless common

			@common = common
			@full   = full
			@alias  = aka
		end

		%w[id type location].each {|name|
			define_method name do |value = nil|
				if value
					instance_variable_set "@#{name}", value
				else
					instance_variable_get "@#{name}"
				end
			end
		}

		def tier
			self[:tier] || 0
		end

		def tier=(value)
			self[:tier] = value
		end

		def refreshed
			self[:refreshed] || 0
		end

		def refreshed=(value)
			self[:refreshed] = value
		end

		def capped
			self[:capped] || 0
		end

		def capped=(value)
			self[:capped] = value
		end

		def owner
			self[:owner] || :neutral
		end

		def owner=(value)
			self[:owner] = value
		end

		def guild
			self[:guild]
		end

		def guild=(value)
			self[:guild] = value
		end

		def points
			case type
			when :ruin   then 0
			when :camp   then 5
			when :tower  then 10
			when :keep   then 25
			when :castle then 35
			end
		end
	end

	def self.objective(&block)
		(@objectives ||= []) << block
	end

	def initialize
		@objectives = self.class.instance_variable_get(:@objectives).map {|block|
			Objective.new(name, block)
		}
	end

	def name
		self.class.name.match(/([^:]+)$/)[1].downcase
	end

	include Enumerable

	def each(&block)
		return enum_for :each unless block

		@objectives.each(&block)

		self
	end

	def [](id)
		@objectives.find { |o| o.id == id.to_i }
	end
end

require 'map/green'
require 'map/red'
require 'map/blue'
require 'map/eternal'
