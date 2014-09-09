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
	def self.all
		(@list || []).map(&:new)
	end

	def self.inherited(klass)
		(@list ||= []) << klass
	end

	class Objective < Browser::Storage
		attr_reader :map, :full, :common, :alias

		def initialize(map, block)
			@map = map

			instance_eval(&block)

			super(`window`, "#{@map.name}.#@id")
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
			return @alias || @full || @common unless common

			@common = common
			@full   = full
			@alias  = aka
		end

		Point = Struct.new(:x, :y)

		def location(*args)
			if args.empty?
				@location
			else
				@location = Point.new(*args)
			end
		end

		%w[id type cardinal link].each {|name|
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

		class Guild < Struct.new(:id, :name, :tag)
			def self.json_create(data)
				new(data[:id], data[:name], data[:tag])
			end

			def to_json
				{ JSON.create_id => self.class.name, id: id, name: name, tag: tag }.to_json
			end
		end

		def guild
			self[:guild]
		end

		def guild=(value)
			if value.nil?
				self[:guild] = nil
			else
				self[:guild] = Guild.new(value.id, value.name, value.tag)
			end
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

	def self.id(value = nil)
		value ? @id = value : @id
	end

	def initialize
		@objectives = self.class.instance_variable_get(:@objectives).map {|block|
			Objective.new(self, block)
		}
	end

	def name
		self.class.name.match(/([^:]+)$/)[1].downcase
	end

	def id
		self.class.id
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

	def save
		@objectives.each(&:save)
	end

	def reload
		@objectives.each(&:reload)
	end

	def clear
		@objectives.each {|objective|
			objective.clear
			objective.save
		}
	end
end

require 'map/green'
require 'map/red'
require 'map/blue'
require 'map/eternal'
