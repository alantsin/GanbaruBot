# Helper method to determine card id
def scout()
	
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
	
	when 83, 146..148, 379..390, 629, 837..839, 1022, 1047, 1048, 1054, 1070, 1083, 1136, 1166
		puts true
		return true
	else
		puts false
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