require 'discordrb'

require_relative 'mafia_helper'
require_relative 'TOKENS'

bot = Discordrb::Commands::CommandBot.new token: TOKEN_VALUE, client_id: CLIENT_ID_VALUE, prefix: '!'

mafia_init()

# Put user in array of players
bot.command :test do |event, action|

	case action
	
	when "start"
	
		if event.channel.name == 'umitest'
		
			if $can_join
			
				if $mafia_players.length < $max_players
					$mafia_players.push(Player.new(event.user))
					puts $mafia_players[$mafia_players.length - 1].player.pm($mafia_players[$mafia_players.length - 1].player.name + ' has joined as player ' + $mafia_players.length.to_s)
					
					if $mafia_players.length >= 2
					
						if $join_ending
							$join_ending = false
							puts 'Game starting in 1 seconds'
							sleep(1)
							$can_join = false
							puts 'Game has started'
							assign_roles()
						end
						
					end
					
				else
					puts 'The game is full'
				end
				
			else
				puts 'The game has already started'
			end
			
		end
	
	when "help"
	
		if event.channel.id == event.user.pm.id
	
			i = 0
			
			while i < $mafia_players.length
				if event.user.id == $mafia_players[i].player.id
					event.respond($mafia_players[i].role.help_text())
					break
				end
				i += 1
			end
		
		end
	
	else
		puts 'Invalid action'
	end
	
end

bot.run