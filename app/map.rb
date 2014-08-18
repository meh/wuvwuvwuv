#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

class Map < Lissio::Component
	class Objective
		attr_reader :common, :alias

		def initialize(&block)
			instance_eval(&block)
		end

		%w[ruin camp tower keep castle separator].each {|type|
			define_method "#{type}?" do
				@type == type
			end
		}

		def id(id = nil)
			return @id unless id

			@id = id
		end

		def name(common = nil, name = nil, aka = nil)
			return @name || @common unless common

			@common = common
			@name   = name
			@alias  = aka
		end

		def type(type = nil)
			return @type unless type

			@type = type
		end

		def location(location = nil)
			return @location unless location

			@location = location
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

		def icon
			if type == :ruin
				case name
				when "Carver's Ascent"        then 'carvers_ascent'
				when 'Orchard Overlook'       then 'orchard_overlook'
				when "Bauer's Estate"         then 'bauers_estate'
				when "Battle's Hollow"        then 'battles_hollow'
				when 'Temple of Lost Prayers' then 'temple_of_lost_prayers'
				end
			else
				type.to_s
			end
		end
	end

	class Separator < Objective
		def initialize
			super do
				type :separator
			end
		end
	end

	class Objectives
		def self.make(&block)
			new(&block).to_a
		end

		def initialize(&block)
			@array = []

			instance_eval(&block)
		end

		def objective(&block)
			@array << Objective.new(&block)
		end

		def separator
			@array << Separator.new
		end

		def to_a
			@array
		end
	end

	def self.objectives(&block)
		if block
			@objectives = Objectives.make(&block)
		else
			@objectives
		end
	end

	def objectives
		self.class.objectives
	end

	def render
		element.inner_dom do |_|
			_.table do
				_.tr.icon do
					objectives.each do |o|
						if o.separator?
							_.td.separator
							_.td.separator.space
							next
						end

						_.td.data(id: o.id) do
							_.img(class: o.type).src("img/#{o.icon}.png")
						end
					end
				end

				_.tr.name do
					objectives.each do |o|
						if o.separator?
							_.td.separator
							_.td.separator.space
							next
						end

						_.td.data(id: o.id) do
							if o.ruin?
								_.div o.location.upcase
							else
								_.div o.alias || o.name
							end
						end
					end
				end

				_.tr.timer do
					objectives.each do |o|
						if o.separator?
							_.td.separator
							_.td.separator.space
							next
						end

						_.td.data(id: o.id).low do
							'1:30'
						end
					end
				end
			end
		end

		super
	end

	css do
		text align: :center
		font size: 14.px

		rule 'table' do
			border spacing: 0
			display 'inline-block'

			style 'background-image', '-webkit-gradient(
				linear, left top, left bottom, from(rgba(0,0,0,0.15)),
				to(rgba(0,0,0,0))
			)'

			style 'background-image', '-moz-linear-gradient(
				rgba(0, 0, 0, 0.15) 0%, rgba(0, 0, 0, 0)
			)'

			border style: :solid,
			       width: [2.px, 0, 0, 0],
			       image: 'linear-gradient(to right, rgba(0, 0, 0, 0), black, rgba(0, 0, 0, 0)) 1'

			rule 'tr' do
				rule '&:first-child' do
					rule 'td' do
						padding top: 3.px
					end
				end

				rule 'td' do
					text align: :center
					padding 0
					width 40.px

					rule '&:first-child' do
						padding left: 3.px
					end

					rule '&:last-child' do
						padding right: 3.px
					end

					rule '&.separator' do
						width 0

						border right: [1.px, :solid, :black]

						rule '&.space' do
							border :none
							width 1.px
						end
					end
				end

				rule '&.icon' do
					line height: 1.px

					rule 'td' do
						height 28.px

						rule 'img' do
							height 28.px
							width  28.px

							rule '&.ruin' do
								height 24.px
								width  24.px
							end
						end
					end
				end

				rule '&.timer' do
					rule 'td' do
						padding top: 5.px

						rule '&.high' do
							style 'text-shadow',
								(', 0 0 2px #b20000' * 10)[1 .. -1] +
								(', 0 0 1px #b20000' * 10)
						end

						rule '&.mid' do
							style 'text-shadow',
								(', 0 0 2px #ff6000' * 10)[1 .. -1] +
								(', 0 0 1px #ff6000' * 10)
						end

						rule '&.low' do
							style 'text-shadow',
								(', 0 0 2px #007a20' * 10)[1 .. -1] +
								(', 0 0 1px #007a20' * 10)
						end
					end
				end
			end
		end
	end
end
