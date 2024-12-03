class_name Effect extends Resource


enum Target {
	PLAYER, ENEMY
}

enum Proc {
	INSTANT, 
	SPELL_CHECK, 
	PLAYER_END_TURN, 
	ENEMY_END_TURN
}


var name: String
var target: Target
var proc: Proc


func _init(new_name: String, applies_to: Target, procs_at: Proc) -> void:
	name = new_name
	target = applies_to
	proc = procs_at


func process(_targ: Unit) -> bool:
	print("%s - This effect does nothing!" % [name])
	return true


## ================  INDIVIDUAL EFFECTS  ================ #


## Burn does extra damage over time.
class Burn extends Effect:
	var dmg: float
	var turns: int


	func _init(applies_to: Target, procs_at: Proc, dmg_tick: float, length: int) -> void:
		super("Burn", applies_to, procs_at)
		dmg = dmg_tick
		turns = length


	func process(targ: Unit) -> bool:
		targ.take_dmg(dmg)
		turns -= 1
		print("%s - %s takes %d damage [%d turns remaining]" % [name, targ.name, dmg, turns])
		return turns <= 0


## Heal replenishes health.
class Heal extends Effect:
	var amt: float


	func _init(applies_to: Target, procs_at: Proc, hp: float) -> void:
		super("Heal", applies_to, procs_at)
		amt = hp


	func process(targ: Unit) -> bool:
		targ.heal(amt)
		print("%s - %s heals %d HP" % [name, targ.name, amt])
		return false


## Shield protects against damage. By default, shield only lasts 1 turn.
class Shield extends Effect:
	var amt: float


	func _init(applies_to: Target, procs_at: Proc, hp: float) -> void:
		super("Shield", applies_to, procs_at)
		amt = hp


	func process(targ: Unit) -> bool:
		targ.gain_shield(amt)
		print("%s - %s shields for %d damage" % [name, targ.name, amt])
		return false


## Wild makes the affinity be used in combination with any other.
class Wild extends Effect:
	var affinity: Card.Affinity
	var card_limit: int


	func _init(aff: Card.Affinity, num_cards: int) -> void:
		super("Wild", Target.PLAYER, Proc.SPELL_CHECK)

		affinity = aff
		card_limit = num_cards