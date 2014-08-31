#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

class Mumble
	include Native

	def initialize(embed)
		super(`embed.snapshot()`)
	end

	alias_native :tick
	alias_native :name

	def identity
		JSON.parse(`#@native.identity`)
	end

	def avatar
		Space.new(`#@native.avatar`)
	end

	def camera
		Space.new(`#@native.camera`)
	end

	class Space
		include Native

		def position
			Vector.new(`#@native.position`)
		end

		def front
			Vector.new(`#@native.front`)
		end

		def top
			Vector.new(`#@native.top`)
		end
	end

	class Vector
		include Native

		alias_native :x
		alias_native :y
		alias_native :z
	end
end
