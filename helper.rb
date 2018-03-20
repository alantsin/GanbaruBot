# Helper method to make the table look nice
def spacing(s)
	case s.length
	
	when 1
		return s + '    '
	when 2
		return s + '   '
	when 3
		return s + '  '
	when 4
		return s + ' '
	else
		return s + ''
	end
end

# Helper method to display the data nicely

def markdown_card()

	url = 'https://schoolido.lu/api/cards/' + $card_id + '/'
	
	obj = JSON.parse(open(url).read)

	# Start by getting skill type
	
	if $card_skill_array.nil?
		
		$center_skill = nil
		
	else
	
		$center_skill = $parsed_content.css('div.description')[1].inner_text
	
		skill_obj = obj['skill'].to_s
		skill_details_obj = obj['skill_details'].to_s # Split with ','
		skill_details = skill_details_obj.split(',')
		
		case skill_obj # Refactor for new skill types later
		
		when 'Healer'
			benefit = 'HP Recovery'

		when 'Perfect Lock'
			benefit = 'Seconds of Perfect Lock'
			
		else #Check for specific skills
		
			if skill_obj.include? 'Yell'
				benefit = 'HP Recovery'
				
			elsif skill_obj.include? 'Trick'
				benefit = 'Seconds of Semi-Perfect Lock'
			
			else
				benefit = 'Score Increase'
			end
				
		end
	
	end
	
	#Save Card Thumbnail, Idolized
	
	image = obj['round_card_idolized_image'].to_s
	download = open("https:#{image}")
	IO.copy_stream(download, $card_id + '.png')
		
	resized_image = MiniMagick::Image.open($card_id + '.png')
	resized_image.resize '100x100'
	resized_image.format 'png'
	resized_image.write 'resized' + $card_id + '.png'
	
	# Prepare data
	
	skill_level = Array.new(8)
	i = 0
	
	if !$card_skill_array.nil?
	
		if skill_obj == 'Perfect Lock'
		
			while i < 8
				skill_level[i] = $card_skill_array[i].split(',')
				skill_level[i][0] = skill_level[i][0].gsub(/[^\d,\.]/, '')
				skill_level[i][1] = spacing(skill_level[i][2].to_s.gsub(/[^\d,\.]/, ''))
				i += 1
				
			end
		
		else
	
			while i < 8
				skill_level[i] = $card_skill_array[i].split(',')
				skill_level[i][0] = skill_level[i][0].gsub(/[^\d,\.]/, '')
				skill_level[i][1] = spacing(skill_level[i][1].to_i.to_s.gsub(/[^\d,\.]/, ''))
				i += 1
			end
			
		end
		
		avg_array = Array.new(8)
		
		abs_array = Array.new(8)
		
		sd_n1_array = Array.new(8)
		
		sd_1_array = Array.new(8)

		sd_n2_array = Array.new(8)
		
		sd_2_array = Array.new(8)
		
		i = 0
	
		case benefit

		when 'Score Increase'
		
			while i < 8
				avg_array[i] = spacing((2.5 * skill_level[i][0].to_i * 0.01 * skill_level[i][1].to_i / skill_details[0].gsub(/[^\d,\.]/, '').to_f).round(1).to_s)
				abs_array[i] = spacing((2.5 * skill_level[i][1].to_i / skill_details[0].gsub(/[^\d,\.]/, '').to_f).round(1).to_s)
				
				np = skill_details[0].gsub(/[^\d,\.]/, '').to_i * skill_level[i][0].to_i * 0.01
				sd = Math.sqrt(np * (1 - (skill_level[i][0].to_i * 0.01))).round(1)
				
				sd_n1_array[i] = spacing(((((np - sd) /  skill_details[0].gsub(/[^\d,\.]/, '').to_i).round(3) * 2.5 * skill_level[i][1].to_i) / skill_details[0].gsub(/[^\d,\.]/, '').to_i).round(1).to_s)
				sd_1_array[i] = spacing(((((np + sd) /  skill_details[0].gsub(/[^\d,\.]/, '').to_i).round(3) * 2.5 * skill_level[i][1].to_i) / skill_details[0].gsub(/[^\d,\.]/, '').to_i).round(1).to_s)
				sd_n2_array[i] = spacing(((((np - (2 * sd)) /  skill_details[0].gsub(/[^\d,\.]/, '').to_i).round(3) * 2.5 * skill_level[i][1].to_i) / skill_details[0].gsub(/[^\d,\.]/, '').to_i).round(1).to_s)
				sd_2_array[i] = spacing(((((np + (2 * sd)) /  skill_details[0].gsub(/[^\d,\.]/, '').to_i).round(3) * 2.5 * skill_level[i][1].to_i) / skill_details[0].gsub(/[^\d,\.]/, '').to_i).round(1).to_s)
				
				i += 1
			end
			
		when 'HP Recovery'
			
			while i < 8
				avg_array[i] = spacing((480 * skill_level[i][0].to_i * 0.01 * skill_level[i][1].to_i / skill_details[0].gsub(/[^\d,\.]/, '').to_f).round(1).to_s)
				abs_array[i] = spacing((480 * skill_level[i][1].to_i / skill_details[0].gsub(/[^\d,\.]/, '').to_f).round(1).to_s)
				
				np = skill_details[0].gsub(/[^\d,\.]/, '').to_i * skill_level[i][0].to_i * 0.01
				sd = Math.sqrt(np * (1 - (skill_level[i][0].to_i * 0.01))).round(1)
				
				sd_n1_array[i] = spacing(((((np - sd) /  skill_details[0].gsub(/[^\d,\.]/, '').to_i).round(3) * 480 * skill_level[i][1].to_i) / skill_details[0].gsub(/[^\d,\.]/, '').to_i).round(1).to_s)
				sd_1_array[i] = spacing(((((np + sd) /  skill_details[0].gsub(/[^\d,\.]/, '').to_i).round(3) * 480 * skill_level[i][1].to_i) / skill_details[0].gsub(/[^\d,\.]/, '').to_i).round(1).to_s)
				sd_n2_array[i] = spacing(((((np - (2 * sd)) /  skill_details[0].gsub(/[^\d,\.]/, '').to_i).round(3) * 480 * skill_level[i][1].to_i) / skill_details[0].gsub(/[^\d,\.]/, '').to_i).round(1).to_s)
				sd_2_array[i] = spacing(((((np + (2 * sd)) /  skill_details[0].gsub(/[^\d,\.]/, '').to_i).round(3) * 480 * skill_level[i][1].to_i) / skill_details[0].gsub(/[^\d,\.]/, '').to_i).round(1).to_s)
				
				
				i += 1
			end

		else 
			
		end
		
	end
	
	# Make strings for output
	
	$markdown_array = Array.new(5)
	
	max_stats = $card_level_array[$card_level_array.length - 2].split(',')
	
	$markdown_array[1] = "```scala\nStats at max level #{$card_max_level}:\nSmile: #{max_stats[0].gsub(/\D/, '')}\nPure:  #{max_stats[1].gsub(/\D/, '')}\nCool:  #{max_stats[2].gsub(/\D/, '')}\n```\n"
	
	if $center_skill.nil?
		
		$markdown_array[0] = "**Data for Card:** \[#{$card_id}\] #{obj['idol']['name'].to_s} #{obj['translated_collection'].to_s} \n**Center Skill:** N/A\n"
		
		$markdown_array[2] = "**Skill Data:** N/A\n"
		
		$markdown_array[3] = ''
		
		$markdown_array[4] = ''
		
	else
	
		$markdown_array[0] = "**Data for Card:** \[#{$card_id}\] #{obj['idol']['name'].to_s} #{obj['translated_collection'].to_s} \n**Center Skill:** #{$center_skill}\n"
		
		$markdown_array[2] = "**Skill Data:** #{skill_details[0]}, there is a *p* chance of *n* #{benefit}\n"
		
		i = 0
		
		if skill_obj == 'Perfect Lock'
		
			$markdown_array[3] = "```scala\n|S.Lv |  p  |  n  |\n===================\n"
			
			$markdown_array[4] = ''
	
			while i < 8
			
				$markdown_array[4] = $markdown_array[4] + "|  #{i + 1}  | #{skill_level[i][0]}% |#{skill_level[i][1]}|\n"
				i += 1
				
			end
		
		else
		
			$markdown_array[3] = "```scala\n|S.Lv |  p  |  n  | Avg | Abs |Stat>| -1σ | +1σ | -2σ | +2σ |\n===========================================================\n"
			
			$markdown_array[4] = ''
	
			while i < 8
		
				$markdown_array[4] = $markdown_array[4] + "|  #{i + 1}  | #{skill_level[i][0]}% |#{skill_level[i][1]}|#{avg_array[i]}|#{abs_array[i]}|     |#{sd_n1_array[i]}|#{sd_1_array[i]}|#{sd_n2_array[i]}|#{sd_2_array[i]}|\n"
				i += 1
			
			end
		
		end
	
		$markdown_array[4] = $markdown_array[4] + "```"
	
	end

	return
	
end

# Helper method to open the url to the data
def openurl(card)

	document = open('https://sif.kirara.ca/card/' + card)
	content = document.read
	$parsed_content = Nokogiri::HTML(content)
	data = $parsed_content.css('script').children.first.inner_text.split(':') # Now a string
	extract_data(data)
	
end

# Helper method to extract data from the url into global variables
def extract_data(data)

	$card_id = data[0].gsub(/\D/, '') # Use $card_id to upload image
	
	$card_max_level = data[2].gsub(/\D/, '')
	
	$card_max_bond = data[3].gsub(/\D/, '')
	
	$card_level_array = data[5].split('],')

	if data[4].include? 'null'
		$card_skill_array = nil
		
	else
	
		$card_skill_array = data[6].split('],') # Split percentage and value with .gsub(/[^\d,\.]/, '')
		
	end
	
	markdown_card()
		
end

# Helper method to determine card id
def scout(type)

	puts type
	
	case type
	
	when 'ur'
		card_pool = $ur_array
		
	when 'ssr'
		card_pool = $ssr_array
		
	when 'sr'
		card_pool = $sr_array
		
	when 'r'
		card_pool = $r_array
		
	when 'n'
		card_pool = $n_array
		
	when 'blue'
	
		rarity = rand(1..5)
		puts rarity
		
		case rarity
		
		when 1
			card_pool = $ur_array
		else
			card_pool = $sr_array
		end
		
	else
	
		rarity = rand(1..100)
		puts rarity
		
		case rarity # Choose box based on rarity
		
		when 1
			card_pool = $ur_array
		
		when 2..5
			card_pool = $ssr_array
			
		when 6..20
			card_pool = $sr_array
			
		else
			card_pool = $r_array
			
		end
		
	end
	
	bad_card = true
	
	while bad_card
	
		card = rand(2..card_pool.length - 1) # Pick index
		id = card_pool[card].split('</td>') # Gets the actual card id
		puts id[0]
		
		next if card_pool[card].include? '(pre-transformed)' # Don't choose promo cards
		
		next if special_card(id[0].to_i)	#Don't choose special cards
			
		bad_card = false
		
		return id[0]
	
	end

end

# Helper function to identify special cards

def special_card(id)

	case id
	
	when 83, 146..148, 206, 379..390, 629, 837..839, 1022, 1047, 1048, 1054, 1070, 1083, 1136, 1166, 90, 107, 162, 182, 1317..1320, 1330, 1340..1345, 1347, 1349..1351, 1360, 1371, 1373..1375, 1386, 1396, 1397, 1399, 1401..1403, 1413, 1415..1417, 1427, 1447, 1449..1451, 1461, 1477..1479, 1484, 1500, 1502, 1504
		return true
	else
		return false
	end
	
end

# Initializes the card rarity arrays as global variables
def get_cards()

	document = open('https://sif.kirara.ca/checklist_grouped')
	content = document.read.to_s
	rarity_array = content.split('<h2>')
	
	$n_array = rarity_array[1].split('<td class="ar">#')
	#puts n_array[2] # First card for N is at index 2
	
	$r_array = rarity_array[2].split('<td class="ar">#')
	
	$sr_array = rarity_array[3].split('<td class="ar">#')
	
	$ssr_array = rarity_array[4].split('<td class="ar">#')
	
	$ur_array = rarity_array[5].split('<td class="ar">#')

	#puts ur_array[ur_array.length - 1]
	
end

# Helper method to determine the image type
def image_type(path)

	if Dir[File.join(path, '**', '*.gif')].count { |file| File.file?(file) } > 0
		return '*.gif'
		
	elsif Dir[File.join(path, '**', '*.png')].count { |file| File.file?(file) } > 0
		return '*.png'
		
	else
		return '*.jpg'
		
	end
	
end
 
# Helper method to determine if link is a supported image type
def is_image(link)

	if (link.downcase.end_with?('.jpg') || 
		link.downcase.end_with?('.jpeg') ||
		link.downcase.end_with?('.png') ||
		link.downcase.end_with?('.gif'))
	return true
	
	else
		return false
		
	end
	
end

# Helper method to count the number of files in the directory
def file_count(path)
	return Dir.glob(File.join(path, '**', '*')).select { |file| File.file?(file) }.count
end