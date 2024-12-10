Scriptname XMPIgniteBarrels extends ObjectReference

Import PO3_SKSEFunctions
;====================================================

sound property FallingSound auto
weapon property FallingOilWeapon auto
ammo property FallingOilAmmo auto
explosion property OilExplosion auto

Keyword Property XMPFireDamage Auto
Float Property NearbyHazardExplosionRadius = 10.0 Auto
Formlist Property XMPFireSources Auto
Bool HasFireAmmo = False

;====================================================

Function SwitchToFalling(objectReference causeActor)
	UnregisterForUpdate()
	goToState("Triggered")
	self.setActorCause(causeActor as actor)
	FallingSound.play(self)
	self.DamageObject(10.0)	
	DisableLinkChain()
EndFunction

Function ReplaceObject()
	self.PlaceAtMe(OilExplosion, 1, true, true)
EndFunction

Event OnLoad()
	RegisterForUpdate(0.5)
EndEvent

Event OnUpdate()
	Actor player = Game.GetPlayer()
	Ammo equippedAmmo = GetEquippedAmmo(player)
	if equippedAmmo
		Enchantment ammoEnchantment = GetEquippedAmmoEnchantment(player)
		if ammoEnchantment.HasKeyword(XMPFireDamage) || equippedAmmo.HasKeyword(XMPFireDamage)
			HasFireAmmo = True
		else
			HasFireAmmo = False
		endif
	else
		HasFireAmmo = False
	endif
EndEvent

Event OnMagicEffectApply(ObjectReference akCaster, MagicEffect akEffect)
	if akEffect.HasKeyword(XMPFireDamage) || XMPFireSources.HasForm(akEffect)
		SwitchToFalling(akCaster)
	endif
EndEvent

Event onHit(objectReference akAggressor, form akSource, projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
	if akSource.HasKeyword(XMPFireDamage) || XMPFireSources.HasForm(akSource) || HasFireAmmo
		SwitchToFalling(akAggressor)
	endif
EndEvent
  
Event OnDestructionStageChanged(int aiOldStage, int aiCurrentStage)
	if aiCurrentStage == 1
		SwitchToFalling(self)
	endif
    
	if aiCurrentStage == 2
		ReplaceObject()
		Utility.Wait(1.5)
		self.Disable()
		self.Delete()
    	endif
EndEvent

state Triggered
	Event onBeginState()
	EndEvent

	Event onHit(objectReference akAggressor, form akSource, projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
		self.setActorCause(akAggressor as actor)
	EndEvent
	
	Event onTriggerEnter(objectReference triggerRef)
		self.DamageObject(90.0)
	EndEvent

	Event OnDestructionStageChanged(int aiOldStage, int aiCurrentStage)	
		if aiCurrentStage == 2
			ReplaceObject()
			Utility.Wait(1.5)
			self.Disable()
			self.Delete()
		endif
	EndEvent
EndState

Event onReset()
	self.reset()
	self.clearDestruction()
	goToState("waiting")
EndEvent
