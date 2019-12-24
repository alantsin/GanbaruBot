require 'discordrb'
require 'json'
require 'nokogiri'
require 'open-uri'

require_relative 'helper'
require_relative 'TOKENS'

bot = Discordrb::Commands::CommandBot.new token: TOKEN_VALUE, client_id: CLIENT_ID_VALUE, prefix: '!'

name_array = Array.new # Used to keep track of names to prevent command spam

last_used = '0' # Prevent solo scouts in succession

not_using = true # Prevents concurrent use of !card

get_cards()

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

	begin
		event.user.pm("Welcome to Umidah's server!\n\nFriendly reminder to read the #welcome channel since there's a 99% chance you're only here for global emotes.\n\nThere will be frequent pings from the #live-on-twitch channel, so read #actually-important-stuff for ways to get rid of it.\n\nAnyone that complains about the pings will be branded with the **Baka** role and have their global emote permissions removed.")
		event.user.add_role(DEFAULT_ROLE)
		bot.send_message(TEST_CHANNEL, event.user.username + " was made a dah")
	rescue
		event.user.add_role(BLOCKED_ROLE)
		bot.send_message(TEST_CHANNEL, "It just got a lot more toxic in here...")
	end
	
end

bot.member_leave do |event|
	bot.send_message(TEST_CHANNEL, event.user.username + " has left.")
end

bot.command :dah, description: "Command to request the dah role if not automatically assigned to you when you joined" do |event|
	if event.channel.name == 'bot-commands'

		if event.user.roles[0].nil?
		
			begin
				event.user.pm('You are now a dah!')
				event.user.add_role(DEFAULT_ROLE)
			rescue
				event.respond('Enable DMs to be granted the role.')
			end	
			
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
			
				event.user.pm("Y-you're already a dah...")
				
			else
			
				begin
					event.user.pm('You are now a dah!')
					event.user.add_role(DEFAULT_ROLE)
				rescue
					event.respond('Enable DMs to be granted the role.')
				end	
				
			end
			
		end
		
	end
	
end

bot.command :role, description: "[Bot-Commands] Used to assign different roles for channel access. Accepts the words 'Chat', 'Gacha', 'Bored', and 'Weeb' for the input. If you want full access, use 'All' as input." do |event, id|
 
 
	if event.channel.name == 'bot-commands' || event.channel.name == 'umitest'
	
		if id.downcase == 'chat'
		
			begin
				event.user.pm('You now have access to the Chat channels.')
				event.user.add_role(CHAT_ROLE)
			rescue
				event.respond('Enable DMs to be granted the role.')
			end
			 
		elsif id.downcase == 'gacha'

			begin
				event.user.pm('You now have access to the Gacha channels.')
				event.user.add_role(GACHA_ROLE)
			rescue
				event.respond('Enable DMs to be granted the role.')
			end
			 
		elsif id.downcase == 'bored'

			begin
				event.user.pm('You now have access to the Bored channels.')
				event.user.add_role(BORED_ROLE)
			rescue
				event.respond('Enable DMs to be granted the role.')
			end
			 
		elsif id.downcase == 'weeb'

			begin
				event.user.pm('You now have access to the Weeb channels.')
				event.user.add_role(WEEB_ROLE)
			rescue
				event.respond('Enable DMs to be granted the role.')
			end

		elsif id.downcase == 'all'

			begin
				event.user.pm('You now have access to the all the free-to-play channels.')
				event.user.add_role(CHAT_ROLE)
				event.user.add_role(GACHA_ROLE)
				event.user.add_role(BORED_ROLE)
				event.user.add_role(WEEB_ROLE)
			rescue
				event.respond('Enable DMs to be granted the role.')
			end
			 
		else

			event.respond('Not a valid role...')
			 
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
								
						$card_id = id.to_s

						output = openurl($card_id)
								
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
bot.command :countdown, description: 'A 3-second countdown to help coordinate matches' do |event|
  
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

bot.command :hp, description: '[Team-Building-Help] Displays the HP Overflow % Boost Table for School Idol Festival' do |event|

	if event.channel.name == 'team-building-help' || event.channel.name == 'umitest'
	
		event.respond('Your tap score in SIF gets a boost percentage based on your HP Overflow:')
		sleep(1)
		event.respond "```scala\n|Max HP| Boost|\n===============\n|   9  | 0.26 |\n|  10  | 0.29 |\n|  11  | 0.31 |\n|  12  | 0.34 |\n|  13  | 0.37 |\n|  14  | 0.40 |\n|  15  | 0.43 |\n|  16  | 0.46 |\n|  17  | 0.49 |\n|  18  | 0.51 |\n|  19  | 0.59 |\n|  20  | 0.63 |\n|  21  | 0.66 |\n|  22  | 0.70 |\n|  23  | 0.73 |\n|  24  | 0.77 |\n|  25  | 0.80 |\n|  26  | 0.84 |\n|  27  | 0.88 |\n|  28  | 0.91 |\n|  29  | 0.95 |\n|  30  | 0.99 |\n|  31  | 1.02 |\n|  32  | 1.06 |\n|  33  | 1.10 |\n|  34  | 1.14 |\n|  35  | 1.18 |\n|  36  | 1.21 |\n|  37  | 1.76 |\n|  38  | 1.83 |\n|  39  | 1.90 |\n|  40  | 1.97 |\n|  41  | 2.04 |\n|  42  | 2.11 |\n|  43  | 2.18 |\n|  44  | 2.25 |\n|  45  | 2.33 |\n|  46  | 2.64 |\n|  47  | 2.73 |\n|  48  | 2.82 |\n|  49  | 2.91 |\n|  50  | 3.00 |\n|  51  | 3.09 |\n|  52  | 3.19 |\n|  53  | 3.28 |\n|  54  | 3.38 |\n|  55  | 3.47 |\n|  56  | 3.57 |\n|  57  | 3.67 |\n|  58  | 3.77 |\n|  59  | 3.87 |\n|  60  | 3.98 |\n|  61  | 4.08 |\n|  62  | 4.19 |\n|  63+ | 4.29 |```"
  
	end
	
end

bot.run