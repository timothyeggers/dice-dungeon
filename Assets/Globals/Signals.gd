extends Node

#region Global
signal dice_selected(diceControl)
signal dice_deselected(diceControl)
#endregion

#region Overworld

#endregion

#region Battle Scene
signal receiver_selected(damage_receiver: DamageReceiverComponent)

## Emitted at the end of the start player turn function
signal player_start_turn
## Emitted at the end of end player turn function
signal player_end_turn
## Emitted at the end of start enemy turn function
signal enemy_start_turn
## Emitted at the end of end enemy turn function
signal enemy_end_turn
#endregion
