require 'discordrb'
require 'json'
require 'mini_magick'
require 'nokogiri'

require_relative 'helper'
require_relative 'TOKENS'

# Exclude this user id: 188081906586222603

bot = Discordrb::Commands::CommandBot.new token: TOKEN_VALUE, client_id: CLIENT_ID_VALUE, prefix: '!'

name_array = Array.new # Used to keep track of names to prevent command spam

last_used = '0' # Prevent solo scouts in succession

not_using = true # Prevents concurrent use of !card

get_cards()

$card_count = JSON.parse(open("http://schoolido.lu/api/cards/").read)['count'] # Gets total card count

# Command to update all members to the dah role

bot.command :update do |event|
	i = 0
	while i < event.server.members.length
		event.server.members[i].add_role(DEFAULT_ROLE)
		puts("Added " + event.server.members[i].name + " to dah role")
		i += 1
	end
end

bot.member_join do |event|
	puts event.user.username + " has joined"
	if (event.user.id != 188081906586222603)
		event.user.add_role(DEFAULT_ROLE)
		bot.send_message(TEST_CHANNEL, event.user.username + " has joined and became a dahDUM")
	end
end

bot.member_leave do |event|
	puts event.user.username + " has left"
	bot.send_message(TEST_CHANNEL, event.user.username + " has left and became a :dahUMD:")
end

bot.command :dah, description: "Command to request the dah role if not automatically assigned to you when you joined" do |event|
	if event.channel.name == 'bot-commands'

		if (event.user.id == 188081906586222603)
			event.channel.send_file File.new("emojis\\" + "Pierrot.png")

		elsif event.user.roles[0].nil?
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
		
			id = id.to_i
		
			if id.is_a? Integer
			
				if (id >= 1 && id <= $card_count)
			
					if !special_card(id)
					
							begin
				
								not_using = false
								
								id = id.to_s

								openurl(id)
								
								# Upload image and delete
								event.channel.send_file File.new('resized' + $card_id + '.png')
								File.delete($card_id + '.png') # Delete original
								File.delete('resized' + $card_id + '.png') # Delete resized
								
								sleep(0.5)
								
								if !$center_skill.nil?
									event.respond($markdown_array[0] + $markdown_array[1] + $markdown_array[2] + $markdown_array[3] + $markdown_array[4])
									event.send_temp('Taking a nap...', 3)
								
								else
									event.respond($markdown_array[0] + $markdown_array[1] + $markdown_array[2])
									event.send_temp('Taking a nap...', 3)
									
								end
								
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
		
	resized_image = MiniMagick::Image.open(number + '.png')
	resized_image.resize '100x100'
	resized_image.format 'png'
	resized_image.write 'resized' + number + '.png'
		
	event.channel.send_file File.new('resized' + number + '.png')
		
	File.delete(number + '.png') # Delete original
	File.delete('resized' + number + '.png') # Delete resized
		 
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

	if event.channel.name == 'bot-commands'
	
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
								#puts 'image' + extension
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

	if event.channel.name == 'bot-commands'
	
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

	begin
		info = hugemoji.split(':')
		prefix = 'https://cdn.discordapp.com/emojis/'
		suffix = info[2].gsub(/[>]/, '.png')

		image = prefix + suffix
		download = open(image)
		IO.copy_stream(download, "emojis\\#{download.base_uri.to_s.split('/')[-1]}")
		event.channel.send_file File.new("emojis\\" + suffix)
		File.delete("emojis\\" + suffix)
		puts '' # To prevent returning text in the Discord chat
		
	rescue
		event.respond 'Custom emojis only...'
		
	end
	
end

# 3 second countdown to help coordinate simultaneous events
bot.command :countdown, description: '[Co-op-Room] A 3-second countdown to help coordinate matches' do |event|

	if event.channel.name == 'co-op-room'
  
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

bot.run