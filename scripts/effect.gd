class_name Effect extends Resource


enum Target {
	PLAYER, ENEMY
}

enum Proc {
	START_TURN,
	SPELL_CHECK, 
	END_TURN
}


@export var name: String
@export var target: Target
@export var proc: Proc
@export var turns: int


func _init(eff_name: String, applies_to: Target, procs_at: Proc, length: int) -> void:
	name = eff_name
	target = applies_to
	proc = procs_at
	turns = length


func new_instance() -> Effect:
	return Effect.new(name, target, proc, turns)


## ================  INDIVIDUAL EFFECTS  ================ #


## Burn does extra damage over time.
class Burn extends Effect:
	@export var dmg: float


	func _init(applies_to: Target, procs_at: Proc, dmg_tick: float, length: int) -> void:
		super("Burn", applies_to, procs_at, length)
		dmg = dmg_tick


	func new_instance() -> Effect.Burn:
		return Effect.Burn.new(target, proc, dmg, turns)


## Heal replenishes health.
class Heal extends Effect:
	@export var hp: float


	func _init(applies_to: Target, procs_at: Proc, heal: float, length: int) -> void:
		super("Heal", applies_to, procs_at, length)
		hp = heal


	func new_instance() -> Effect.Heal:
		return Effect.Heal.new(target, proc, hp, turns)


## Shield protects against damage. By default, shield only lasts 1 turn.
class Shield extends Effect:
	@export var hp: float


	func _init(applies_to: Target, procs_at: Proc, shield: float, length: int) -> void:
		super("Shield", applies_to, procs_at, length)
		hp = shield


	func new_instance() -> Effect.Shield:
		return Effect.Shield.new(target, proc, hp, turns)


## Wild makes the affinity be used in combination with any other.
class Wild extends Effect:
	@export var affinity: Card.Affinity
	@export var card_limit: int


	func _init(aff: Card.Affinity, num_cards: int, length: int) -> void:
		super("Wild", Target.PLAYER, Proc.SPELL_CHECK, length)

		affinity = aff
		card_limit = num_cards


	func new_instance() -> Effect.Wild:
		return Effect.Wild.new(affinity, card_limit, turns)