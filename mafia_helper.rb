# Initializes variables for Mafia game
def mafia_init()

	$mafia_players = Array.new
	$mafiaadmin = nil
	$active_game = false
	$can_join = false
	$current_players = 0
	$abstain_count = 0
	
	$is_morning = false
	$cat = false
	
	$everyone_elected = false
	$everyone_voted = false
	$elect_tie = true
	$can_vote = false
	$vote_yes = 0
	$vote_no = 0
	
	$end_game_message = ''
	
	# Pointers to current players
	$current_president = nil
	
	$current_honoka = nil
	$current_kotori = nil
	$current_maki = nil
	$current_rin = nil
	$current_umi = nil
	$current_hanayo = nil
	$current_nozomi= nil
	$current_nico = nil
	
	$elect_target = nil
	$elect_target_index = nil
	
end

# Sanity check to prevent idiots
def sanity_check(input)

	x = $mafia_players_ordered.length - 1
	if input.to_i.abs == (0..x)
		return true
	end
	return false
	
end

# Assigns roles to players
def assign_roles()
	# The original list of players unmodified, use for listing and altering indexed values
	$president_name = 'Eli'
	$mafia_players_ordered = $mafia_players.clone
	# The randomized list of players, use for iterating and altering all values instead of one
	$mafia_players = $mafia_players.shuffle
	
	i = 0
	
	while i < $mafia_players.length
	
		$mafia_players[i].role = assign_roles_helper(i)
		$mafia_players[i].player.pm("Hello, your role is #{$mafia_players[i].role.name} this game! Direct message me \"!mafia help\" at night if you don't know what to do.")
		i += 1
		
	end
	
	$mafia_night_counter = 0
	
end

def assign_roles_helper(i)

	case i 
	
	when i = 0
		role = Honoka.new
		$current_honoka = role
	
	when i = 1
		role = Eli.new
		$current_president = role
		
	when i = 2
		role = Kotori.new
		$current_kotori = role
		
	when i = 3
		role = Maki.new
		$current_maki = role
		
	when i = 4
		role = Rin.new
		$current_rin = role
		
	when i = 50
		role = Umi.new
		$current_umi = role
		
	when i = 60
		role = Hanayo.new
		$current_hanayo = role
		
	when i = 70
		role = Nozomi.new
		$current_nozomi = role
		
	when i = 80
		role = Nico.new
		$current_nico = role
	
	else
		role = N_Card.new
		
	end
		
	return role
	
end

# For displaying numbers correctly
def ordinal(n)

	case n
	
	when n = 1
		return 'st'
	
	when n = 2
		return 'nd'
	
	when n = 3
		return 'rd'
		
	else
		return 'th'
	end
	
end

# Increments the night count
def mafia_night()

	$is_morning = false
	$cat = false
	$mafia_night_counter += 1
	$mafia_night = $mafia_night_counter.to_s + ordinal($mafia_night_counter)
	
end

# Lists the current players of the game
def list_players()

	i = 0
	player_list = "Current Players: \n"
	
	while i < $mafia_players_ordered.length
	
		if $mafia_players_ordered[i].alive
			player_list = player_list + "Player #{i + 1} = #{$mafia_players_ordered[i].name}\n"
		end
		
		i += 1
	end

	return player_list
	
end

# Check to progress to morning if every player has made their move
def end_night()
	
	i = 0
	while i < $mafia_players_ordered.length
		
		if $mafia_players_ordered[i].alive && !$mafia_players_ordered[i].role.night_action
			puts 'Waiting for others to make their move'
			return
		end
		
		i += 1
		
	end
	
	$is_morning = true
	
end

# Resets all players' night_action

def reset_night_action()

	i = 0
	
	while i < $mafia_players.length
		$mafia_players[i].role.night_action = false
		i += 1
	end

end

# Resets all players' day variables

def reset_day_action()

	i = 0
	
	while i < $mafia_players.length
	
		$mafia_players[i].elect_count = 0
		$mafia_players[i].vote_count = 0
		$mafia_players[i].role.day_action_elect = false
		$mafia_players[i].role.day_action_vote = false
		i += 1
		
	end
	
	$abstain_count = 0
	$everyone_elected = false
	$everyone_voted = false
	$elect_tie = true
	$can_vote = false
	
	$elect_target = nil
	$elect_target_index = nil
	
	$vote_yes = 0
	$vote_no = 0

end

# Removes a player from the game
def remove_player(n)

	$mafia_players_ordered[n].alive = false
	$current_players -= 1
	# Remove player from global variables
	case $mafia_players_ordered[n].role.name
	
	when 'Honoka'
	
		$current_honoka = nil
		
	when 'Eli'
		
		# President replacement function here
		$current_eli = nil
		# If no replacement, end game
		$current_president = nil
	
	when 'Kotori'
	
		$current_kotori = nil
	
	when 'Maki'
	
		$current_maki = nil
		
	when 'Rin'
	
		$current_rin = nil
		
	when 'Umi'
	
		$current_umi = nil
		
	when 'Hanayo'
	
		$current_hanayo = nil
		
	when 'Nozomi'
	
		$current_nozomi = nil
		
	when 'Nico'
	
		$current_nico = nil
	
	else
	
	end
	
end

# Result of President's night actions and Maki
def president_assign()
	# If Maki did not save target, remove target from game
	if $current_president.assign_target.nil?
	
		message = $president_name + ' assigned homework to nobody!'
		
	else
	
		if !$current_maki.nil?
		
			if $current_president.assign_target == $current_maki.help_target
				message = $president_name + ' assigned homework to **' + $mafia_players_ordered[$current_president.assign_target - 1].name + '**, but Maki was there to help!'
			else
				remove_player($current_president.assign_target - 1)
				message = $president_name + ' assigned homework to ' + $mafia_players_ordered[$current_president.assign_target - 1].name + "**. They will work on it for the rest of the game!\nMaki was too busy helping " + $mafia_players_ordered[$current_maki.help_target - 1].name + '** tonight!'
			end
			
		else
			message = $president_name + ' assigned homework to **' + $mafia_players_ordered[$current_president.assign_target - 1].name + '**. They will work on it for the rest of the game!'
			remove_player($current_president.assign_target - 1)
		end
		
	end
	
	return message
	
end

# Result of Kotori's follow
def kotori_follow()
	# If Kotori followed President and they assigned homework
	if !$current_president.assign_target.nil?
		if $mafia_players_ordered[$current_kotori.follow_target - 1].role.name == $current_president.name
		
			message = 'Kotori was following **' + $mafia_players_ordered[$current_kotori.follow_target - 1].name + '** and guilted her to help with the homework!'
			remove_player($current_kotori.follow_target - 1)
			return message
		
		end
	end
	
	message = 'Kotori was following **' + $mafia_players_ordered[$current_kotori.follow_target - 1].name + '** but they did not do anything suspicious.'
	
	return message
	
end

# Check if end game condition is met

def end_game()

	winners = ''
	
	i = 0

	# Check if Team Idol Wins (All Council members were assigned homework)
	if $current_president.nil?
		
		while i < $mafia_players_ordered.length
	
			if $mafia_players_ordered[i].alive
				winners = winners + '**' + $mafia_players_ordered[i].name + ' as ' + $mafia_players_ordered[i].role.name + "**\n"
			end
			
			i += 1
		
		end
		
		$end_game_message = "The game is over! Team Idol wins! The winners are:\n#{winners}"
		
		return true
		
	# Check if Team Council Wins (All Idol members were assigned homework)
	elsif $current_honoka.nil? && $current_kotori.nil? && $current_maki.nil? && $current_rin.nil?

		while i < $mafia_players_ordered.length
	
			if $mafia_players_ordered[i].role.name == 'Eli' || $mafia_players_ordered[i].role.name == 'Umi' || $mafia_players_ordered[i].role.name == 'Nozomi'
				winners = winners + '**' + $mafia_players_ordered[i].name + "**\n"
			end
			
			i += 1
		
		end
			
		$end_game_message = "The game is over! Team Council wins! The winners are:\n#{winners}"
			
		return true
		
	else
	
		return false
		
	end
	
end

# Election function
def elect(n)

	if n == 0
	
		$abstain_count += 1
		return " abstained from electing. Total abstain count: #{$abstain_count}"
		
	else
	
		$mafia_players_ordered[n - 1].elect_count += 1
		return " elected **#{$mafia_players_ordered[n - 1].name}**. Total votes for #{$mafia_players_ordered[n - 1].name}: #{$mafia_players_ordered[n - 1].elect_count}"
	
	end
	
end

# Check that everyone has elected, or that abstain count is majority
def end_election()

	i = 0
	while i < $mafia_players_ordered.length
		
		if $mafia_players_ordered[i].alive && !$mafia_players_ordered[i].role.day_action_elect
			return
		end
		
		i += 1
		
	end
	
	$everyone_elected = true
	
end

# Check that everyone has voted
def end_voting()

	i = 0
	while i < $mafia_players_ordered.length
		
		if $mafia_players_ordered[i].alive && !$mafia_players_ordered[i].role.day_action_vote
			puts 'Waiting for others to make their move'
			return
		end
		
		i += 1
		
	end
	
	$everyone_voted = true
	
end

# Check if a majority was reached for election
def majority_elected()

	if $abstain_count > ($current_players / 2)
	
		return false
	
	else

		# Find the player with the largest elect_count
		i = 0
		current_max = 0
		
		
		while i < $mafia_players_ordered.length
		
			if $mafia_players_ordered[i].elect_count >= current_max
			
				if $mafia_players_ordered[i].elect_count == current_max
				
					$elect_tie = true
				
				else
				
					$elect_tie = false
					$elect_target = $mafia_players_ordered[i]
					$elect_target_index = i
					current_max = $mafia_players_ordered[i].elect_count
				
				end
			
			end
		
			i += 1
		
		end
		
		if !$elect_tie
			return true
		end
	
	end

	return false
	
end

# Results of the vote
def vote_result()

	if $cat
	
		message = "A cat destroyed the daily homework, so **#{$elect_target.name}** was spared!\nVote Result: #{$vote_yes} Yes, #{$vote_no} No"

	elsif $vote_yes > $vote_no
										
		message = "**#{$elect_target.name} will do the daily homework!**\nVote Result: #{$vote_yes} Yes, #{$vote_no} No"
		remove_player($elect_target_index)
		
	else
	
		message = "**#{$elect_target.name} will NOT do the daily homework!**\nVote Result: #{$vote_yes} Yes, #{$vote_no} No"
	
	end
	
	return message

end

# Honoka honks



# Check if Honoka is alive and has honked
def honk()
	if !$current_honoka.nil?
		if !$current_honoka.honk_target.nil?
			return true
		end
	end
	return false
end

# Check if Rin is alive and used her Cat
def cat()
	if !$current_rin.nil?
		if !$current_rin.cat.nil?
			return true
		end
	end
	return false
end

# Base class for a player in Mafia
class Player

	attr_accessor :player, :name, :elect_count, :vote_count, :alive, :role

	def initialize(event_user)
		@player = event_user
		@name = player.name
		@elect_count = 0
		@vote_count = 0
		@alive = true
		@role = nil
	end
	
end

class Honoka

	@@help_text = "You are **Honoka**, the leader of Team Idol. You win if you are still in the game when all members of the Student Council are out of the game.\nYou have a one-time use ability `!honk <Number>` otherwise you `!idol` to progress the game state. If you use it, and you are still in the game during the daytime, the player that you targeted will automatically be elected for the daily homework without requiring a majority vote.\nDuring the daytime, your `!vote` is also worth double."
	
	attr_accessor :name, :night_action, :day_action_elect, :day_action_vote, :honk_target

	def initialize()
		@name = 'Honoka'
		@night_action = false
		@day_action_elect = false
		@day_action_vote = false
		@honk = true
		@honk_target = nil
	end
	
	def help_text()
		return @@help_text
	end
	
	def honk(target)
	
		if sanity_check(target)
		
			if @honk
				@honk = false
				@night_action = true
				@honk_target = target
				return "You decide to honk #{$mafia_players_ordered[target - 1].name}"
			else
				return "You already used your Honked this game. Do \"!idol\" to progress the game."
			end
			
		else
			return "Invalid number"
		end
		
	end
	
	def idol()
		@honk_target = nil
		@night_action = true
		return 'You decide to do nothing tonight.'
	end

end

class Eli

	@@help_text = "You are Eli, the President of Team Student Council. You win if there is still a Student Council member in the game when all members of Team Idol are out of the game. If Nozomi is in the game, you will know her identity at the start of the game.\nYou can `!assign <Number>` each night, or `!idol` to assign homework to nobody. Whoever you target with `!assign` will be removed from the game unless Maki targets the same player that night.\nIf Kotori follows you and you `!assign` homework, she will remove you from the game! In a 6+ player game, Umi or Nozomi will take your place as President if they are still in the game when you are removed."

	attr_accessor :name, :night_action, :day_action_elect, :day_action_vote, :assign_target

	def initialize()
		@name = $president_name
		@night_action = false
		@day_action_elect = false
		@day_action_vote = false
		@assign_target = nil
	end
	
	def help_text()
		return @@help_text
	end
	
	def assign(target)
	
		if sanity_check(target)
		
			if $is_morning
				return 'You can only assign homework at night!'
				
			else
		
				if $mafia_players_ordered[target - 1].alive
				
					if $mafia_players_ordered[target - 1].role.name == $president_name
						return 'You cannot assign homework to yourself!'
						
					else
						@assign_target = target
						@night_action = true
						return "You decide to assign homework to #{$mafia_players_ordered[target - 1].name}"
						
					end
				
				else
					return 'Not a valid target.'
				
				end
				
			end
			
		else
			return "Invalid number"
		end
		
	end
	
	def idol()
		@assign_target = nil
		@night_action = true
		return 'You decided to assign homework to nobody tonight.'
	end

end

class Kotori

	@@help_text = "You are **Kotori**, the Cop and a member of Team Idol. You win if you are still in the game when all members of Team Student Council are out of the game.\nYou must `!follow <Number>` each night. If you follow Eli and they assign homework that night, you will catch her during the day and remove her from the game."

	attr_accessor :name, :night_action, :day_action_elect, :day_action_vote, :follow_target

	def initialize()
		@name = 'Kotori'
		@night_action = false
		@day_action_elect = false
		@day_action_vote = false
		@follow_target = nil
	end
	
	def help_text()
		return @@help_text
	end
	
	def follow(target)
	
		if sanity_check(target)
	
			if $is_morning
				return 'You can only follow at night!'
				
			else
		
				if $mafia_players_ordered[target - 1].alive
				
					if $mafia_players_ordered[target - 1].role.name == 'Kotori'
						return 'You cannot follow yourself!'
						
					else
						@follow_target = target
						@night_action = true
						return "You decide to follow #{$mafia_players_ordered[target - 1].name}"
						
					end
				
				else
					return 'Not a valid target.'
				
				end
				
			end
			
		else
			return "Invalid number"
		end
		
	end

end

class Maki

	@@help_text = "You are **Maki**, the Tutor Doctor and a member of Team Idol. You win if you are still in the game when all members of Team Student Council are out of the game.\nYou must `!help < Number>` each night. You can't target the same player twice in a row. You can also target yourself. If your target is also targeted by `!assign` in the same night, you will save that target from being removed from the game."

	attr_accessor :name, :night_action, :day_action_elect, :day_action_vote, :help_target, :last_helped

	def initialize()
		@name = 'Maki'
		@night_action = false
		@day_action_elect = false
		@day_action_vote = false
		@help_target = nil
		@last_helped = 0
	end
	
	def help_text()
		return @@help_text
	end
	
	def help(target)
	
		if sanity_check(target)
	
			if $is_morning
				return 'You can only help at night!'
				
			else
		
				if $mafia_players_ordered[target - 1].alive
				
					if target == @last_helped
						return 'You cannot help the same player two nights in a row!'
					else
						@help_target = target
						@last_helped = target
						@night_action = true
						return "You decide to help #{$mafia_players_ordered[target - 1].name}"
					end
				
				else
					return 'Not a valid target.'			
				end
				
			end
			
		else
			return "Invalid number"
		end
		
	end

end
 
class Rin

	@@help_text = "You are **Rin**, the Cat Idol and a member of Team Idol. You win if you are still in the game when all members of the Student Council are out of the game.\nYou have a one-time use ability `!cat`; otherwise you `!idol` to progress the game state. If you use your ability, your cat will destroy the daily homework, thus saving anyone that was elected and voted for on the following day. This ability will work even if you are eliminated before the election and voting cycle begins."

	attr_accessor :name, :night_action, :day_action_elect, :day_action_vote, :cat

	def initialize()
		@name = 'Rin'
		@night_action = false
		@day_action_elect = false
		@day_action_vote = false
		@cat = true
	end
	
	def help_text()
		return @@help_text
	end
	
	def cat()
		if @cat
			@cat = false
			$cat = true
			@night_action = true
			return 'You send your Cat out tonight to destroy the daily homework.'
		else
			return "You already used your Cat this game. Do \"!idol\" to progress the game."
		end
	end
	
	def idol()
		@night_action = true
		return 'You decide to do nothing tonight.'
	end

end

class Umi

	@@help_text = "You are **Umi**, the Archer and a member of Team Student Council. You win if there is still a Student Council member in the game when all members of Team Idol are out of the game.\nYou have a one-time use ability `!arrow`; otherwise you `!idol` to progress the game state. Arrow will negate the targetted player's action for the night. If that player used a one-time use ability, they will not be able to use it again.\nIf both Eli and Nozomi are out of the game, you will become the President and gain the ability to `!assign <Number>` each night instead."

	attr_accessor :name, :night_action, :day_action_elect, :day_action_vote, :arrow, :arrow_target, :assign_target

	def initialize()
		@name = 'Umi'
		@night_action = false
		@day_action_elect = false
		@day_action_vote = false
		@arrow = true
		@arrow_target = nil
		@assign_target = nil
	end
	
	def help_text()
		return @@help_text
	end
	
	def arrow(target)
	
		if sanity_check(target)
		
		else
			return "Invalid number"
		end

	end
	
	def assign(target)
	
		if sanity_check(target)
		
		else
			return "Invalid number"
		end

	end
	
	def idol()
		@night_action = true
		return 'You decide to do nothing tonight.'
	end

end

class Hanayo

	@@help_text = "You are **Hanayo**, the Detective and a member of Team Idol. You win if you are still in the game when all members of the Student Council are out of the game.\nYou must `!inspect <Number>` each night. Whoever you inspect you will learn if they are on Team Idol or Team Student Council."

	attr_accessor :name, :night_action, :day_action_elect, :day_action_vote, :inspect_target

	def initialize()
		@name = 'Hanayo'
		@night_action = false
		@day_action_elect = false
		@day_action_vote = false
		@inspect_target = nil
	end
	
	def help_text()
		return @@help_text
	end
	
	def inspect(target)
	
		if sanity_check(target)
		
		else
			return "Invalid number"
		end

	end

end

class Nozomi

	@@help_text = "You are Nozomi, the Vice President of Team Student Council. You win if there is still a Student Council member in the game when all members of Team Idol are out of the game. You will also know the identity of Eli at the start of the game.\nYou can `!washi <Number>` each night, or `!idol` to do nothing. Whoever you target with `!washi` will be unable to elect and vote during the daytime. You cannot target the same player twice.\nIf Eli is eliminated from the game, you will become the new President and gain the ability to `!assign <Number>` instead."

	attr_accessor :name, :night_action, :day_action_elect, :day_action_vote, :washi_target, :assign_target

	def initialize()
		@name = 'Nozomi'
		@night_action = false
		@day_action_elect = false
		@day_action_vote = false
		@washi_target = nil
		@assign_target = nil
	end
	
	def help_text()
		return @@help_text
	end
	
	def washi(target)
	
		if sanity_check(target)
		
		else
			return "Invalid number"
		end
		
	end
	
	def assign(target)
	
		if sanity_check(target)
		
		else
			return "Invalid number"
		end

	end
	
	def idol()
		@assign_target = nil
		@night_action = true
		return 'You decided to assign homework to nobody tonight.'
	end

end

class Nico

	@@help_text = "You are **Nico**, the Charmer and a member of Team Idol. You win if you are still in the game when all members of the Student Council are out of the game.\nYou have a one-time use ability `!charm <Number>`; otherwise you `!idol` to progress the game state. Whoever you Charm will have their night action target randomized. If you choose a target with no night action, the charm will fail but it won't take up your one use."

	attr_accessor :name, :night_action, :day_action_elect, :day_action_vote, :charm_target

	def initialize()
		@name = 'Nico'
		@night_action = false
		@day_action_elect = false
		@day_action_vote = false
		@charm_target = nil
	end
	
	def help_text()
		return @@help_text
	end
	
	def charm(target)
	
		if sanity_check(target)
		
		else
			return "Invalid number"
		end

	end

end

class N_Card

	@@help_text = "You are an N Card. You have no abilities that you can use. You must !idol` every night to progress the game state."

	attr_accessor :name, :night_action, :day_action_elect, :day_action_vote

	def initialize()
		@name = 'N Card'
		@night_action = false
		@day_action_elect = false
		@day_action_vote = false
	end
	
	def idol()
		@night_action = true
		return 'You decide to do nothing tonight.'
	end

end