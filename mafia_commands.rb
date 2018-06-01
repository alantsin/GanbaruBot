require 'discordrb'

require_relative 'mafia_helper'
require_relative 'TOKENS'

bot = Discordrb::Commands::CommandBot.new token: TOKEN_VALUE, client_id: CLIENT_ID_VALUE, prefix: '!'

mafia_init()

# Command to start a game and join
bot.command :mafia do |event, action|

	action = action.downcase

	case action
	
	when 'start'
	
		if event.channel.name == 'umitest'
		
			if $can_join
			
				# Check that player isn't already joined
				
				i = 0
				
				while i < $mafia_players.length
				
					if event.user.id == $mafia_players[i].player.id
						event.respond('You have already joined this game!')
						return
					end
					
					i += 1
				
				end
			
				if $mafia_players.length < $max_players
					$mafia_players.push(Player.new(event.user))
					$current_players += 1
					event.respond($mafia_players[$mafia_players.length - 1].player.pm($mafia_players[$mafia_players.length - 1].player.name + ' has joined as Player ' + $mafia_players.length.to_s))
					
					if $mafia_players.length >= 2
					
						if $join_ending
							$join_ending = false
							$active_game = true
							puts 'Game starting in 10 seconds'
							# Adjust sleep time
							sleep(1)
							$can_join = false
							puts 'Game has started'
							$president_name = 'Eli'
							assign_roles()
							$mafia_night_counter = 0
							
							event.respond("Idol Mafia has started! Remember that due to the malleability of Discord names, you use your actions by referring to the Player Number rather than the username. Example: `!assign 4` to assign homework to Player 4. You can also do `!mafia players` in the public text channel to see which players have not made a move yet.")
							sleep(1)
							
							loop do
								mafia_night()
								event.respond("Welcome to the #{$mafia_night} night of Idol Mafia. PM me your action for the night, or whisper `!mafia help` for instructions.")
								sleep(1)
								event.respond(list_players())
								sleep(1) until $is_morning
								event.respond('It is morning!')
								sleep(1)
								
								# Do night actions here
								event.respond(rin_cat())
								sleep(1)
								
								event.respond(president_assign())
								sleep(1)
								if end_game()
									event.respond($end_game_message)
									break
								end
								
								event.respond(kotori_follow())
								sleep(1)
								if end_game()
									event.respond($end_game_message)
									break
								end
								
								# Do election stuff here
								reset_day_action()
								sleep(1)
								event.respond('It is now time to elect who will do the daily homework! Do `!elect <Number>` to elect that player, or `!elect 0` to abstain. If the majority of players abstain from electing, no one will be elected. Otherwise, the majority vote will decide. Ties will also result in no one being elected.')
								sleep(1)
								
								event.respond(list_players())
								sleep(1) until $everyone_elected
								
								event.respond('The results are in!')
								sleep(1)
								
								if majority_elected()
								
									event.respond("The majority have decided to elect **#{$elect_target.name}**. #{$elect_target.name} has 30 seconds to explain why they shouldn't do the homework.")
									# Sleep 30
									sleep(1)
									event.respond("It is time to vote! Do `!vote yes` or `!vote no` to decide the fate of #{$elect_target.name}...")
									sleep(1) until $everyone_voted
									
									# Put vote results here
									event.respond('The people have decided...')
									sleep(1)
									if $vote_yes > $vote_no
										
										event.respond("**#{$elect_target.name} will do the daily homework!**\nVote Result: #{$vote_yes} Yes, #{$vote_no} No")
										remove_player($elect_target_index)
										sleep(1)
										
										if end_game()
											event.respond($end_game_message)
											break
										end
									
									else
									
										event.respond("**#{$elect_target.name} will NOT do the daily homework!**\nVote Result: #{$vote_yes} Yes, #{$vote_no} No")
									
									end
									
								else
									event.respond('The majority could not decide who to elect!')
								end
								
								sleep(1)
								
								# Reset all players' night_action
								reset_night_action()
							end
							
							mafia_init()
							
						end
						
					end
					
				else
					event.respond('The game is full')
				end
				
			else
				event.respond('The game has already started')
			end
			
		end
	
	when 'help'
		
		if event.channel.id == event.user.pm.id
			
			if $active_game
		
				i = 0
					
				while i < $mafia_players.length
					if event.user.id == $mafia_players[i].player.id
						event.respond($mafia_players[i].role.help_text())
						break
					end
					i += 1
				end
				
			else
			
				event.respond('No game active right now.')
			
			end
			
		end
		
	when 'players'
	
		if $active_game
			
			waiting_list = ''
			
			i = 0
			
			while i < $mafia_players_ordered.length
	
				if $mafia_players_ordered[i].alive
				
					if !$is_morning
					
						if !$mafia_players_ordered[i].role.night_action
						
							waiting_list = waiting_list + "Player #{i + 1} = #{$mafia_players_ordered[i].name}\n"
							
						end
					
					elsif !$everyone_elected
						
						if !$mafia_players_ordered[i].role.day_action_elect
						
							waiting_list = waiting_list + "Player #{i + 1} = #{$mafia_players_ordered[i].name}\n"
						
						end
						
					else
					
						if !$mafia_players_ordered[i].role.day_action_vote
						
							waiting_list = waiting_list + "Player #{i + 1} = #{$mafia_players_ordered[i].name}\n"
						
						end
					
					end
				
				end
		
				i += 1
				
			end
			
			event.respond("Waiting on the following players to make a move:\n#{waiting_list}")
		
		else
		
			event.respond('No game active right now.')
		
		end
	
	else
	
		event.respond('Invalid action')
		
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

# Command to vote 
bot.command :vote do |event, decision|

	# Respond to command only in channel
	if event.channel.id != event.user.pm.id
	
		if $active_game
	
			i = 0
			while i < $mafia_players.length
			
				# Check if player is in game
				if event.user.id == $mafia_players[i].player.id
				
					# Check if player is alive
					if $mafia_players[i].alive
					
						# Check if player has not voted yet
						
						if !$mafia_players[i].role.day_action_vote
						
							# Check if player is Honoka
							if $mafia_players[i].role.name == 'Honoka'
								n = 1
							else
								n = 0
							end
							
							case decision.downcase
							
							when 'yes'
							
								$vote_yes = $vote_yes + 1 + n
								$mafia_players[i].role.day_action_vote = true
								event.respond("#{$mafia_players[i].player.name} voted Yes")
								end_voting()
							
							when 'no'
							
								$vote_no = $vote_no + 1 + n
								$mafia_players[i].role.day_action_vote = true
								event.respond("#{$mafia_players[i].player.name} voted No")
								end_voting()
								
							else
								event.respond('You must put yes or no for your !vote.')
							end
						
						else
							event.respond('You have already voted today!')
						end
						
						return
						
					else
					
						event.respond('You have been assigned homework to do for the rest of the game!')
						return
						
					end
					
				end
				
				i += 1
				
			end
			
			event.respond('You are not in the current game!')
			return
			
		else
			event.respond('No game active right now.')
		end
	
	end
	
end

# Command to elect 
bot.command :elect do |event, target|

	# Respond to command only in channel
	if event.channel.id != event.user.pm.id
	
		if $active_game
	
			i = 0
			while i < $mafia_players.length
			
				# Check if player is in game
				if event.user.id == $mafia_players[i].player.id
				
					# Check if player is alive
					if $mafia_players[i].alive
					
						# Check if player has not elected yet
						
						if !$mafia_players[i].role.day_action_elect
					
							# Check that player number is valid
							begin
								target = target.to_i
								if target >= 0 && target <= $mafia_players_ordered.length
										
									event.respond($mafia_players[i].name + elect(target))
									$mafia_players[i].role.day_action_elect = true
									end_election()
									
								else
									event.respond('Not a valid player number!')
								end
								
							rescue
								event.respond('Integers only after your command!')
							end
						
						else
							event.respond('You have already elected today!')
						end
						
						return
						
					else
					
						event.respond('You have been assigned homework to do for the rest of the game!')
						return
						
					end
					
				end
				
				i += 1
				
			end
			
			event.respond('You are not in the current game!')
			return
			
		else
			event.respond('No game active right now.')
		end
	
	end
	
end

# Command to idle for certain roles
bot.command :idle do |event|

	# Respond to command only in PM
	if event.channel.id == event.user.pm.id
	
		if $active_game
	
			i = 0
			while i < $mafia_players.length
			
				# Check if player is in game
				if event.user.id == $mafia_players[i].player.id
				
					# Check if player is alive
					if $mafia_players[i].alive
					
						# Check that player is a role that can't idle
						if $mafia_players[i].role.name == 'Kotori' || $mafia_players[i].role.name == 'Maki' ||  $mafia_players[i].role.name == 'Hanayo' || $mafia_players[i].role.name == 'Nozomi'
							event.respond('Your role cannot idle. You must do your role command')
						else
							event.respond($mafia_players[i].role.idle)
							end_night()
						end
						
						return
						
					else
						event.respond('You have been assigned homework to do for the rest of the game!')
						return
					end
					
				end
				
				i += 1
			end
			
			event.respond('You are not in the current game!')
			return
			
		else
		
			event.respond('No game active right now.')
		
		end
	
	end
	
end

# Command for Eli to assign homework
bot.command :assign do |event, target|
	
	# Respond to command only in PM
	if event.channel.id == event.user.pm.id
	
		if $active_game
	
			i = 0
			while i < $mafia_players.length
			
				# Check if player is in game
				if event.user.id == $mafia_players[i].player.id
				
					# Check if player is alive
					if $mafia_players[i].alive
					
						# Check that player is President
						if $mafia_players[i].role.name == $president_name
							# Check that player number is valid
							begin
								target = target.to_i
								if target > 0 && target <= $mafia_players_ordered.length
									event.respond($mafia_players[i].role.assign(target))
									end_night()
								else
									event.respond('Not a valid player number!')
								end
							rescue
								event.respond('Integers only after your command!')
							end
							
							return
							
						else
							event.respond('That is not a valid action for your role!')
							return
						end
						
					else
					
						event.respond('You have been assigned homework to do for the rest of the game!')
						return
					
					end
				
				end
				i += 1
			end
			
			event.respond('You are not in the current game!')
			return
			
		else
		
			event.respond('No game active right now.')
		
		end
	
	end

end

# Command for Kotori to follow

bot.command :follow do |event, target|
	
	# Respond to command only in PM
	if event.channel.id == event.user.pm.id
	
		if $active_game
	
			i = 0
			while i < $mafia_players.length
			
				# Check if player is in game
				if event.user.id == $mafia_players[i].player.id
				
					# Check if player is alive
					if $mafia_players[i].alive
					
						# Check that player is Kotori
						if $mafia_players[i].role.name == 'Kotori'
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
								event.respond('Integers only after your command!')
							end
							
							return
							
						else
							event.respond('That is not a valid action for your role!')
							return
						end
						
					else
					
						event.respond('You have been assigned homework to do for the rest of the game!')
						return
					
					end
				
				end
				i += 1
			end
			
			event.respond('You are not in the current game!')
			return
			
		else
		
			event.respond('No game active right now.')
		
		end
	
	end

end

# Command for Maki to help
bot.command :help do |event, target|
	
	# Respond to command only in PM
	if event.channel.id == event.user.pm.id
	
		if $active_game
	
			i = 0
			while i < $mafia_players.length
			
				# Check if player is in game
				if event.user.id == $mafia_players[i].player.id
				
					# Check if player is alive
					if $mafia_players[i].alive
					
						# Check that player is Maki
						if $mafia_players[i].role.name == 'Maki'
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
								event.respond('Integers only after your command!')
							end
							
							return
							
						else
							event.respond('That is not a valid action for your role!')
							return
						end
						
					else
					
						event.respond('You have been assigned homework to do for the rest of the game!')
						return
					
					end
				
				end
				i += 1
			end
			
			event.respond('You are not in the current game!')
			return
			
		else
		
			event.respond('No game active right now.')
		
		end
	
	end

end


bot.run