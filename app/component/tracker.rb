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
		attr_reader :name

		def initialize(name)
			@name = name
			@map  = Map.const_get(name.capitalize).new
		end

		on :render do
			element.add_class @name

			epoch = Time.new.to_i

			@map.each {|objective|
				next if objective.ruin?

				difference = epoch - objective.capped

				if difference > 0 && difference <= 5 * 60
					timer     = element.at_css(".timer td[data-id='#{objective.id}']")
					remaining = (5 * 60) - difference
					minutes   = (remaining / 60).floor
					seconds   = remaining % 60

					timer.inner_text = '%d:%02d' % [minutes, seconds]
					timer.add_class :active

					if minutes == 4 && seconds > 45
						timer.add_class :highest
					elsif minutes >= 3
						timer.add_class :high
					elsif minutes >= 1
						timer.add_class :medium
					elsif seconds > 10
						timer.add_class :low
					else
						timer.add_class :lowest
					end
				end

				if objective.tier > 0
					element.at_css(".icon td[data-id='#{objective.id}'] .tier").inner_text = objective.tier
				end

				if objective.owner != :neutral
					icon = element.at_css(".icon td[data-id='#{objective.id}'] img")
					icon.add_class objective.owner
				end
			}

			sieges

			every 1 do
				timers
			end

			every 60 do
				sieges
			end

			$window.on :storage do |e|
				next unless e.key.start_with? @map.name

				_, id = e.key.split('.')

				objective = @map[id]
				objective.reload

				icon  = element.at_css(".icon td[data-id='#{objective.id}'] img")
				tier  = element.at_css(".icon td[data-id='#{objective.id}'] .tier")
				siege = element.at_css(".icon td[data-id='#{objective.id}'] .siege")
				timer = element.at_css(".timer td[data-id='#{objective.id}']")

				icon.remove_class :red, :green, :blue

				unless objective.owner == :neutral
					icon.add_class objective.owner
				end

				if !objective.ruin?
					tier.inner_text  = ''
					siege.inner_text = ''
					timer.inner_text = '4:55'
					timer.add_class :active
				end
			end
		end

		def timers
			element.css('.timer .active').each {|e|
				minutes, seconds = e.inner_text.split(':').map(&:to_i)

				if minutes == 0 && seconds == 1
					e.inner_text = ''
					e.remove_class :active, :lowest

					next
				end

				if seconds == 0
					e.inner_text = "%d:59" % (minutes - 1)
				else
					e.inner_text = "%d:%02d" % [minutes, seconds - 1]
				end

				if minutes == 4 && seconds == 55
					e.add_class :highest
				elsif minutes == 4 && seconds == 45
					e.remove_class :highest
					e.add_class :high
				elsif minutes == 3 && seconds == 0
					e.remove_class :high
					e.add_class :medium
				elsif minutes == 1 && seconds == 0
					e.remove_class :medium
					e.add_class :low
				elsif minutes == 0 && seconds == 10
					e.remove_class :low
					e.add_class :lowest
				end
			}
		end

		def sieges
			@map.each {|objective|
				el   = element.at_css(".icon td[data-id='#{objective.id}'] .siege")
				diff = Time.new.to_i - objective.refreshed

				if diff > 60 * 60
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
			}
		end

		on :click, '.icon img' do |e|
			id        = e.on.parent.data[:id]
			objective = @map[id]

			next if objective.ruin?

			tier = element.at_css(".icon td[data-id='#{id}'] .tier")

			if objective.tier == 3 || (objective.tier == 2 && objective.camp?)
				objective.tier = 0
				tier.inner_text = ''
			else
				objective.tier += 1
				tier.inner_text = objective.tier
			end

			objective.save
		end

		on 'context:menu', '.icon img' do |e|
			id        = e.on.parent.data[:id]
			objective = @map[id]

			objective.refreshed = Time.new.to_i
			objective.save

			sieges
		end

		tag class: :tracker

		html do |_|
			_.div.control

			_.table do
				_.tr.icon do
					@map.each do |o|
						_.td.data(id: o.id) do
							_.div.siege
							_.div.tier
							_.img(class: o.type).data(name: o.name)
						end
					end
				end

				_.tr.name do
					@map.each do |o|
						_.td.data(id: o.id) do
							if o.ruin? || Application.state["cardinal.#{o.type}"]
								_.div.cardinal o.location.upcase
							else
								_.div o.name
							end
						end
					end
				end

				_.tr.timer do
					@map.each do |o|
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

			rule '&.blue', '&.green', '&.red' do
				rule 'td:nth-child(13)' do
					border right: [1.px, :solid, :black]
					padding right: 2.px
				end

				rule 'td:nth-child(14)' do
					padding left: 1.px
				end
			end

			rule '&.eternal' do
				# Jerrifer
				rule 'td:nth-child(7)' do
					border right: [1.px, :solid, :black]
					padding right: 1.px
				end

				# Mendon
				rule 'td:nth-child(8)' do
					padding left: 2.px
				end

				# Veloka
				rule 'td:nth-child(14)' do
					border right: [1.px, :solid, :black]
					padding right: 1.px
				end

				# Bravost
				rule 'td:nth-child(15)' do
					padding left: 1.px
				end

				# Langor
				rule 'td:nth-child(21)' do
					border right: [1.px, :solid, :black]
					padding right: 2.px
				end
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
