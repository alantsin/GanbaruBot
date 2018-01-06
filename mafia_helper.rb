# Initializes variables for Mafia game
def mafia_init()
	$mafia_players = Array.new
	$can_join = true
	$join_ending = true
	$max_players = 9
end

def assign_roles()
	$mafia_players = $mafia_players.shuffle
	i = 0
	while i < $mafia_players.length
		$mafia_players[i].role = assign_roles_helper(i)
		$mafia_players[i].player.pm("Hello, your role is " + $mafia_players[i].role.name + " this game! Direct message me \"!mafia help\" at night if you don't know what to do.")
		i += 1
	end
end

def assign_roles_helper(i)
	case i 
	
	when i = 0
		role = Honoka.new
		puts "New Honoka created"
	
	when i = 1
		role = Eli.new
		puts "New Eli created"
		
	when i = 2
		role = Kotori.new
		puts "New Kotori created"
		
	when i = 3
		role = Maki.new
		puts "New Maki created"
		
	when i = 4
		role = Rin.new
		puts "New Rin created"
	
	else
		role = N_Card.new
		puts "New N Card created"
		
	end
		
	return role
	
end

def mafia_start()
	$mafia_night = 0
	
end

# Helper function to determine if target is a player in the game
def is_player(target)

	return false
end

# Base class for a player in Mafia
class Player

	attr_accessor :player, :name, :role

	def initialize(player)
		@player = player
		@name = player.name
		@role = nil
	end
	
end

class Honoka

	@@help_text = "You are Honoka, the leader of Team Idol. You win if you are still in the game when all members of the Student Council are out of the game.\nYou have a one-time use ability `!honk <username>` otherwise you `!idle` to progress the game state. If you use it, and you are still in the game during the daytime, the player that you targeted will automatically be elected for the daily homework without requiring a majority vote.\nDuring the daytime, your `!elect` and `!vote` are also worth double. In the event of a tie, your nomination and vote will take precedent."
	
	attr_accessor :name, :night_action, :day_action_elect, :day_action_vote, :honk_target

	def initialize()
		@name = "Honoka"
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
		puts "You decide to do nothing tonight."
	end

end

class Eli

	@@help_text = "You are the President of Team Student Council. You win if there is still a Student Council member in the game when all members of Team Idol are out of the game.\nYou can `!assign <username>` each night, or `!idle` to assign homework to nobody. Whoever you target with `!assign` will be removed from the game unless Maki targets the same player that night.\nIf Kotori follows you and you `!assign` homework, she will remove you from the game! In a 6+ player game, Umi or Nozomi will take your place as President if they are still in the game when you are removed."

	attr_accessor :name, :night_action, :day_action_elect, :day_action_vote, :assign_target

	def initialize()
		@name = "Eli"
		@night_action = false
		@day_action_elect = false
		@day_action_vote = false
		@assign_target = nil
	end
	
	def help_text()
		return @@help_text
	end
	
	def assign(target)
		@assign_target = target
		@night_action = true
		puts "You decide to assign homework to " + target
	end
	
	def idle()
		@assign_target = nil
		@night_action = true
		puts "Assigned homework to nobody tonight."
	end

end

class Kotori

	@@help_text = "You are Kotori, the Cop and a member of Team Idol. You win if you are still in the game when all members of Team Student Council are out of the game.\nYou must `!follow <username>` each night. If you follow Eli and they assign homework that night, you will catch her during the day and remove her from the game.\nIn a 7+ player game, Hanayo will know your identity when the game starts."

	attr_accessor :name, :night_action, :day_action_elect, :day_action_vote, :follow_target

	def initialize()
		@name = "Kotori"
		@night_action = false
		@day_action_elect = false
		@day_action_vote = false
		@follow_target = nil
	end
	
	def help_text()
		return @@help_text
	end
	
	def follow(target)
		@follow_target = target
		@night_action = true
		puts "You decide to follow " + target
	end

end

class Maki

	@@help_text = "You are Maki, the Tutor Doctor and a member of Team Idol. You win if you are still in the game when all members of Team Student Council are out of the game.\nYou must `!help <username>` each night. You can't target the same player twice in a row. You can also target yourself. If your target is also targeted by `!assign` or `!shoot` in the same night, you will save that target from being removed from the game."

	attr_accessor :name, :night_action, :day_action_elect, :day_action_vote, :help_target, :last_helped

	def initialize()
		@name = "Maki"
		@night_action = false
		@day_action_elect = false
		@day_action_vote = false
		@help_target = nil
		@last_helped = ""
	end
	
	def help_text()
		return @@help_text
	end
	
	def help(target)
		if target == @last_helped
			puts "Cannot help the same person twice in a row"
		else
			@help_target = target
			@night_action = true
			@last_helped = target
			puts "You decide to help " + target
		end
	end

end
 
class Rin

	@@help_text = "You are Rin, the Cat Idol and a member of Team Idol. You win if you are still in the game when all members of the Student Council are out of the game.\nYou have a one-time use ability `!nyaa`; otherwise you `!idle` to progress the game state. If you use your ability, you will evade all actions during the daytime and you will discover the identity of anyone that targeted you."

	attr_accessor :name, :night_action, :day_action_elect, :day_action_vote, :nyaa

	def initialize()
		@name = "Rin"
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
			puts "You decide to become a cat tonight."
		else
			puts "You already used your Nyaa this game. Do \"!idle\" to progress the game."
		end
	end
	
	def idle()
		@honk_target = nil
		@night_action = true
		puts "You decide to do nothing tonight."
	end

end

class N_Card

	attr_accessor :night_action, :day_action_elect, :day_action_vote

	def initialize()
		@night_action = false
		@day_action_elect = false
		@day_action_vote = false
	end

end