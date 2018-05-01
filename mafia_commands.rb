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
					
					event.respond($mafia_players[$mafia_players.length - 1].player.pm($mafia_players[$mafia_players.length - 1].player.name + ' has joined as Player ' + $mafia_players.length.to_s))
					
					if $mafia_players.length >= 2
					
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
							
							event.respond("Idol Mafia has started! Remember that due to the malleability of Discord names, you use your role action by referring to the Player Number rather than the username. Example: `!assign 4` to assign homework to Player 4.")
							sleep(1)
							
							loop do
								mafia_night()
								event.respond("Welcome to the #{$mafia_night} night of Idol Mafia. PM me your action for the night, or whisper `!mafia help` for instructions. You have 3 minutes before morning comes. If you don't make a move by then, you will be removed from the game.")
								sleep(1)
								event.respond(list_players())
								sleep(1) until $is_morning
								event.respond('It is morning!')
								sleep(1)
								# Do election stuff here
								reset_day_action()
								# Reset all players' night_action
								reset_night_action()
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

# Command to idle for certain roles
bot.command :idle do |event|

	# Respond to command only in PM
	if event.channel.id == event.user.pm.id
	
		i = 0
		while i < $mafia_players.length
			# Check if player is in game
			if event.user.id == $mafia_players[i].player.id
				# Check that player is a role that can't idle
				if $mafia_players[i].role.name == 'Kotori' || $mafia_players[i].role.name == 'Maki' ||  $mafia_players[i].role.name == 'Hanayo' || $mafia_players[i].role.name == 'Nozomi'
					event.respond('Your role cannot idle. You must do your role command')
				else
					event.respond($mafia_players[i].role.idle)
					end_night()
				end
				
				return
				
			end
			
			i += 1
		end
		
		event.respond('You are not in the current game!')
		return
	
	end
	
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
					# Check that player number is valid
					begin
						target = target.to_i
						if target > 0 && target <= $mafia_players_ordered.length
							event.respond($mafia_players[i].role.assign(target))
							# Insert function to check that everyone has finished their move, loop of role night actions
						else
							event.respond('Not a valid player number!')
						end
					rescue
						event.respond('Something went wrong. Did you put an integer after your command?')
					end
					
					return
					
				else
					event.respond('That is not a valid action for your role!')
					return
				end
			
			end
			i += 1
		end
		
		event.respond('You are not in the current game!')
		return
	
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
				# Check that player is President
				if $mafia_players[i].role.name == $president_name
					# Check that player number is valid
					begin
						target = target.to_i
						if target > 0 && target <= $mafia_players_ordered.length
							event.respond($mafia_players[i].role.follow(target))
							# Insert function to check that everyone has finished their move, loop of role night actions
						else
							event.respond('Not a valid player number!')
						end
					rescue
						event.respond('Something went wrong. Did you put an integer after your command?')
					end
					
					return
					
				else
					event.respond('That is not a valid action for your role!')
					return
				end
			
			end
			i += 1
		end
		
		event.respond('You are not in the current game!')
		return
	
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
				# Check that player is President
				if $mafia_players[i].role.name == $president_name
					# Check that player number is valid
					begin
						target = target.to_i
						if target > 0 && target <= $mafia_players_ordered.length
							event.respond($mafia_players[i].role.help(target))
							# Insert function to check that everyone has finished their move, loop of role night actions
						else
							event.respond('Not a valid player number!')
						end
					rescue
						event.respond('Something went wrong. Did you put an integer after your command?')
					end
					
					return
					
				else
					event.respond('That is not a valid action for your role!')
					return
				end
			
			end
			i += 1
		end
		
		event.respond('You are not in the current game!')
		return
	
	end

end



bot.run