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
	class Clipboard < Lissio::Component
		def new
			::Clipboard.new(element.to_n)
		end

		tag name: :embed, width: 0, height: 0, type: 'application/x-clipboard'

		css do
			position :absolute
			top -5.px
			left -5.px
		end
	end
end
