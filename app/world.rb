#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

class World
	HASH = {
		1008 => 'Jade Quarry',
		2006 => 'Underworld',
		1023 => "Devona's Rest",
		2105 => 'Arborstone',
		1014 => 'Crystal Desert',
		1022 => 'Kaineng',
		2001 => 'Fissure of Woe',
		1001 => 'Anvil Rock',
		2003 => 'Gandara',
		1003 => "Yak's Bend",
		2007 => 'Far Shiverpeaks',
		1011 => 'Stormbluff Isle',
		2013 => 'Aurora Glade',
		1016 => 'Sea of Sorrows',
		2005 => 'Ring of Fire',
		2012 => 'Piken Square',
		1012 => 'Darkhaven',
		1005 => 'Maguuma',
		2204 => "Abaddon's Mouth",
		2203 => 'Elona Reach',
		2010 => "Seafarer's Rest",
		2104 => 'Vizunah Square',
		2207 => 'Dzagonur',
		2009 => 'Ruins of Surmia',
		1002 => 'Borlis Pass',
		2002 => 'Desolation',
		1010 => 'Ehmry Bay',
		1024 => 'Eredon Terrace',
		1004 => 'Henge of Denravi',
		1007 => 'Gate of Madness',
		2205 => 'Drakkar Lake',
		2008 => 'Whiteside Ridge',
		1017 => 'Tarnished Coast',
		2101 => 'Jade Sea',
		1013 => 'Sanctum of Rall',
		2014 => "Gunnar's Hold",
		1021 => 'Dragonbrand',
		2301 => 'Baruch Bay',
		2102 => 'Fort Ranik',
		2103 => 'Augury Rock',
		2201 => 'Kodash',
		2202 => 'Riverside',
		2206 => "Miller's Sound",
		1018 => 'Northern Shiverpeaks',
		1015 => 'Isle of Janthir',
		2004 => 'Blacktide',
		1006 => "Sorrow's Furnace",
		2011 => 'Vabbi',
		1009 => 'Fort Aspenwood',
		1020 => "Ferguson's Crossing",
		1019 => 'Blackgate'
	}

	def self.ranks(region)
		Browser::HTTP.get("http://leaderboards.guildwars2.com/en/#{region}/wvw").then {|res|
			text = res.text.gsub('&#x27;', ?')

			Hash[text.scan(%r{class=".*?rank number">[\s\S]*?>\s*(\d+)[\s\S]*?class="name text">\s*([\w' ]+)}m).map {|id, name|
				[name.strip, id.to_i]
			}]
		}
	end

	def self.name(id)
		HASH[id.to_i]
	end

	def self.id(name)
		HASH.key(name)
	end
end
