require 'discordrb'

require_relative 'mafia_helper'
require_relative 'TOKENS'

bot = Discordrb::Commands::CommandBot.new token: TOKEN_VALUE, client_id: CLIENT_ID_VALUE, prefix: '!'

mafia_init()

# Command to start a game and join
bot.command :test do |event, action|

	action = action.downcase

	case action
	
	when 'start'
	
		if event.channel.name == 'umitest'
		
			if $can_join
			
				$channel_id = event.channel.id
			
				if $mafia_players.length < $max_players
					$mafia_players.push(Player.new(event.user))
					
					event.respond($mafia_players[$mafia_players.length - 1].player.pm($mafia_players[$mafia_players.length - 1].player.name + ' has joined as player ' + $mafia_players.length.to_s))
					
					if $mafia_players.length >= 1
					
						if $join_ending
							$join_ending = false
							puts 'Game starting in 10 seconds'
							# Adjust sleep time
							sleep(1)
							$can_join = false
							puts 'Game has started'
							$president_name = 'Eli'
							assign_roles()
							$mafia_night_counter = 0
							
							loop do
								mafia_night()
								event.respond("Welcome to the #{$mafia_night} night of Idol Mafia. PM me your action for the night, or whisper `!mafia help` for instructions. You have 3 minutes before morning comes. If you don't make a move by then, you will be removed from the game.")
								sleep(1)
								event.respond(list_players())
								sleep(1) until $is_morning
								event.respond('It is morning!')
								sleep(1)
								
							end
							
						end
						
					end
					
				else
					puts 'The game is full'
				end
				
			else
				puts 'The game has already started'
			end
			
		end
	
	when 'help'
	
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
		
	when 'morning'
	
		$is_morning = true
		puts('Set to morning')
	
	else
		puts 'Invalid action'
		
	end
	
end

# Command to create N Player
bot.command :dummy do |event, number|
	i = 1
	while i <= number.to_i
		$mafia_players.push(Player.new(event.user))
		$mafia_players[$mafia_players.length - 1].name = "Dummy #{i}"
		$mafia_players[$mafia_players.length - 1].role = N_Card.new
		i += 1
	end
	
	event.respond("Created #{number} Dummy players")
end


# Command for Eli to assign homework
bot.command :assign do |event, target|
	
	# Respond to command only in PM
	if event.channel.id == event.user.pm.id
	
		i = 0
		while i < $mafia_players.length
			# Check if player is in game
			if event.user.id == $mafia_players[i].player.id
				# Check that player is President
				if $mafia_players[i].role.name == $president_name
					# Check if you are assigning yourself
					if target == $mafia_players[i].player.name
						event.respond('You cannot assign homework to yourself!')
					else
						event.respond($mafia_players[i].role.assign(target))
					end
				else
					
				end
			end
			i += 1
		end
		
		return 'That is not a valid action for your role.'
	
	end

end

# Command for Kotori to follow

bot.command :follow do |event, target|
	
	# Respond to command only in PM
	if event.channel.id == event.user.pm.id
	
		i = 0
		while i < $mafia_players.length
			# Check if player is in game
			if event.user.id == $mafia_players[i].player.id
				# Check that player is Kotori
				if $mafia_players[i].role.name == 'Kotori'
					# Check if you are following yourself
					if target == $mafia_players[i].player.name
						event.respond('You cannot follow yourself!')
					else
						event.respond($mafia_players[i].role.follow(target))
					end
				end
			end
			i += 1
		end
		
		return 'That is not a valid action for your role.'
	
	end

end

# Command for Maki to help
bot.command :help do |event, target|
	
	# Respond to command only in PM
	if event.channel.id == event.user.pm.id
	
		i = 0
		while i < $mafia_players.length
			# Check if player is in game
			if event.user.id == $mafia_players[i].player.id
				# Check that player is Maki
				if $mafia_players[i].role.name == 'Maki'
						event.respond($mafia_players[i].role.follow(target))
				end
			end
			i += 1
		end
		
		return 'That is not a valid action for your role.'
	
	end

end



bot.run