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
							_.img(class: o.type).data(name: o.name)
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

						_.td.data(id: o.id)
					end
				end
			end
		end

		super
	end

	def tick
		element.css('.timer td[data-id]').each {|e|
			unless (timer = e.inner_text).empty?
				minutes, seconds = timer.split(':').map(&:to_i)

				if minutes == 0 && seconds == 1
					e.inner_text = ''
				elsif seconds == 0
					e.inner_text = "%d:59" % (minutes - 1)
				else
					e.inner_text = "%d:%02d" % [minutes, seconds - 1]
				end

				if minutes >= 3
					e[:class] = :high
				elsif minutes >= 1
					e[:class] = :medium
				else
					e[:class] = :low
				end
			end
		}
	end

	def update(details)
		details.__send__(self.class.name.match(/([^:]+)$/)[1].downcase).each {|o|
			timer = element.at_css(".timer td[data-id='#{o.id}']")
			icon  = element.at_css(".icon td[data-id='#{o.id}'] img")
			owner = (icon.class_names - [:ruin, :camp, :tower, :keep, :castle]).first || :neutral

			if owner != o.owner
				icon.remove_class owner

				unless o.owner == :neutral
					icon.add_class o.owner
				end

				unless owner == :neutral
					timer.inner_text = '5:00'
				end
			end
		}
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

							rule '&.camp' do
								content 'url(img/camp.png)'

								%w[red blue green].each do |color|
									rule "&.#{color}" do
										content "url(img/camp.#{color}.png)"
									end
								end
							end

							rule '&.tower' do
								content 'url(img/tower.png)'

								%w[red blue green].each do |color|
									rule "&.#{color}" do
										content "url(img/tower.#{color}.png)"
									end
								end
							end

							rule '&.keep' do
								content 'url(img/keep.png)'

								%w[red blue green].each do |color|
									rule "&.#{color}" do
										content "url(img/keep.#{color}.png)"
									end
								end
							end

							rule '&.castle' do
								content 'url(img/castle.png)'

								%w[red blue green].each do |color|
									rule "&.#{color}" do
										content "url(img/castle.#{color}.png)"
									end
								end
							end

							rule '&.ruin' do
								{ "Carver's Ascent"        => 'carvers_ascent',
								  'Orchard Overlook'       => 'orchard_overlook',
								  "Bauer's Estate"         => 'bauers_estate',
								  "Battle's Hollow"        => 'battles_hollow',
								  'Temple of Lost Prayers' => 'temple_of_lost_prayers'
								}.each {|name, path|
									rule %Q{&[data-name="#{name}"]} do
										content "url(img/#{path}.png)"

										%w[red blue green].each do |color|
											rule "&.#{color}" do
												content "url(img/#{path}.#{color}.png)"
											end
										end
									end
								}
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

						rule '&.medium' do
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
