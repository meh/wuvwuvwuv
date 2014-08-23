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
	class Green < self
		objective do
			id 49
			name 'Workshop', 'Bluevale Refuge', 'Vale'
			type :camp
			location :sw
		end

		objective do
			id 45
			name 'Tower', 'Bluebriar', 'Briar'
			type :tower
			location :sw
		end

		objective do
			id 44
			name 'Keep', 'Dreadfall Bay', 'Bay'
			type :keep
			location :w
		end

		objective do
			id 48
			name 'Quarry', 'Faithleap', 'Faith'
			type :camp
			location :nw
		end

		objective do
			id 47
			name 'Tower', 'Sunnyhill', 'Sunny'
			type :tower
			location :nw
		end

		objective do
			id 56
			name 'Crossroads', 'The Titanpaw', 'North'
			type :camp
			location :n
		end

		objective do
			id 46
			name 'Keep', 'Garrison', 'Garri'
			type :keep
			location :c
		end

		objective do
			id 43
			name 'Orchard', "Hero's Lodge", 'South'
			type :camp
			location :s
		end

		objective do
			id 57
			name 'Tower', 'Cragtop', 'Crag'
			type :tower
			location :ne
		end

		objective do
			id 54
			name 'Lumber Mill', 'Foghaven', 'Fog'
			type :camp
			location :ne
		end

		objective do
			id 41
			name 'Keep', 'Shadaran Hills', 'Hills'
			type :keep
			location :e
		end

		objective do
			id 42
			name 'Tower', 'Redlake', 'Lake'
			type :tower
			location :se
		end

		objective do
			id 55
			name 'Fishing Village', 'Redwater Lowlands', 'Water'
			type :camp
			location :se
		end

		objective do
			id 74
			name "Bauer's Estate"
			type :ruin
			location :nw
		end

		objective do
			id 75
			name "Battle's Hollow"
			type :ruin
			location :sw
		end

		objective do
			id 76
			name 'Temple of Lost Prayers'
			type :ruin
			location :s
		end

		objective do
			id 72
			name "Carver's Ascent"
			type :ruin
			location :se
		end

		objective do
			id 73
			name 'Orchard Overlook'
			type :ruin
			location :ne
		end
	end
end
