# Helper method to make the table look nice
def spacing(s)
	case s.length
	
	when 1
		return '  ' + s + '  '
	when 2
		return ' ' + s + '  '
	when 3
		return '  ' + s
	when 4
		return ' ' + s
	else
		return s
		
	end
end

def amplify_spacing(s)
	case s.length
	
	when 5
		return ' ' + s
	else
		return s
		
	end
end


# Helper method to display the data nicely

def markdown_card()

	url = 'https://schoolido.lu/api/cards/' + $card_id + '/'
	
	obj = JSON.parse(open(url).read)
	
	image = obj['round_card_idolized_image'].to_s
	download = open("https:#{image}")
	IO.copy_stream(download, $card_id + '.png')
	
	rarity = obj['rarity'].to_s
	
	card_max_level = obj['idolized_max_level'].to_s

	case rarity
	
	when 'R'
		amplify_max = 9
	when 'SR'
		amplify_max = 11
	when 'SSR'
		amplify_max = 14
	else
		amplify_max = 16
		
	end
	
	extract_data()
	
	max_smile = obj['idolized_maximum_statistics_smile'].to_s
	max_pure = obj['idolized_maximum_statistics_pure'].to_s
	max_cool = obj['idolized_maximum_statistics_cool'].to_s
	
	$markdown_array = Array.new(7)
		
	$markdown_array[1] = "```scala\nStats at max level #{card_max_level}:\nSmile: #{max_smile}\nPure:  #{max_pure}\nCool:  #{max_cool}\n```\n"
	
	if ((SKILL_EXPERIENCE.include? $card_id) || (PRACTICE_EXPERIENCE.include? $card_id))
		
		return special_cards($card_id, obj)
	
	elsif rarity == 'N' # N card
		
		$markdown_array[0] = "**Data for Card:** \[#{$card_id}\] #{obj['idol']['name'].to_s} #{obj['translated_collection'].to_s} \n**Center Skill:** N/A\n"
		
		$markdown_array[2] = "**Skill Data:** N/A\n"
		$markdown_array[3] = ''
		$markdown_array[4] = ''
		
		return $markdown_array[0] + $markdown_array[1] + $markdown_array[2] + $markdown_array[3] + $markdown_array[4]
		
	else
	
		$markdown_array[0] = "**Data for Card:** \[#{$card_id}\] #{obj['idol']['name'].to_s} #{obj['translated_collection'].to_s} \n**Center Skill:** #{$center_skill}\n"
	
		skill_obj = obj['skill'].to_s
		skill_details_obj = obj['skill_details'].to_s # Split with ','
		skill_details = skill_details_obj.split(',')
		
	end
	
	# Prepare data
	
	skill_level = Array.new(16)
	
	avg_array = Array.new(16)
			
	abs_array = Array.new(16)
			
	sd_n1_array = Array.new(16)
			
	sd_1_array = Array.new(16)

	sd_n2_array = Array.new(16)
			
	sd_2_array = Array.new(16)
			
	i = 0
	
	case skill_obj
		
	when 'Appeal Boost'
	
		while i < amplify_max
			skill_level[i] = $card_skill_array[i].split(',')
			skill_level[i][0] = skill_level[i][0].gsub(/[^\d,\.]/, '')
			skill_level[i][1] = skill_level[i][1].to_s.gsub(/[^\d,\.]/, '')
			skill_level[i][2] = spacing(skill_level[i][2].to_s.gsub(/[^\d,\.]/, ''))
			i += 1
		end
			
		# Conditional to check which year and group
		if skill_details[1].include? 'first-year μ'
			
			appeal = "first-year μ's cards"
			
		elsif skill_details[1].include? 'second-year μ'
			
			appeal = "second-year μ's cards"
			
		elsif skill_details[1].include? 'third-year μ'
			
			appeal = "third-year μ's cards"
			
		elsif skill_details[1].include? 'first-year Aqours'
			
			appeal = "first-year Aqours cards"
			
		elsif skill_details[1].include? 'second-year Aqours'
			
			appeal = "second-year Aqours cards"
			
		else
			
			appeal = "third-year Aqours cards "
			
		end
			
		$markdown_array[2] = "**Appeal Boost:** #{skill_details[0]}, there is a *p* chance of increasing the stats of #{appeal} by *n* for *t* seconds.\n"
		
		$markdown_array[3] = "```scala\n|S.Lv |  p  |  n  |  t  |\n=========================\n"
				
		$markdown_array[4] = ''
		
		i = 0
		
		while i < 8
				
			$markdown_array[4] = $markdown_array[4] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1] + '%')}|#{spacing(skill_level[i][2])}|\n"
			i += 1
					
		end
		
		$markdown_array[4] = $markdown_array[4] + "```\n"
		
		$markdown_array[5] = "**Amplify Table:**\n"
		
		$markdown_array[6] = ''
		
		while i < amplify_max
				
			$markdown_array[6] = $markdown_array[6] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1] + '%')}|#{spacing(skill_level[i][2])}|\n"
			i += 1
					
		end
			
	when 'Perfect Score Up'
	
		while i < amplify_max
				skill_level[i] = $card_skill_array[i].split(',')
				skill_level[i][0] = skill_level[i][0].gsub(/[^\d,\.]/, '')
				skill_level[i][1] = spacing(skill_level[i][1].to_s.gsub(/[^\d,\.]/, ''))
				skill_level[i][2] = spacing(skill_level[i][2].to_s.gsub(/[^\d,\.]/, ''))
				i += 1
		end
			
		i = 0
		
		while i < amplify_max
			avg_array[i] = spacing((skill_level[i][0].to_i * 0.01 * skill_level[i][1].to_i).round(1).to_s)
			abs_array[i] = spacing((skill_level[i][1].to_i).round(1).to_s)
					
			np = skill_details[0].gsub(/[^\d,\.]/, '').to_i * skill_level[i][0].to_i * 0.01
			sd = Math.sqrt(np * (1 - (skill_level[i][0].to_i * 0.01))).round(1)
						
			sd_n1_array[i] = spacing(((((np - sd) /  skill_details[0].gsub(/[^\d,\.]/, '').to_i).round(3) * skill_level[i][1].to_i)).round(1).to_s)
			sd_1_array[i] = spacing(((((np + sd) /  skill_details[0].gsub(/[^\d,\.]/, '').to_i).round(3) * skill_level[i][1].to_i)).round(1).to_s)
			sd_n2_array[i] = spacing(((((np - (2 * sd)) /  skill_details[0].gsub(/[^\d,\.]/, '').to_i).round(3) * skill_level[i][1].to_i)).round(1).to_s)
			sd_2_array[i] = spacing(((((np + (2 * sd)) /  skill_details[0].gsub(/[^\d,\.]/, '').to_i).round(3) * skill_level[i][1].to_i)).round(1).to_s)
						
						
			i += 1
		end
			
		$markdown_array[2] = "**Perfect Score Up:** #{skill_details[0]}, there is a *p* chance of increasing the score of PERFECT notes by *n* for *t* seconds.\n"
		
		$markdown_array[3] = "```scala\n|S.Lv |  p  |  n  | Avg | Abs |  t  | -1σ | +1σ | -2σ | +2σ |\n=============================================================\n"
					
		$markdown_array[4] = ''
				
		i = 0
			
		while i < 8
			$markdown_array[4] = $markdown_array[4] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1])}|#{avg_array[i]}|#{abs_array[i]}|#{skill_level[i][2]}|#{sd_n1_array[i]}|#{sd_1_array[i]}|#{sd_n2_array[i]}|#{sd_2_array[i]}|\n"
			i += 1
		end
		
		$markdown_array[4] = $markdown_array[4] + "```\n"
		
		$markdown_array[5] = "**Amplify Table:**\n"
		
		$markdown_array[6] = ''
		
		while i < amplify_max
				
			$markdown_array[6] = $markdown_array[6] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1])}|#{avg_array[i]}|#{abs_array[i]}|#{skill_level[i][2]}|#{sd_n1_array[i]}|#{sd_1_array[i]}|#{sd_n2_array[i]}|#{sd_2_array[i]}|\n"
			i += 1
					
		end
			
	when 'Mirror'
	
		while i < amplify_max
			skill_level[i] = $card_skill_array[i].split(',')
			skill_level[i][0] = skill_level[i][0].gsub(/[^\d,\.]/, '')
			skill_level[i][1] = spacing(skill_level[i][2].to_s.gsub(/[^\d,\.]/, ''))
			i += 1				
		end
			
		# Conditional to check which year and group
		if skill_details[1].include? 'first-year μ'
			
			appeal = "first-year μ's card"
			
		elsif skill_details[1].include? 'second-year μ'
			
			appeal = "second-year μ's card"
			
		elsif skill_details[1].include? 'third-year μ'
			
			appeal = "third-year μ's card"
			
		elsif skill_details[1].include? 'first-year Aqours'
			
			appeal = "first-year Aqours card"
			
		elsif skill_details[1].include? 'second-year Aqours'
			
			appeal = "second-year Aqours card"
			
		else
			
			appeal = "third-year Aqours card"
				
		end
			
		$markdown_array[2] = "**Mirror:** #{skill_details[0]}, there is a *p* chance of copying the stats of another #{appeal} for *t* seconds.\n"
		
		$markdown_array[3] = "```scala\n|S.Lv |  p  |  t  |\n===================\n"
				
		$markdown_array[4] = ''
			
		i = 0
		
		while i < 8
				
			$markdown_array[4] = $markdown_array[4] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1])}|\n"
			i += 1
					
		end
		
		$markdown_array[4] = $markdown_array[4] + "```\n"
		
		$markdown_array[5] = "**Amplify Table:**\n"
		
		$markdown_array[6] = ''
		
		while i < amplify_max
				
			$markdown_array[6] = $markdown_array[6] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1])}|\n"
			i += 1
					
		end
			
	when 'Skill Boost'
	
		while i < amplify_max
			skill_level[i] = $card_skill_array[i].split(',')
			skill_level[i][0] = skill_level[i][0].gsub(/[^\d,\.]/, '')
			skill_level[i][1] = skill_level[i][1].to_s.gsub(/[^\d,\.]/, '')
			skill_level[i][2] = spacing(skill_level[i][2].to_s.gsub(/[^\d,\.]/, ''))
			i += 1
		end
			
		$markdown_array[2] = "**Skill Boost:** #{skill_details[0]}, there is a *p* chance of increasing the chance of other skills activating by *n* for *t* seconds.\n"
		
		$markdown_array[3] = "```scala\n|S.Lv |  p  |  n  |  t  |\n=========================\n"
				
		$markdown_array[4] = ''
			
		i = 0
		
		while i < 8
				
			$markdown_array[4] = $markdown_array[4] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1] + '%')}|#{spacing(skill_level[i][2])}|\n"
			i += 1
					
		end
		
		$markdown_array[4] = $markdown_array[4] + "```\n"
		
		$markdown_array[5] = "**Amplify Table:**\n"
		
		$markdown_array[6] = ''
		
		while i < amplify_max
				
			$markdown_array[6] = $markdown_array[6] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1] + '%')}|#{spacing(skill_level[i][2])}|\n"
			i += 1
					
		end
			
	when 'Encore'
			
		while i < 8
			skill_level[i] = $card_skill_array[i].split(',')
			skill_level[i][0] = skill_level[i][0].gsub(/[^\d,\.]/, '')
			i += 1				
		end
			
		$markdown_array[2] = "**Encore:** #{skill_details[0]}, there is a *p* chance repeating the last activated skill.\n"
		
		$markdown_array[3] = "```scala\n|S.Lv |  p  |\n=============\n"
				
		$markdown_array[4] = ''
			
		i = 0
		
		while i < 8
				
			$markdown_array[4] = $markdown_array[4] + "|  #{i + 1}  | #{skill_level[i][0]}% |\n"
			i += 1
					
		end
		
		$markdown_array[4] = $markdown_array[4] + "```\n"
		
		$markdown_array[5] = "**Amplify Table:** N/A"
		
		return $markdown_array[0] + $markdown_array[1] + $markdown_array[2] + $markdown_array[3] + $markdown_array[4] + $markdown_array[5]
			
	when 'Amplify'
	
		while i < amplify_max
			skill_level[i] = $card_skill_array[i].split(',')
			skill_level[i][0] = skill_level[i][0].gsub(/[^\d,\.]/, '')
			skill_level[i][1] = spacing(skill_level[i][1].to_i.to_s.gsub(/[^\d,\.]/, ''))
			i += 1
		end
			
		$markdown_array[2] = "**Amplify:** #{skill_details[0]}, there is a *p* chance of increasing the skill level of the next activating skill by *n*.\n"
		
		$markdown_array[3] = "```scala\n|S.Lv |  p  |  n  |\n===================\n"
		
		$markdown_array[4] = ''
			
		i = 0
	
		while i < 8
				
			$markdown_array[4] = $markdown_array[4] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1])}|\n"
			i += 1
					
		end
		
		$markdown_array[4] = $markdown_array[4] + "```\n"
		
		$markdown_array[5] = "**Amplify Table:**\n"
		
		$markdown_array[6] = ''
		
		while i < amplify_max
				
			$markdown_array[6] = $markdown_array[6] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1])}|\n"
			i += 1
					
		end
			
	when 'Combo Bonus Up'
	
		combo_max = Array.new(amplify_max)
			inc = Array.new(amplify_max)
			
		while i < amplify_max
			skill_level[i] = $card_skill_array[i].split(',')
			skill_level[i][0] = skill_level[i][0].gsub(/[^\d,\.]/, '')
			combo_max[i] = skill_level[i][1].to_i * 10
			inc[i] = spacing(((combo_max[i] - skill_level[i][1].to_f) / 30).to_s)
			combo_max[i] = spacing(combo_max[i].to_s)
			skill_level[i][1] = skill_level[i][1].to_s.gsub(/[^\d,\.]/, '')
			skill_level[i][2] = spacing(skill_level[i][2].to_s.gsub(/[^\d,\.]/, ''))
			skill_level[i][3] = skill_level[i][3].to_s.gsub(/[^\d,\.]/, '')
			i += 1
		end
			
		c = skill_details[0].gsub(/[^\d]/, '')
			
		$markdown_array[2] = "**Combo Bonus Up:** Every *c* combo, there is a *p* chance of providing *min* to *max* score increase for each note based on Combo Count for *t* seconds.\n**inc** = [(*max* - *min*) / 30] and represents the value that *min* increments by every 10 Combo Count until reaching 301 Combo, at which point *min* = *max* and stays that way until the combo is broken or finished.\n"
		
		$markdown_array[3] = "```scala\n|S.Lv |  c  |  p  | min | max | inc |  t  |\n===========================================\n"
			
		$markdown_array[4] = ''
			
		i = 0
		
		while i < 8
			$markdown_array[4] = $markdown_array[4] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][3])}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1])}|#{combo_max[i]}|#{inc[i]}|#{spacing(skill_level[i][2])}|\n"
			i += 1
		end
		
		$markdown_array[4] = $markdown_array[4] + "```\n"
		
		$markdown_array[5] = "**Amplify Table:**\n"
		
		$markdown_array[6] = ''
		
		while i < amplify_max
			$markdown_array[6] = $markdown_array[6] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][3])}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1])}|#{combo_max[i]}|#{inc[i]}|#{spacing(skill_level[i][2])}|\n"
			i += 1
		end
		
	when 'Total Trick', 'Timer Trick'
		
		while i < 9
			skill_level[i] = $card_skill_array[i].split(',')
			skill_level[i][0] = skill_level[i][0].gsub(/[^\d,\.]/, '')
			skill_level[i][1] = spacing(skill_level[i][2].to_s.gsub(/[^\d,\.]/, ''))
			i += 1				
		end
			
		$markdown_array[2] = "**Semi-Perfect Lock:** #{skill_details[0]}, there is a *p* chance of *t* seconds of turning GREAT notes into PERFECT. Natural PERFECT notes during this duration are worth 8% more score.\n"
			
		$markdown_array[3] = "```scala\n|S.Lv |  p  |  t  |\n===================\n"
				
		$markdown_array[4] = ''
			
		i = 0
		
		while i < 8
				
			$markdown_array[4] = $markdown_array[4] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1])}|\n"
			i += 1
					
		end
		
		$markdown_array[4] = $markdown_array[4] + "```\n"
		
		$markdown_array[5] = "**Amplify Table:**\n"
		
		$markdown_array[6] = ''
		
		while i < 9
				
			$markdown_array[6] = $markdown_array[6] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1])}|\n"
			i += 1
					
		end
		
	when 'Perfect Lock'
	
		while i < amplify_max
			skill_level[i] = $card_skill_array[i].split(',')
			skill_level[i][0] = skill_level[i][0].gsub(/[^\d,\.]/, '')
			skill_level[i][1] = spacing(skill_level[i][2].to_s.gsub(/[^\d,\.]/, ''))
			i += 1				
		end
			
		$markdown_array[2] = "**Perfect Lock:** #{skill_details[0]}, there is a *p* chance of *t* seconds of turning GOOD and GREAT notes into PERFECT. Natural PERFECT notes during this duration are worth 8% more score.\n"
			
		$markdown_array[3] = "```scala\n|S.Lv |  p  |  t  |\n===================\n"
				
		$markdown_array[4] = ''
			
		i = 0
		
		while i < 8
				
			$markdown_array[4] = $markdown_array[4] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1])}|\n"
			i += 1
					
		end
		
		$markdown_array[4] = $markdown_array[4] + "```\n"
		
		$markdown_array[5] = "**Amplify Table:**\n"
		
		$markdown_array[6] = ''
		
		while i < amplify_max
				
			$markdown_array[6] = $markdown_array[6] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1])}|\n"
			i += 1
					
		end
			
	when 'Timer Yell', 'Total Yell', 'Rhythmical Yell', 'Perfect Yell'
		
		while i < 9
			skill_level[i] = $card_skill_array[i].split(',')
			skill_level[i][0] = skill_level[i][0].gsub(/[^\d,\.]/, '')
			skill_level[i][1] = spacing(skill_level[i][1].to_s.gsub(/[^\d,\.]/, ''))
			i += 1				
		end
		
		i = 0
			
		while i < 9
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
			
		$markdown_array[2] = "**Healer:** #{skill_details[0]}, there is a *p* chance of *n* HP recovery.\n"
			
		$markdown_array[3] = "```scala\n|S.Lv |  p  |  n  |Score| Avg | Abs | -1σ | +1σ | -2σ | +2σ |\n=============================================================\n"
				
		$markdown_array[4] = ''
			
		i = 0
		
		while i < 8
			$markdown_array[4] = $markdown_array[4] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1])}|#{spacing(((skill_level[i][1]).to_i * 480).to_s)}|#{avg_array[i]}|#{abs_array[i]}|#{sd_n1_array[i]}|#{sd_1_array[i]}|#{sd_n2_array[i]}|#{sd_2_array[i]}|\n"
			i += 1
		end
		
		$markdown_array[4] = $markdown_array[4] + "```\n"
		
		$markdown_array[5] = "**Amplify Table:**\n"
		
		$markdown_array[6] = ''
		
		while i < 9
			$markdown_array[6] = $markdown_array[6] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1])}|#{spacing(((skill_level[i][1]).to_i * 480).to_s)}|#{avg_array[i]}|#{abs_array[i]}|#{sd_n1_array[i]}|#{sd_1_array[i]}|#{sd_n2_array[i]}|#{sd_2_array[i]}|\n"
			i += 1
		end
			
	when 'Healer'
	
		while i < amplify_max
			skill_level[i] = $card_skill_array[i].split(',')
			skill_level[i][0] = skill_level[i][0].gsub(/[^\d,\.]/, '')
			skill_level[i][1] = spacing(skill_level[i][1].to_s.gsub(/[^\d,\.]/, ''))
			i += 1
		end
			
		i = 0
			
		while i < amplify_max
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
			
		$markdown_array[2] = "**Healer:** #{skill_details[0]}, there is a *p* chance of *n* HP recovery.\n"
			
		$markdown_array[3] = "```scala\n|S.Lv |  p  |  n  |Score| Avg | Abs | -1σ | +1σ | -2σ | +2σ |\n=============================================================\n"
				
		$markdown_array[4] = ''
			
		i = 0
		
		while i < 8
			$markdown_array[4] = $markdown_array[4] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1])}|#{spacing(((skill_level[i][1]).to_i * 480).to_s)}|#{avg_array[i]}|#{abs_array[i]}|#{sd_n1_array[i]}|#{sd_1_array[i]}|#{sd_n2_array[i]}|#{sd_2_array[i]}|\n"
			i += 1
		end
		
		$markdown_array[4] = $markdown_array[4] + "```\n"
		
		$markdown_array[5] = "**Amplify Table:**\n"
		
		$markdown_array[6] = ''
		
		while i < amplify_max
			$markdown_array[6] = $markdown_array[6] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1])}|#{spacing(((skill_level[i][1]).to_i * 480).to_s)}|#{avg_array[i]}|#{abs_array[i]}|#{sd_n1_array[i]}|#{sd_1_array[i]}|#{sd_n2_array[i]}|#{sd_2_array[i]}|\n"
			i += 1
		end
		
	when 'Timer Charm', 'Total Charm', 'Rhythmical Charm', 'Perfect Charm'
	
		while i < 9
			skill_level[i] = $card_skill_array[i].split(',')
			skill_level[i][0] = skill_level[i][0].gsub(/[^\d,\.]/, '')
			skill_level[i][1] = spacing(skill_level[i][1].to_i.to_s.gsub(/[^\d,\.]/, ''))
			i += 1
		end
			
		i = 0
	
		while i < 9
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
			
		$markdown_array[2] = "**Score Up:** #{skill_details[0]}, there is a *p* chance of *n* Score Up.\n"
				
		$markdown_array[3] = "```scala\n|S.Lv |  p  |  n  |Charm| Avg | Abs | -1σ | +1σ | -2σ | +2σ |\n=============================================================\n"
				
		$markdown_array[4] = ''
			
		i = 0
	
		while i < 8
				
			$markdown_array[4] = $markdown_array[4] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1])}|#{spacing(((skill_level[i][1]).to_i * 2.5).round.to_s)}|#{avg_array[i]}|#{abs_array[i]}|#{sd_n1_array[i]}|#{sd_1_array[i]}|#{sd_n2_array[i]}|#{sd_2_array[i]}|\n"
			i += 1
					
		end
		
		$markdown_array[4] = $markdown_array[4] + "```\n"
		
		$markdown_array[5] = "**Amplify Table:**\n"
		
		$markdown_array[6] = ''
		
		while i < 9
				
			$markdown_array[6] = $markdown_array[6] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1])}|#{spacing(((skill_level[i][1]).to_i * 2.5).round.to_s)}|#{avg_array[i]}|#{abs_array[i]}|#{sd_n1_array[i]}|#{sd_1_array[i]}|#{sd_n2_array[i]}|#{sd_2_array[i]}|\n"
			i += 1
					
		end	
		
	else # Score Up
	
		while i < amplify_max
			skill_level[i] = $card_skill_array[i].split(',')
			skill_level[i][0] = skill_level[i][0].gsub(/[^\d,\.]/, '')
			skill_level[i][1] = spacing(skill_level[i][1].to_i.to_s.gsub(/[^\d,\.]/, ''))
			i += 1
		end
			
		i = 0
			
		case $card_id
			
		when '90', '107', '162', '182', '206', '1350', '1401', '1449', '1838', '2051'
			
			$markdown_array[2] = "**Unique Score Up Skill:** #{skill_details[0]}, there is a *p* chance of *n* Score Up.\n"
				
			$markdown_array[3] = "```scala\n|S.Lv |  p  |  n  |Charm|\n=========================\n"
					
			$markdown_array[4] = ''
				
			i = 0
			
			while i < 8
				$markdown_array[4] = $markdown_array[4] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1])}|#{spacing(((skill_level[i][1]).to_i * 2.5).round.to_s)}|\n"
				i += 1
			end
			
			$markdown_array[4] = $markdown_array[4] + "```\n"
		
			$markdown_array[5] = "**Amplify Table:**\n"
		
			$markdown_array[6] = ''
			
			while i < amplify_max
				$markdown_array[6] = $markdown_array[6] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1])}|#{spacing(((skill_level[i][1]).to_i * 2.5).round.to_s)}|\n"
				i += 1
			end

		else
			
			while i < amplify_max
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
				
			$markdown_array[2] = "**Score Up:** #{skill_details[0]}, there is a *p* chance of *n* Score Up.\n"
				
			$markdown_array[3] = "```scala\n|S.Lv |  p  |  n  |Charm| Avg | Abs | -1σ | +1σ | -2σ | +2σ |\n=============================================================\n"
				
			$markdown_array[4] = ''
			
			i = 0
	
			while i < 8
				
				$markdown_array[4] = $markdown_array[4] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1])}|#{spacing(((skill_level[i][1]).to_i * 2.5).round.to_s)}|#{avg_array[i]}|#{abs_array[i]}|#{sd_n1_array[i]}|#{sd_1_array[i]}|#{sd_n2_array[i]}|#{sd_2_array[i]}|\n"
				i += 1
					
			end
		
			$markdown_array[4] = $markdown_array[4] + "```\n"
		
			$markdown_array[5] = "**Amplify Table:**\n"
		
			$markdown_array[6] = ''
		
			while i < amplify_max
				
				$markdown_array[6] = $markdown_array[6] + "|#{spacing((i + 1).to_s)}|#{spacing(skill_level[i][0] + '%')}|#{spacing(skill_level[i][1])}|#{spacing(((skill_level[i][1]).to_i * 2.5).round.to_s)}|#{avg_array[i]}|#{amplify_spacing(abs_array[i])}|#{sd_n1_array[i]}|#{sd_1_array[i]}|#{sd_n2_array[i]}|#{amplify_spacing(sd_2_array[i])}|\n"
				i += 1
					
			end
			
			$markdown_array[6] = $markdown_array[6] + "```"
			
			amplify_header = "```scala\n|S.Lv |  p  |  n  |Charm| Avg | Abs  | -1σ | +1σ | -2σ | +2σ  |\n===============================================================\n"
			
			return $markdown_array[0] + $markdown_array[1] + $markdown_array[2] + $markdown_array[3] + $markdown_array[4] + $markdown_array[5] + amplify_header + $markdown_array[6]
				
		end
			
	end
	
	$markdown_array[6] = $markdown_array[6] + "```"
	
	return $markdown_array[0] + $markdown_array[1] + $markdown_array[2] + $markdown_array[3] + $markdown_array[4] + $markdown_array[5] + $markdown_array[3] + $markdown_array[6]
	
end

# Helper method to fill in special card information

def special_cards(id, obj)

	$markdown_array[0] = "**Data for Card:** \[#{$card_id}\] #{obj['idol']['name'].to_s} #{obj['translated_collection'].to_s} \n**Center Skill:** N/A\n"

	case id
		
	when '1166'
		
		$markdown_array[2] = "**Skill Data:** N/A\n"
		$markdown_array[3] = "Practice with a Smile card for 480 experience, or 400 experience for other attributes."
		
	when '83'
	
		$markdown_array[2] = "**Skill Data:** N/A\n"
		$markdown_array[3] = "Practice with a Smile card for 2400 experience, or 2000 experience for other attributes."
			
	when '1022'
		
		$markdown_array[2] = "**Skill Data:** N/A\n"
		$markdown_array[3] = "Practice with a Pure card for 2400 experience, or 2000 experience for other attributes."
			
	when '1070'
		
		$markdown_array[2] = "**Skill Data:** N/A\n"
		$markdown_array[3] = "Practice with a Cool card for 2400 experience, or 2000 experience for other attributes."
			
	when '146'
		
		$markdown_array[2] = "**Skill Data:** N/A\n"
		$markdown_array[3] = "Practice with a Smile card for 6000 experience, or 5000 experience for other attributes."
			
	when '147'
		
		$markdown_array[2] = "**Skill Data:** N/A\n"
		$markdown_array[3] = "Practice with a Pure card for 6000 experience, or 5000 experience for other attributes."
		
	when '148'
		
		$markdown_array[2] = "**Skill Data:** N/A\n"
		$markdown_array[3] = "Practice with a Cool card for 6000 experience, or 5000 experience for other attributes."
			
	when '629', '1136', '1386', '1396', '1397'
		
		$markdown_array[2] = "**Skill Data:** N/A\n"
		$markdown_array[3] = "Practice with a card for 12000 experience."
			
	when '379'
		
		$markdown_array[2] = "**Smile Assist [R]:**\n"
		$markdown_array[3] = "Practice with a Smile card for 10 Skill experience."
			
	when '380'
		
		$markdown_array[2] = "**Pure Assist [R]:**\n"
		$markdown_array[3] = "Practice with a Pure card for 10 Skill experience."
			
	when '381'
		
		$markdown_array[2] = "**Pinpoint Assist [R]:**\n"
		$markdown_array[3] = "Practice with a Cool card for 10 Skill experience."
			
	when '382'
		
		$markdown_array[2] = "**Full Assist [R]:**\n"
		$markdown_array[3] = "Practice with a card for 10 Skill experience."
			
	when '1484'
		
		$markdown_array[2] = "**Uchicchi's Birthday:**\n"
		$markdown_array[3] = "Practice with a card for 50 Skill experience."
			
	when '383', '1340'
		
		$markdown_array[2] = "**Smile Assist [SR]:**\n"
		$markdown_array[3] = "Practice with a Smile card for 100 Skill experience."
			
	when '384', '1341'
		
		$markdown_array[2] = "**Pure Assist [SR]:**\n"
		$markdown_array[3] = "Practice with a Pure card for 100 Skill experience."
			
	when '385', '1342'

		$markdown_array[2] = "**Pinpoint Assist [SR]:**\n"
		$markdown_array[3] = "Practice with a Cool card for 100 Skill experience."
			
	when '386', '1048'
		
		$markdown_array[2] = "**Full Assist [SR]:**\n"
		$markdown_array[3] = "Practice with a card for 100 Skill experience."
			
	when '387', '1343'
		
		$markdown_array[2] = "**Smile Assist [UR]:**\n"
		$markdown_array[3] = "Practice with a Smile card for 1000 Skill experience."
			
	when '388', '1344'
		
		$markdown_array[2] = "**Pure Assist [UR]:**\n"
		$markdown_array[3] = "Practice with a Pure card for 1000 Skill experience."
			
	when '389', '1345'
		
		$markdown_array[2] = "**Pinpoint Assist [UR]:**\n"
		$markdown_array[3] = "Practice with a Cool card for 1000 Skill experience."
			
	when '390', '1346'
		
		$markdown_array[2] = "**Full Assist [UR]:**\n"
		$markdown_array[3] = "Practice with a card for 1000 Skill experience."
		
	else
			
	$markdown_array[2] = "**Skill Data:** N/A\n"
	$markdown_array[3] = ''
		
	end

	$markdown_array[4] = ''
	
	return $markdown_array[0] + $markdown_array[1] + $markdown_array[2] + $markdown_array[3] + $markdown_array[4]

end

# Helper method to open the url to the data
def openurl()

	document = open('https://sif.kirara.ca/card/' + $card_id)
	content = document.read
	$parsed_content = Nokogiri::HTML(content)
	$center_skill = $parsed_content.css('div.description')[1].inner_text
	data = $parsed_content.css('script').children.first.inner_text.split(':') # Now a string
	
	return data
	
end

# Helper method to extract data from the url into global variables
def extract_data()

	data = openurl()

	$card_skill_array = data[extract_helper(data)].split('],') # Split percentage and value with .gsub(/[^\d,\.]/, '')
	
	return
	
end

# Determines index of data

def extract_helper(data)

	i = 0
	
	longest = ''
	
	longest_index = 0
	
	while i < data.length
	
		if data[i].length > longest.length
		
			longest = data[i]
			longest_index = i
		
		end
		
		i += 1

	end
	
	data.delete_at(longest_index)
	
	i = 0
	
	longest = ''
	
	longest_index = 0
	
	while i < data.length
	
		if data[i].length > longest.length
		
			longest = data[i]
			longest_index = i
		
		end
		
		i += 1

	end
	
	return longest_index

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
		
		next if PRACTICE_EXPERIENCE.include? id[0].to_i	#Don't choose special cards
		
		next if SKILL_EXPERIENCE.include? id[0].to_i	#Don't choose special cards
			
		bad_card = false
		
		return id[0]
	
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

# Helper function to update max card count
def update_max_cards()
	JSON.parse(open("http://schoolido.lu/api/cards/").read)['count']
end