# Initializes variables for Mafia game
def mafia_init()
	$mafia_players = Array.new
	$can_join = true
	$join_ending = true
	$max_players = 9
end

# Assigns roles to players
def assign_roles()
	# The original list of players unmodified
	$mafia_players_ordered = $mafia_players.clone
	# Shuffle the original list to assign roles
	$mafia_players = $mafia_players.shuffle
	i = 0
	while i < $mafia_players.length
		$mafia_players[i].role = assign_roles_helper(i)
		$mafia_players[i].player.pm("Hello, your role is #{$mafia_players[i].role.name} this game! Direct message me \"!mafia help\" at night if you don't know what to do.")
		i += 1
	end
end

def assign_roles_helper(i)
	case i 
	
	when i = 0
		role = Honoka.new
		puts 'New Honoka created'
	
	when i = 1
		role = Eli.new
		puts 'New Eli created'
		
	when i = 2
		role = Kotori.new
		puts 'New Kotori created'
		
	when i = 3
		role = Maki.new
		puts 'New Maki created'
		
	when i = 4
		role = Rin.new
		puts 'New Rin created'
	
	else
		role = N_Card.new
		puts 'New N Card created'
		
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
	while i < $mafia_players.length
		
		if !$mafia_players[i].role.night_action
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

# Resets all players' day_action_elect and day_action_vote

def reset_day_action()

	i = 0
	
	while i < $mafia_players.length
		$mafia_players[i].role.day_action_elect = false
		$mafia_players[i].role.day_action_vote = false
		i += 1
	end

end

# Base class for a player in Mafia
class Player

	attr_accessor :player, :name, :alive, :role

	def initialize(player)
		@player = player
		@name = player.name
		@alive = true
		@role = nil
	end
	
end

class Honoka

	@@help_text = "You are Honoka, the leader of Team Idol. You win if you are still in the game when all members of the Student Council are out of the game.\nYou have a one-time use ability `!honk <Number>` otherwise you `!idle` to progress the game state. If you use it, and you are still in the game during the daytime, the player that you targeted will automatically be elected for the daily homework without requiring a majority vote.\nDuring the daytime, your `!elect` and `!vote` are also worth double. In the event of a tie, your nomination and vote will take precedent."
	
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
		if @honk
			@honk = false
			@night_action = true
			@honk_target = target
			puts "You decide to Honk " + target
		else
			puts "You already used your Honked this game. Do \"!idle\" to progress the game."
		end
	end
	
	def idle()
		@honk_target = nil
		@night_action = true
		return 'You decide to do nothing tonight.'
	end

end

class Eli

	@@help_text = "You are the President of Team Student Council. You win if there is still a Student Council member in the game when all members of Team Idol are out of the game.\nYou can `!assign <Number>` each night, or `!idle` to assign homework to nobody. Whoever you target with `!assign` will be removed from the game unless Maki targets the same player that night.\nIf Kotori follows you and you `!assign` homework, she will remove you from the game! In a 6+ player game, Umi or Nozomi will take your place as President if they are still in the game when you are removed."

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
		
	end
	
	def idle()
		@assign_target = nil
		@night_action = true
		return 'You decided to assign homework to nobody tonight.'
	end

end

class Kotori

	@@help_text = "You are Kotori, the Cop and a member of Team Idol. You win if you are still in the game when all members of Team Student Council are out of the game.\nYou must `!follow <Number>` each night. If you follow Eli and they assign homework that night, you will catch her during the day and remove her from the game."

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
		
	end

end

class Maki

	@@help_text = "You are Maki, the Tutor Doctor and a member of Team Idol. You win if you are still in the game when all members of Team Student Council are out of the game.\nYou must `!help < Number>` each night. You can't target the same player twice in a row. You can also target yourself. If your target is also targeted by `!assign` or `!shoot` in the same night, you will save that target from being removed from the game."

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
		
	end

end
 
class Rin

	@@help_text = "You are Rin, the Cat Idol and a member of Team Idol. You win if you are still in the game when all members of the Student Council are out of the game.\nYou have a one-time use ability `!nyaa`; otherwise you `!idle` to progress the game state. If you use your ability, you will evade all actions during the daytime and you will discover the identity of anyone that targeted you."

	attr_accessor :name, :night_action, :day_action_elect, :day_action_vote, :nyaa

	def initialize()
		@name = 'Rin'
		@night_action = false
		@day_action_elect = false
		@day_action_vote = false
		@nyaa = true
	end
	
	def help_text()
		return @@help_text
	end
	
	def nyaa(target)
		if @nyaa
			@nyaa = false
			@night_action = true
			return 'You decide to become a cat tonight.'
		else
			return "You already used your Nyaa this game. Do \"!idle\" to progress the game."
		end
	end
	
	def idle()
		@night_action = true
		return 'You decide to do nothing tonight.'
	end

end

class N_Card

	@@help_text = "You are an N Card. You have no abilities that you can use. You must !idle` every night to progress the game state."

	attr_accessor :name, :night_action, :day_action_elect, :day_action_vote

	def initialize()
		@name = 'N Card'
		@night_action = false
		@day_action_elect = false
		@day_action_vote = false
	end
	
	def idle()
		@night_action = true
		return 'You decide to do nothing tonight.'
	end

end