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
	class Mumble < Lissio::Component
		def new
			::Mumble.new(element.to_n)
		end

		def available?
			`#{element.to_n}.name == "Guild Wars 2"`
		end

		tag name: :embed, width: 0, height: 0, type: 'application/x-mumble-link'

		css do
			position :absolute
			top -5.px
			left -5.px
		end
	end
end
