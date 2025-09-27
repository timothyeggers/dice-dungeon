class_name EnemyData extends Resource

@export var name: String
@export var stats: DamageReceiverData
@export var abilities: Array[AbilityData]
@export var portrait: Texture
# adding to total PathData.threat_level
@export var threat_weight := 1
# not in use 
@export var theme := "Stoney Halls"
