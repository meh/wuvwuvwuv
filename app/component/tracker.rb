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
			@name       = name
			@map        = Map.const_get(name.capitalize).new
			@objectives = @map.map { |o| Objective.new(o) }
		end

		on 'page:load' do
			@objectives.each {|objective|
				objective.trigger! 'page:load'
			}
		end

		on 'page:unload' do
			@objectives.each {|objective|
				objective.trigger! 'page:unload'
			}
		end

		on :render do
			element.add_class @name
		end

		tag class: :tracker

		html do |_|
			# this be for the side width control shit
			_.div.control

			_.div.objectives do
				@objectives.each do |objective|
					_ << objective
				end
			end
		end

		css do
			text align: :center

			rule '.objectives' do
				display 'inline-block'

				background image: 'linear-gradient(to bottom, rgba(0,0,0,0.30), rgba(0,0,0,0))'

				border style: :solid,
				       width: [2.px, 0, 0, 0],
				       image: 'linear-gradient(to right, rgba(0, 0, 0, 0), black, rgba(0, 0, 0, 0)) 1'
			end

			rule '&.blue', '&.green', '&.red' do
				rule '.objective:nth-child(13)' do
					border right: [1.px, :solid, :black]
					padding right: 5.px
				end
			end

			rule '&.eternal' do
				# Jerrifer
				rule '.objective:nth-child(7)' do
					border right: [1.px, :solid, :black]
					padding right: 1.px
				end

				# Mendon
				rule '.objective:nth-child(8)' do
					padding left: 2.px
				end

				# Veloka
				rule '.objective:nth-child(14)' do
					border right: [1.px, :solid, :black]
					padding right: 1.px
				end

				# Bravost
				rule '.objective:nth-child(15)' do
					padding left: 1.px
				end

				# Langor
				rule '.objective:nth-child(21)' do
					border right: [1.px, :solid, :black]
					padding right: 2.px
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

			media '(max-width: 1024px)' do
				# RIP ;_;
			end

			media '(max-width: 1280px)' do
				rule 'body.small', 'body.normal' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 10.px
							width 34.px

							rule '.timer' do
								font size: 14.px
							end
						end
					end
				end
			end

			media '(max-width: 1366px)' do
				rule 'body.small' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 10.px
							width 37.px

							rule '.timer' do
								font size: 14.px
							end
						end
					end
				end

				rule 'body.normal' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 10.px
							width 34.px

							rule '.timer' do
								font size: 14.px
							end
						end
					end
				end
			end

			media '(max-width: 1440px)' do
				rule 'body.small' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 11.px
							width 41.px

							rule '.timer' do
								font size: 14.px
							end
						end
					end
				end

				rule 'body.normal' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 10.px
							width 38.px

							rule '.timer' do
								font size: 14.px
							end
						end
					end
				end

				rule 'body.large' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 10.px
							width 36.px

							rule '.timer' do
								font size: 14.px
							end
						end
					end
				end
			end

			media '(max-width: 1680px)' do
				rule 'body.small' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 14.px
							width 52.px

							rule '.timer' do
								font size: 14.px
							end
						end
					end
				end

				rule 'body.small', 'body.normal' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 13.px
							width 48.px

							rule '.timer' do
								font size: 14.px
							end
						end
					end
				end

				rule 'body.large' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 13.px
							width 47.px

							rule '.timer' do
								font size: 15.px
							end
						end
					end
				end

				rule 'body.larger' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 12.px
							width 43.px

							rule '.timer' do
								font size: 16.px
							end
						end
					end
				end
			end

			media '(max-width: 1920px)' do
				rule 'body.small', 'body.normal' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 14.px
							width 50.px

							rule '.timer' do
								font size: 14.px
							end
						end
					end
				end

				rule 'body.large' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 15.px
							width 56.px

							rule '.timer' do
								font size: 15.px
							end
						end
					end
				end

				rule 'body.larger' do
					rule '.tracker.eternal' do
						rule '.objective' do
							font size: 15.px
							width 54.px

							rule '.timer' do
								font size: 16.px
							end
						end
					end
				end
			end
		end
	end
end

require 'component/tracker/objective'
