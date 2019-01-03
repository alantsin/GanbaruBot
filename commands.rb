require 'discordrb'
require 'json'
require 'nokogiri'
require 'open-uri'

require_relative 'helper'
require_relative 'mafia_helper'
require_relative 'TOKENS'

bot = Discordrb::Commands::CommandBot.new token: TOKEN_VALUE, client_id: CLIENT_ID_VALUE, prefix: '!'

name_array = Array.new # Used to keep track of names to prevent command spam

last_used = '0' # Prevent solo scouts in succession

not_using = true # Prevents concurrent use of !card

get_cards()

mafia_init()

$time_last_updated = Time.new.to_i

$card_count = update_max_cards()

# Command to update all members to the dah role

bot.command :update do |event|
	if event.channel.name == 'umitest'
	
		i = 0
		while i < event.server.members.length
			event.server.members[i].add_role(DEFAULT_ROLE)
			puts("Added " + event.server.members[i].name + " to dah role")
			sleep(2)
			i += 1
		end
		
	end
end

bot.member_join do |event|
	puts event.user.username + " has joined"
		event.user.add_role(DEFAULT_ROLE)
		bot.send_message(TEST_CHANNEL, event.user.username + " has joined and became a dahDUM")
end

bot.member_leave do |event|
	puts event.user.username + " has left"
	bot.send_message(TEST_CHANNEL, event.user.username + " has left and became a :dahUMD:")
end

bot.command :dah, description: "Command to request the dah role if not automatically assigned to you when you joined" do |event|
	if event.channel.name == 'bot-commands'

		if event.user.roles[0].nil?
			event.user.add_role(DEFAULT_ROLE)
			
		else
		
			i = 0
			dah = false
			
			while i < event.user.roles.length
			
				if event.user.roles[i].name == 'dah'
					dah = true
				end
				i += 1
				
			end
			
			if dah
				event.respond("Y-you're already a dah...")
			else
				event.user.add_role(DEFAULT_ROLE)
			end
			
		end
		
	end
	
end

bot.command :card, description: "[Team-Building-Help] Returns data on a card with `!card` *id*. Does not work with special cards. Can only look up one card at a time." do |event, id|

	if event.channel.name == 'team-building-help' || event.channel.name == 'umitest'

		if not_using
		
			id = Integer id rescue nil
		
			if !id.nil?
			
				if (Time.now.to_i - $time_last_updated) > 3600
				
					$card_count = update_max_cards()
					
				end
			
				if ((id >= 0) && (id <= $card_count))
					
					begin
				
						not_using = false
						
						if id == 0
						
							id = $card_count
							
						end
								
						id = id.to_s

						output = openurl(id)
								
						# Upload image and delete
						event.channel.send_file File.new($card_id + '.png')
						File.delete($card_id + '.png') # Delete original
								
						sleep(0.5)
								
						event.respond(output)
						
						event.send_temp('Taking a nap...', 3)
								
						sleep(3)
								
						looking_up = false
						not_using = true
								
						puts ''
								
					rescue
							
						looking_up = false
						not_using = true
						puts ''
								
					end
					
				else
				
					looking_up = false
					event.respond('Not a valid card number...')
					
				end
				
				
			else
			
				looking_up = false
				event.respond('Not a valid card number...')
				
			end
			
		end
	
	end
	
end

bot.command :solo, description: '[Bot-Commands] Does a solo scout with every card in the box. Non-subs must wait for someone else to solo first before they can solo again' do |event, type|

	if event.channel.name == 'bot-commands' || event.channel.name == 'umitest'
	
	if event.user.roles.length > 0
	
		$i = 0
		$not_sub = true
			
		while $i < event.user.roles.length
		
			if event.user.roles[$i].name == 'Untoasted Subs'
				$not_sub = false
			end
			$i += 1
			
		end
		
	end
				
	if $not_sub
		
		if last_used == event.user.id # Non-subs cannot solo in succession
				event.user.pm('G-give someone else a chance first...')
				return		
		end
				
	end
		
	last_used = event.user.id
		
	puts type.nil?
	if type.nil?
		type = ''
	end
	
	number = scout(type.downcase).to_s
	url = "http://schoolido.lu/api/cards/#{number}/"
	obj = JSON.parse(open(url).read)
	image = obj['round_card_image'].to_s
	download = open("https:#{image}")
	IO.copy_stream(download, number + '.png')
		
	# resized_image = MiniMagick::Image.open(number + '.png')
	# resized_image.resize '100x100'
	# resized_image.format 'png'
	# resized_image.write 'resized' + number + '.png'
		
	event.channel.send_file File.new(number + '.png')
		
	File.delete(number + '.png') # Delete original
	# File.delete('resized' + number + '.png') # Delete resized
		 
	puts '' # To prevent returning text in the Discord chat
		
	end
	
end

bot.command :emote, description: '[Sub] [Global] Posts your custom image in the chat' do |event|

# Make a folder for that particular user if one doesn't exist
	unless File.directory?("emojis/#{event.user.id.to_s}")
		Dir.mkdir("emojis/#{event.user.id.to_s}")
	end
	
	begin
		
		if event.user.roles.length > 0
			$i = 0
			$is_sub = false
			
			while $i < event.user.roles.length
				if event.user.roles[$i].name == 'Untoasted Subs'
					$is_sub = true
				end
				$i += 1
			end
			
			if $is_sub
		
				begin
					path = Dir.pwd + '/emojis/' + event.user.id.to_s + '/'
					
					Dir.chdir(path) do
						if file_count(path)
							name = Dir.glob(image_type(path))[0].to_s
							event.channel.send_file File.new(name)
						else
							puts false
						end
					end
					
				rescue
					puts 'User has no image saved'
					event.respond 'Y-you haven\'t saved an image yet...'
					
				end
				
			else
				event.respond 'S-subscriber only feature for now...'
			
			end	
			
		else
			event.respond 'S-subscriber only feature for now...'
			
		end		
		
	rescue
		puts 'Not a sub'
		event.respond 'S-subscriber only feature for now...'
		
	end
	
end

bot.command :save, description: '[Sub] [Bot-Commands] Saves an image for your personal use with \"!save URL\" that you can put in chat with \"!emote\". Supports .jpg, .png, and .gif' do |event, link|

	if event.channel.name == 'bot-commands' || event.channel.name == 'umitest'
	
		begin
		
			if event.user.roles.length > 0
				$i = 0
				$is_sub = false
			
				while $i < event.user.roles.length
					if event.user.roles[$i].name == 'Untoasted Subs'
						$is_sub = true
					end
					$i += 1
				end
				
				if $is_sub

				# Make a folder for that particular user if one doesn't exist
					unless File.directory?("emojis/#{event.user.id.to_s}")
						Dir.mkdir("emojis/#{event.user.id.to_s}")
					end
			 
					begin

					# Save an image
						if is_image(link) # Check if link is supported format
							
							path = Dir.pwd + '/emojis/' + event.user.id.to_s + '/'
								
							if file_count(path) < 1 # If no saved images, save the image
								download = open(link)
								extension = link[link.length - 4, link.length]
								IO.copy_stream(download, path + 'image' + extension, 9000000)
								
								begin
									event.channel.send_file File.new(path + 'image' + extension)
									event.respond 'Saved as custom image...'
									
								rescue
									FileUtils.rm_rf Dir.glob(path)
									event.respond 'Y-your image was too large. Try a different one...'
									
								end
								
							else
								event.respond 'Y-you can only save 1 image... To delete your current one, type \"!delete"'
								
							end
								
						else
							puts 'No link or invalid link'
							event.respond 'O-only supported Discord image types please... (.jpg, .png, .gif)'
						end
						
					rescue
						puts 'No link or invalid link'
						event.respond 'O-only supported Discord image types please... (.jpg, .png, .gif)'
						
					end
					
				else
					event.respond 'S-subscriber only feature for now...'
			
				end	
			
			else
				event.respond 'S-subscriber only feature for now...'
			
			end	
		
		rescue
			puts 'Not a sub'
			event.respond 'S-subscriber only feature for now...'
			
		end
	 
	end
	
end

bot.command :delete, description: '[Sub] [Bot-Commands] Deletes your currently saved image if you want to replace it' do |event|

	if event.channel.name == 'bot-commands' || event.channel.name == 'umitest'
	
		begin
		
			if event.user.roles.length > 0
				$i = 0
				$is_sub = false
			
				while $i < event.user.roles.length
					if event.user.roles[$i].name == 'Untoasted Subs'
						$is_sub = true
					end
					$i += 1
				end
				
				if $is_sub
			
				# Make a folder for that particular user if one doesn't exist
					unless File.directory?("emojis/#{event.user.id.to_s}")
						Dir.mkdir("emojis/#{event.user.id.to_s}")
					end
					
					begin
					
						path = Dir.pwd + '/emojis/' + event.user.id.to_s + '/'
					
					# Delete saved image if there is one
						Dir.chdir(path) do
						
							if file_count(path) > 0
								FileUtils.rm_rf Dir.glob(path)
								event.respond 'Saved image d-deleted...'
								
							else
								event.respond 'N-nothing to delete...'
								
							end
							
						end
					
					rescue
						puts 'Nothing to delete'
						event.respond 'N-nothing to delete...'
					end
				
				else
					event.respond 'S-subscriber only feature for now...'
			
				end	
					
			else
				event.respond 'S-subscriber only feature for now...'
					
			end
			
		rescue
			puts 'Not a sub'
			event.respond 'S-subscriber only feature for now...'
			
		end
			
	end
	
end

# Posts the original size of a custom emoji
bot.command :huge, description: '[Global] HUGE EMOJI' do |event, hugemoji|

		info = hugemoji.split(':')
		prefix = 'https://cdn.discordapp.com/emojis/'
		suffix = info[2].gsub(/[>]/, '.gif')
		image = prefix + suffix
		
		# Check if image is gif
		if Net::HTTP.get_response(URI.parse(image)).code == '415'
			suffix = info[2].gsub(/[>]/, '.png')
			image = prefix + suffix
		end

		download = open(image)
		IO.copy_stream(download, "emojis\\#{download.base_uri.to_s.split('/')[-1]}")
		event.channel.send_file File.new("emojis\\" + suffix)
		File.delete("emojis\\" + suffix)
		puts '' # To prevent returning text in the Discord chat
	
end

# 3 second countdown to help coordinate simultaneous events
bot.command :countdown, description: '[Co-op-Room] A 3-second countdown to help coordinate matches' do |event|

	if event.channel.name == 'co-op-room' || event.channel.name == 'umitest'
  
		if !name_array.include? event.user.name
			name_array.push(event.user.name)
			event.respond 'Get GanbaReady!'
			sleep(1)
			event.respond "3 [#{event.user.name}]"
			sleep(1)
			event.respond "2 [#{event.user.name}]"
			sleep(1)
			event.respond "1 [#{event.user.name}]"
			sleep(1)
			name_array.delete(event.user.name)
			event.respond 'ピギィーーーーッッッ！！！'
			
		else
			event.user.pm('Y-you should wait until your existing countdown is finished...')
			
		end
   
	end
  
end

bot.command :mafiahelp, description: '[bot-commands] Tells you what commands to use for Idol Mafia' do |event|

	event.respond "All commands for Idol Mafia game use the prefix `!mafia ACTION` where action is your action. Here are a list of actions:\n\n**about** - [PM GanbaruBot] Learn about Idol Mafia.\n\n**newgame** - [#bot-commands] Starts a new game of Idol Mafia, can only be used if a game isn't currently active. The person who uses this command gains permissions to use `startgame` and `endgame`\n\n**join** - [#bot-commands] Join a new game of Idol Mafia.\n\n**startgame** - [#bot-commands] Start the game when 5 or more players have joined.\n\n**endgame** - [#bot-commands] End the game prematurely should any bugs occur. Please use responsibly.\n\n**help** - [PM GanbaruBot] Learn about your role in the current game.\n\n**players** - [#bot-commands] Lists the current active players."

end

# Command to start a game and join
bot.command :mafia do |event, action|

	action = action.downcase

	case action
	
	when 'newgame'
	
		if event.channel.name == 'bot-commands'
	
			if $mafiaadmin == nil
				
				$mafia_players.push(Player.new(event.user))
				$current_players += 1
				event.respond($mafia_players[$mafia_players.length - 1].player.pm($mafia_players[$mafia_players.length - 1].player.name + ' has joined as Player ' + $mafia_players.length.to_s))
				
				$mafiaadmin = event.user
				$can_join = true
				puts ''
				
			else
			
				event.respond('A Ggame has already started! Type `!mafia join` to join the game.')
				
			end
			
		end
		
	
	when 'join'
	
		if event.channel.name == 'bot-commands'
		
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
				
				$mafia_players.push(Player.new(event.user))
				$current_players += 1
				event.respond($mafia_players[$mafia_players.length - 1].player.pm($mafia_players[$mafia_players.length - 1].player.name + ' has joined as Player ' + $mafia_players.length.to_s))
				
			else
				event.respond('The game has already started')
			end
			
		end
		
	when 'startgame'
	
		if event.channel.name == 'bot-commands'
	
			if event.user.id != $mafiaadmin.id
			
				event.respond('Only ' + $mafiaadmin.name + ' can start the game')
				return
				
			end
		
			if $mafia_players.length < 5
			
				event.respond('5 or more players must join before starting!')
				
			else
			
				$active_game = true
				$can_join = false
				puts 'Game starting in 5 seconds.'
				assign_roles()
				sleep(5)
								
				event.respond("Idol Mafia has started! Since this is still beta testing, only Honoka, Eli, Kotori, Maki, and Rin exist as unique roles. Everyone else is a N-card that can only !idol. Remember that due to the malleability of Discord names, you use your actions by referring to the Player Number rather than the username. \nExample: `!assign 4` to assign homework to Player 4. \nYou can also do `!mafia players` in #bot-commands to see which players have not made a move yet.")
				sleep(1)
								
				loop do
					mafia_night()
					event.respond("Welcome to the #{$mafia_night} night of Idol Mafia. PM me your action for the night, or PM me `!mafia help` for instructions.")
					sleep(1)
					event.respond(list_players())
					sleep(1) until $is_morning
					event.respond('It is morning!')
					sleep(1)
									
					# Do night actions here
									
					event.respond(president_assign())
					sleep(1)
					if end_game()
							event.respond($end_game_message)
						break
					end
									
					if !$current_kotori.nil?
									
						event.respond(kotori_follow())
						sleep(1)
						if end_game()
							event.respond($end_game_message)
							break
						end
										
					end
									
					# Do election stuff here
					reset_day_action()
					sleep(1)
									
					# Check for Honked
									
					if honk()
									
						$elect_target_index = $current_honoka.honk_target - 1
						$elect_target = $mafia_players_ordered[$elect_target_index]
									
						event.respond("Honoka honked, and got everyone to elect **#{$elect_target.name}**.")
										
					else
									
						event.respond('It is now time to elect who will do the daily homework! Do `!elect <Number>` to elect that player, or `!elect 0` to abstain. If the majority of players abstain from electing, no one will be elected. Otherwise, the majority vote will decide. Ties will also result in no one being elected.')
						sleep(1)
										
						event.respond(list_players())
						sleep(1) until $everyone_elected
										
						event.respond('The results are in!')
						sleep(1)
										
						if majority_elected()
										
							event.respond("The majority have decided to elect **#{$elect_target.name}**.")
										
						else
										
							event.respond('The majority could not decide who to elect!')
							sleep(1)
							reset_night_action()
							next
										
						end
								
					end
									
					# Sleep 10
					sleep(1)
					$can_vote = true
					event.respond("It is time to vote! Do `!vote yes` or `!vote no` to decide the fate of #{$elect_target.name}...")
					sleep(1) until $everyone_voted
									
					event.respond(vote_result())
										
					if end_game()
										
						event.respond($end_game_message)
						break
											
					end
									
					reset_night_action()
									
				end
								
					mafia_init()
				
			end
							
		end
		
	when 'endgame'
	
		if event.user.id == $mafiaadmin.id || event.channel.id == '#umitest'
			mafia_init()
			event.respond('Game ended by admin')
		end		
		
		mafia_init()
	
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
		
	when 'about'
	
		if event.channel.id == event.user.pm.id
		
			event.respond("Idol Mafia is a text-based Discord game based on the party game Mafia.\nThere are two teams, Team Idol and Team Student Council.\nIf you are on Team Idol, you win if you still in the game when all the members of Team Student Council are eliminated.\nIf you are on Team Student Council, you win if you eliminate all members of Team Idol, even if you have been eliminated.\n\nEach player is assigned a role and each role has unique abilities.\nA minimum of 5 players is required to start a game.\nIn a 5-player game, Honoka, Eli, Kotori, Maki, and Rin are in the game. Umi, Hanayo, Nozomi, and Nico will be a part of a 6, 7, 8 or 9 player game.\nEli, Umi, and Nozomi are part of Team Student Council, while the other girls are part of Team Idol.\nWork together with your team to eliminate the other team and claim victory!")
		
		end
	
	else
	
		event.respond('Invalid action')
		
	end
	
end

# Command to create N Player
bot.command :dummy do |event, number|
	if event.channel.name == 'umitest'
		i = 1
		while i <= number.to_i
			$mafia_players.push(Player.new(event.user))
			$mafia_players[$mafia_players.length - 1].name = "Dummy #{i}"
			$mafia_players[$mafia_players.length - 1].role = N_Card.new
			i += 1
		end
		
		event.respond("Created #{number} Dummy players")
	end
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
			# Only allow elect in the morning
			if $is_morning && !$can_vote
	
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
									target = Integer target rescue nil

									if !target.nil? && target >= 0 && target <= $mafia_players_ordered.length
											
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
				event.respond('Now is not the time to elect!')
			end
				
		else
			event.respond('No game active right now.')
		end
	
	end
	
end

# Command to idol for certain roles
bot.command :idol do |event|

	# Respond to command only in PM
	if event.channel.id == event.user.pm.id
	
		if $active_game
		
			# Only allow idol at night
			if !$is_morning
	
				i = 0
				while i < $mafia_players.length
				
					# Check if player is in game
					if event.user.id == $mafia_players[i].player.id
					
						# Check if player is alive
						if $mafia_players[i].alive
						
							# Check that player is a role that can't idol
							if $mafia_players[i].role.name == 'Kotori' || $mafia_players[i].role.name == 'Maki' ||  $mafia_players[i].role.name == 'Hanayo' || $mafia_players[i].role.name == 'Nozomi'
								event.respond('Your role cannot idol. You must do your role command')
							else
								event.respond($mafia_players[i].role.idol)
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
				event.respond('You can only do that at night!')
			end
			
		else
			event.respond('No game active right now.')
		end
	
	end
	
end

# Command for Honoka to Honk
bot.command :honk do |event, target|
	
	# Respond to command only in PM
	if event.channel.id == event.user.pm.id
	
		if $active_game
		
			# Only allow honk at night
			if !$is_morning
	
				i = 0
				while i < $mafia_players.length
				
					# Check if player is in game
					if event.user.id == $mafia_players[i].player.id
					
						# Check if player is alive
						if $mafia_players[i].alive
						
							# Check that player is Honoka
							if $mafia_players[i].role.name == 'Honoka'
								# Check that player number is valid
								begin
									target = Integer target rescue nil
									if !target.nil? && target > 0 && target <= $mafia_players_ordered.length
										event.respond($mafia_players[i].role.honk(target))
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
				event.respond('You can only do that at night!')
			end
			
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
		
			# Only allow assign at night
			if !$is_morning
	
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
									target = Integer target rescue nil
									if !target.nil? && target > 0 && target <= $mafia_players_ordered.length
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
				event.respond('You can only do that at night!')
			end
			
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
		
			# Only allow follow at night
			if !$is_morning
	
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
									target = Integer target rescue nil
									if !target.nil? && target > 0 && target <= $mafia_players_ordered.length
										event.respond($mafia_players[i].role.follow(target))
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
				event.respond('You can only do that at night!')
			end
			
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
		
			# Only allow help at night
			if !$is_morning
	
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
									target = Integer target rescue nil
									if !target.nil? && target > 0 && target <= $mafia_players_ordered.length
										event.respond($mafia_players[i].role.help(target))
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
				event.respond('You can only do that at night!')
			end
			
		else
			event.respond('No game active right now.')
		end
	
	end

end

# Command for Rin to Cat
bot.command :cat do |event, target|
	
	# Respond to command only in PM
	if event.channel.id == event.user.pm.id
	
		if $active_game
		
			# Only allow cat at night
			if !$is_morning
	
				i = 0
				while i < $mafia_players.length
				
					# Check if player is in game
					if event.user.id == $mafia_players[i].player.id
					
						# Check if player is alive
						if $mafia_players[i].alive
						
							# Check that player is Rin
							if $mafia_players[i].role.name == 'Rin'
										event.respond($mafia_players[i].role.cat())
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
				event.respond('You can only do that at night!')
			end
			
		else
			event.respond('No game active right now.')
		end
	
	end

end

bot.run