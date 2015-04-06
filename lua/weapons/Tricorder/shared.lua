if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
	SWEP.HoldType			= "pistol"
	
end

if ( CLIENT ) then

	SWEP.PrintName		= "Tricorder"			
	SWEP.Category = "Star Trek"
	SWEP.Author		= "SuperPlayer"
	SWEP.Slot		= 0
	SWEP.SlotPos		= 4
	SWEP.Description	= "Tricorder"
	SWEP.Purpose		= "Transportation"
	SWEP.Instructions = "Left Click to beam 'home'.\n\nRight click to select 'home' Transporter Platform.\n\nSwitch to a different SWEP and you last coordinates will be saved."

	// Inventory Icon
	
	language.Add("communicator","Communicator");
end

SWEP.Spawnable = true;
SWEP.AdminSpawnable = true;

SWEP.viewModel = "models/ef2weapons/tricorder_stx/tricorder.mdl"
SWEP.worldModel = "models/ef2weapons/tricorder_stx/tricorder.mdl"
 
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
  
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
