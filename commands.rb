require 'discordrb'
require 'json'
require 'mini_magick'
require 'nokogiri'
require 'open-uri'
require 'uri'

require_relative 'helper'

bot = Discordrb::Commands::CommandBot.new token: '0' #TOKEN HERE, client_id: 0 #CLIENT_ID HERE, prefix: '!'

name_array = Array.new # Used to keep track of names to prevent command spam

last_used = '0' # Prevent solo scouts in succession

not_using = true # Prevents concurrent use of !card

$card_count = JSON.parse(open("http://schoolido.lu/api/cards/").read)['count'] # Gets total card count

bot.command :card, description: "[Team-Building-Help] Returns data on a card with `!card *id*. Does not work with special cards. Can only look up one card at a time." do |event, id|

	if event.channel.name == 'umitest'

		if not_using
		
			id = id.to_i
		
			if id.is_a? Integer
			
				if (id >= 1 && id <= $card_count)
			
					if !special_card(id)
					
							begin
				
								not_using = false

								openurl(id)
								
								# Upload image and delete
								event.channel.send_file File.new('resized' + $card_id + '.png')
								File.delete($card_id + '.png') # Delete original
								File.delete('resized' + $card_id + '.png') # Delete resized
								
								sleep(0.5)
								
								# Output card data
								event.respond($markdown_array[0])
								sleep(1)
								
								event.respond($markdown_array[1])
								sleep(0.5)
								
								event.send_temp('Getting data...', 1)
								sleep(1)
								
								event.respond($markdown_array[2])
								
								if !$center_skill.nil?
								
									event.send_temp('Getting data...', 1)
									sleep(1)
								
									event.respond($markdown_array[3] + $markdown_array[4])
									event.send_temp('Taking a nap...', 5)
									sleep(5)
									
								end
								
								looking_up = false
								not_using = true
								puts ''
								
							rescue
							
								looking_up = false
								not_using = true
								
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

	if event.channel.name == 'bot-commands'
	
		if event.user.roles[0].nil?

				if last_used == event.user.id # Non-subs cannot solo in succession
					event.user.pm('G-give someone else a chance first...')
					return
					
				end

			
		elsif event.user.roles[0].name != 'Untoasted Subs'
		
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
		if event.user.roles[0].name == 'Untoasted Subs'
		
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
		
	rescue
		puts 'Not a sub'
		event.respond 'S-subscriber only feature for now...'
		
	end
	
end

bot.command :save, description: '[Sub] [Bot-Commands] Saves an image for your personal use with \"!save URL\" that you can put in chat with \"!emote\". Supports .jpg, .png, and .gif' do |event, link|

	if event.channel.name == 'bot-commands'
	
		begin
		
			if event.user.roles[0].name == 'Untoasted Subs'

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
		
		rescue
			puts 'Not a sub'
			event.respond 'S-subscriber only feature for now...'
			
		end
	 
	end
	
end

bot.command :delete, description: '[Sub] [Bot-Commands] Deletes your currently saved image if you want to replace it' do |event|

	if event.channel.name == 'bot-commands'
	
		begin
		
			if event.user.roles[0].name == 'Untoasted Subs'
			
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

get_cards()

bot.run