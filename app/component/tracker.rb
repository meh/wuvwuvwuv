#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

module Component
	class Tracker < Lissio::Component
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
			super
		end
	
		def name
			self.class.name.match(/([^:]+)$/)[1].downcase
		end
	
		def type_for(id)
			if el = element.at_css(".icon td[data-id='#{id}'] img")
				(el.class_names - [:red, :blue, :green]).first
			end
		end
	
		def owner_for(id)
			if el = element.at_css(".icon td[data-id='#{id}'] img")
				(el.class_names - [:ruin, :camp, :tower, :keep, :castle]).first || :neutral
			end
		end
	
		def storage(name)
			Application.storage(name)
		end
	
		def start(timers, tiers)
			epoch = Time.new.to_i
	
			timers.each {|id, (_, at)|
				difference = epoch - at
				timer      = element.at_css(".timer td[data-id='#{id}']")
	
				next unless timer
				next if type_for(id) == :ruin
	
				if difference > 0 && difference <= 5 * 60
					remaining = (5 * 60) - difference
					minutes   = (remaining / 60).floor
					seconds   = remaining % 60
	
					timer.inner_text = '%d:%02d' % [minutes, seconds]
				end
			}
	
			tiers.each {|id, tier|
				if el = element.at_css(".icon td[data-id='#{id}'] .tier")
					el.inner_text = tier
				end
			}
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
	
					if minutes == 4 && seconds > 50
						e[:class] = :highest
					elsif minutes >= 3
						e[:class] = :high
					elsif minutes >= 1
						e[:class] = :medium
					elsif seconds > 10
						e[:class] = :low
					else
						e[:class] = :lowest
					end
				end
			}
	
			storage(:sieges).each {|id, at|
				if el = element.at_css(".icon td[data-id='#{id}'] .siege")
					diff = Time.new.to_i - at
	
					if diff > 60 * 60
						storage(:sieges).delete(id)
						el.inner_text = ''
					elsif diff > 55 * 60
						el.inner_text = '+'
						el.remove_class :low, :medium, :high
						el.add_class :highest
					elsif diff > 50 * 60
						el.inner_text = '+'
						el.remove_class :low, :medium, :highest
						el.add_class :high
					elsif diff > 30 * 60
						el.inner_text = '+'
						el.remove_class :low, :high, :highest
						el.add_class :medium
					else
						el.inner_text = '+'
						el.remove_class :medium, :high, :highest
						el.add_class :low
					end
				end
			}
		end
	
		def update(details)
			details.__send__(name).each {|o|
				timer = element.at_css(".timer td[data-id='#{o.id}']")
				icon  = element.at_css(".icon td[data-id='#{o.id}'] img")
				tier  = element.at_css(".icon td[data-id='#{o.id}'] .tier")
				siege = element.at_css(".icon td[data-id='#{o.id}'] .siege")
				owner = owner_for(o.id)
	
				if owner != o.owner
					icon.remove_class owner
	
					unless o.owner == :neutral
						icon.add_class o.owner
					end
	
					if type_for(o.id) != :ruin && owner != :neutral
						timer.inner_text = '5:00'
						tier.inner_text  = ''
						siege.inner_text = ''
	
						storage(:tiers).delete(o.id.to_s)
					end
				end
			}
		end
	
		on :click, '.icon img' do |e|
			id = e.on.parent.data[:id]
	
			next if type_for(id) == :ruin
	
			storage(:tiers).tap {|s|
				t  = s[id] || 0
				el = element.at_css(".icon td[data-id='#{id}'] .tier")
	
				if t == 3 || (t == 2 && type_for(id) == :camp)
					s.delete(id)
					el.inner_text = ''
				else
					s[id] = el.inner_text = t + 1
				end
			}
		end
	
		on 'context:menu', '.icon img' do |e|
			id = e.on.parent.data[:id]
	
			storage(:sieges)[id] = Time.new.to_i
		end

		on :render do
			element.add_class name
		end

		tag class: :tracker
	
		html do |_|
			_.div.control

			_.table do
				_.tr.icon do
					objectives.each do |o|
						if o.separator?
							_.td.separator
							_.td.separator.space
							next
						end
	
						_.td.data(id: o.id) do
							_.div.siege
							_.div.tier
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

		css do
			text align: :center
	
			rule '.highest' do
				text shadow: (', 0 0 2px #b20000' * 10)[1 .. -1] +
				             (', 0 0 1px #b20000' * 10)
	
				animation 'blink 1s linear infinite'
			end
	
			rule '.high' do
				text shadow: (', 0 0 2px #b20000' * 10)[1 .. -1] +
				             (', 0 0 1px #b20000' * 10)
			end
	
			rule '.medium' do
				text shadow: (', 0 0 2px #ff6000' * 10)[1 .. -1] +
				             (', 0 0 1px #ff6000' * 10)
			end
	
			rule '.low' do
				text shadow: (', 0 0 2px #007a20' * 10)[1 .. -1] +
				             (', 0 0 1px #007a20' * 10)
			end
	
			rule '.lowest' do
				text shadow: (', 0 0 2px #007a20' * 10)[1 .. -1] +
				             (', 0 0 1px #007a20' * 10)
	
				animation 'blink 1s linear infinite'
			end
	
			rule 'table' do
				border spacing: 0
				display 'inline-block'
	
				background image: 'linear-gradient(to bottom, rgba(0,0,0,0.30), rgba(0,0,0,0))'
	
				border style: :solid,
				       width: [2.px, 0, 0, 0],
				       image: 'linear-gradient(to right, rgba(0, 0, 0, 0), black, rgba(0, 0, 0, 0)) 1'
	
				padding bottom: 10.px
	
				rule 'tr' do
					rule '&:first-child' do
						rule 'td' do
							padding top: 3.px
						end
					end
	
					rule 'td' do
						text align: :center
						padding 0
						position :relative
	
						rule '&:first-child' do
							padding left: 3.px
	
							rule '.siege' do
								left 9.px
							end
						end
	
						rule '&:last-child' do
							padding right: 3.px
	
							rule '.tier' do
								right 9.px
							end
						end
	
						rule '&.separator' do
							width! 0
	
							border right: [1.px, :solid, :black]
	
							rule '&.space' do
								border :none
								width 1.px
							end
						end
	
						rule '.tier' do
							position :absolute
							top 10.px
							right 6.px
							font size: 14.px
						end
	
						rule '.siege' do
							position :absolute
							top 10.px
							left 6.px
							font size: 14.px
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
						end
					end
				end
			end
		end

		css! do
#			rule '.tracker .control' do
#				position :absolute
#				top 0
#				right 0
#				border left: [1.px, :solid, :black]
#				height 400.px
#			end
#
#			rule 'body.small .tracker .control' do
#				width 260.px
#			end
#
#			rule 'body.normal .tracker .control' do
#				width 300.px
#			end
#
#			rule 'body.large .tracker .control' do
#				width 320.px
#			end
#
#			rule 'body.larger .tracker .control' do
#				width 360.px
#			end

			rule 'body.small', 'body.normal' do
				rule '.tracker' do
					font size: 14.px

					rule 'table' do
						rule 'tr' do
							rule 'td' do
								width 40.px
							end
						end
					end
				end
			end

			rule 'body.large' do
				rule '.tracker' do
					font size: 15.px

					rule 'table' do
						rule 'tr' do
							rule 'td' do
								width 44.px
							end
						end
					end
				end
			end

			rule 'body.larger' do
				rule '.tracker' do
					font size: 16.px

					rule 'table' do
						rule 'tr' do
							rule 'td' do
								width 46.px
							end
						end
					end
				end
			end

			media '(max-width: 1024px)' do
				# RIP ;_;
			end

			media '(max-width: 1280px)' do
				rule 'html body.small', 'html body.normal' do
					rule '.tracker' do
						rule '&.eternal' do
							font size: 10.px

							rule 'table' do
								rule 'tr' do
									rule 'td' do
										width 34.px
									end

									rule '&.timer' do
										rule 'td' do
											font size: 14.px
										end
									end
								end
							end
						end
					end
				end
			end

			media '(max-width: 1366px)' do
				rule 'html body.small', 'html body.normal' do
					rule '.tracker' do
						rule '&.eternal' do
							font size: 10.px

							rule 'table' do
								rule 'tr' do
									rule 'td' do
										width 34.px
									end

									rule '&.timer' do
										rule 'td' do
											font size: 14.px
										end
									end
								end
							end
						end
					end
				end
			end

			media '(max-width: 1440px)' do
				rule 'html body.small', 'html body.normal' do
					rule '.tracker' do
						rule '&.eternal' do
							font size: 10.px

							rule 'table' do
								rule 'tr' do
									rule 'td' do
										width 38.px
									end

									rule '&.timer' do
										rule 'td' do
											font size: 14.px
										end
									end
								end
							end
						end
					end
				end

				rule 'html body.large' do
					rule '.tracker' do
						rule '&.eternal' do
							font size: 10.px

							rule 'table' do
								rule 'tr' do
									rule 'td' do
										width 36.px
									end

									rule '&.timer' do
										rule 'td' do
											font size: 14.px
										end
									end
								end
							end
						end
					end
				end
			end

			media '(max-width: 1680px)' do
				rule 'html body.small', 'html body.normal' do
					rule '.tracker' do
						rule '&.eternal' do
							font size: 13.px

							rule 'table' do
								rule 'tr' do
									rule 'td' do
										width 48.px
									end

									rule '&.timer' do
										rule 'td' do
											font size: 14.px
										end
									end
								end
							end
						end
					end
				end

				rule 'html body.large' do
					rule '.tracker' do
						rule '&.eternal' do
							font size: 12.px

							rule 'table' do
								rule 'tr' do
									rule 'td' do
										width 46.px
									end

									rule '&.timer' do
										rule 'td' do
											font size: 15.px
										end
									end
								end
							end
						end
					end
				end

				rule 'html body.larger' do
					rule '.tracker' do
						rule '&.eternal' do
							font size: 12.px

							rule 'table' do
								rule 'tr' do
									rule 'td' do
										width 43.px
									end

									rule '&.timer' do
										rule 'td' do
											font size: 16.px
										end
									end
								end
							end
						end
					end
				end
			end

			media '(max-width: 1920px)' do
				rule 'html body.small', 'html body.normal' do
					rule '.tracker' do
						rule '&.eternal' do
							font size: 14.px

							rule 'table' do
								rule 'tr' do
									rule 'td' do
										width 50.px
									end

									rule '&.timer' do
										rule 'td' do
											font size: 14.px
										end
									end
								end
							end
						end
					end
				end

				rule 'html body.large' do
					rule '.tracker' do
						rule '&.eternal' do
							font size: 15.px

							rule 'table' do
								rule 'tr' do
									rule 'td' do
										width 56.px
									end

									rule '&.timer' do
										rule 'td' do
											font size: 15.px
										end
									end
								end
							end
						end
					end
				end

				rule 'html body.larger' do
					rule '.tracker' do
						rule '&.eternal' do
							font size: 15.px

							rule 'table' do
								rule 'tr' do
									rule 'td' do
										width 54.px
									end

									rule '&.timer' do
										rule 'td' do
											font size: 16.px
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

require 'component/tracker/green'
require 'component/tracker/red'
require 'component/tracker/blue'
require 'component/tracker/eternal'
