-- Read the weapon_real_base if you really want to know what each action does

if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType 		= "ar2"
end

if (CLIENT) then
	SWEP.PrintName 		= "Compression Phaser"
	SWEP.Slot 			= 3
	SWEP.SlotPos 		= 1
	SWEP.IconLetter 		= " "
	SWEP.ViewModelFOV = 65
	SWEP.DrawCrosshair		= true
	SWEP.DrawAmmo	 = false
end


SWEP.Instructions 		= " "

SWEP.Category			= "Star Trek"
SWEP.Author 			= "SuperPlayer"	
SWEP.Spawnable 			= true
SWEP.AdminSpawnable 		= true
SWEP.HoldType 	        	= "ar2"
SWEP.Sound = Sound ("weapons/phaser/tng_phaser8_clean.wav")
SWEP.LastSoundRelease = 0
SWEP.RestartDelay = 1

list.Add("NPCUsableWeapons", {class = "Compression Phaser", title = SWEP.PrintName or ""});

SWEP.ViewModelFlip = false
SWEP.AmmoPerUse	= 1
SWEP.AmmoPerFullUse = 10
SWEP.AmmoPerVapUse = 100
SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.UseHands = true
SWEP.DrawAmmo	= false
SWEP.DrawCrosshair = true
SWEP.ViewModelBoneMods = {
	["ValveBiped.Gun"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}


SWEP.VElements = {
	["element_name"] = { type = "Model", model = "models/ef2weapons/sr/sr.mdl", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(-0.955, 0, -4.092), angle = Angle(-133.978, -176.933, -88.977), size = Vector(1.116, 1.116, 1.116), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["element_name"] = { type = "Model", model = "models/ef2weapons/sr/sr.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(14.272, 2.181, -2.182), angle = Angle(170.794, -101.25, 9.204), size = Vector(0.889, 0.889, 0.889), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}



SWEP.Primary.Sound 		= Sound("weapons/phaser/alt sounds/phaser_fire.wav")
SWEP.Primary.Recoil 		= 0
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 		= 0
SWEP.Primary.ClipSize 		= -1
SWEP.Primary.Delay 		= .5
SWEP.Primary.Automatic = true
SWEP.Primary.DefaultClip 	= 100
SWEP.Primary.MaxAmmo 	= 100;
SWEP.Primary.Ammo 		= "CombineCannon"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"



local Phaseredrags = {}
local Phaseruniquetimer1 = 0

function SWEP:GetSMode()
	
	local m = self.SMode
	
	if m == 1 then
		self.strSMode = "(Full)"
	elseif m == 2 then
	self.strSMode = "(Stun)"
	elseif m == 3 then
		self.strSMode = "(Rapid)"
	elseif m == 4 then
		self.strSMode = "(Vaporise)"		
	end
	
end

function SWEP:Precache()

util.PrecacheSound("weapons/phaser/alt sounds/phaser_fire.wav")
util.PrecacheSound("weapons/phaser/beep.wav")
util.PrecacheSound("weapons/phaser/tng_phaser8_clean.wav")
util.PrecacheSound("weapons/phaser/tng_phaser11_clean.wav")
util.PrecacheSound("weapons/phaser/tng_weapons_clean.wav")

end

function SWEP:Reload()	

	if self.SMode == 1 and CurTime() > self.changemode then
	self.changemode = CurTime() + .5
	self.Weapon:EmitSound("weapons/weps/swep_switchmode.wav")
	//self.Owner:PrintMessage(HUD_PRINTCENTER, "Stun")
	self.SMode = 2
	self:SetNetworkedInt( "XMode", 2 )
	elseif self.SMode == 2 and CurTime() > self.changemode then
	self.changemode = CurTime() + .5
	self.Weapon:EmitSound("weapons/weps/swep_switchmode.wav")
	//self.Owner:PrintMessage(HUD_PRINTCENTER, "Kill (Rapid)")
	self.SMode = 1
	self:SetNetworkedInt( "XMode", 1 )
	
	end

end



function SWEP:PrimaryAttack()

	if ( !self:CanPrimaryAttack() ) then return end

	local m = self.SMode

	if m == 1 then		
		self:Full()		
		
	elseif m == 2 then
		self:Vaporise()
	end
end

function SWEP:SecondaryAttack()
	-- We have already defined Zoomed as being false.
	if (!Zoomed) then -- The player is not zoomed in
 
		Zoomed = true -- Now he is
		self:SetNetworkedInt( "Zoom", 1 )
		if SERVER then
			self.Owner:SetFOV( 45, 0.3 ) -- SetFOV is serverside only
		end
	else -- If he is
 
		Zoomed = false -- We tell the SWEP that he is not
		self:SetNetworkedInt( "Zoom", 0 )
		if SERVER then
			self.Owner:SetFOV( 0, 0.3 ) -- Setting to 0 resets the FOV
		end
	end
end

function SWEP:TakePrimaryAmmo(num)

	// Doesn't use clips
	if ( self.Weapon:Clip1() <= 0 ) then
		if ( self:Ammo1() <= 0 ) then
			return
		end
		self.Owner:RemoveAmmo( num, self.Weapon:GetPrimaryAmmoType() )
		return
	end
	self.Weapon:SetClip1( self.Weapon:Clip1() - num )
end 




function SWEP:Full()

	if SERVER then
	if ( self.Weapon:Clip1() >= 1 ) then //check always if we have ammo
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.2 )
	
	if ( !self:CanPrimaryAttack() ) then return end
	local p = self.Owner
	local aimvector = self.Owner:GetAimVector();
	local t = util.QuickTrace(self.Owner:GetShootPos(),16*1024*aimvector,filter);
	
	
	local shootpos = p:GetShootPos();
	local e = ents.Create("phaser_pulse");
	e:Settings(aimvector, 3000, 50, {10,10});
	e:SetPos(shootpos);
	e:SetOwner(p);
	e.Owner = p;
	e:SetColor(Color(255,200,0,215))
	e.Damage = 200;
	e:Spawn();
	e:Activate();
	
	self.Weapon:EmitSound(self.Primary.Sound, 150)
	-- Emit the gun sound when you fire
	---self:RecoilPower()

	self:TakePrimaryAmmo(1)
	self.Primary.Damage = 0	
	
	if ((game.SinglePlayer() and SERVER) or CLIENT) then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())

	end
	else
	self.Weapon:EmitSound("console/denied01.wav")
	end
	end
end


function SWEP:Vaporise()

	if ( self.Weapon:Clip1() >= 5 ) then//check always if we have ammo
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.3 )
	
	if ( !self:CanPrimaryAttack() ) then return end

	self.Weapon:EmitSound("weapons/phaser_rifle/compfire2.wav", 150)
	-- Emit the gun sound when you fire
	--self:RecoilPower()	
	

	if SERVER then
	self:TakePrimaryAmmo(5)
	self.Primary.Damage = 0
		
	local p = self.Owner
	local aimvector = self.Owner:GetAimVector();
	local t = util.QuickTrace(self.Owner:GetShootPos(),16*1024*aimvector,filter);
	
	
	local shootpos = p:GetShootPos();
	local e = ents.Create("phaser_vaporise");
	e:Settings(aimvector, 3000, 300, {10,10});
	e:SetPos(shootpos);
	e:SetOwner(p);
	e.Owner = p;
	e:SetColor(Color(254,120,0,215))
	e.Damage = 0;
	e:Spawn();
	e:Activate();
	
	end
	
	if ((game.SinglePlayer() and SERVER) or CLIENT) then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())

	end
	
	
	else
	self.Weapon:EmitSound("console/denied01.wav")
	end
end





function SWEP:Think()
	local m = self.SMode
	local trace = {}
			trace.start = self.Owner:GetShootPos()
			trace.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 10^14
			trace.filter = self.Owner
		local tr = util.TraceLine(trace)
		self:SetNWEntity("TraceEnt",tr.Entity)
	if m == 3 then	
		if self.Owner:GetAmmoCount(self.Primary.Ammo)>=self.AmmoPerUse then
			if self.Owner:KeyDown (IN_ATTACK) and self.LastSoundRelease + self.RestartDelay < CurTime() then	
				self.SoundObject = CreateSound (self.Weapon, self.Sound)
					self.SoundObject:Play()
				self.SoundPlaying = true
		       	else
		            if self.SoundObject and self.SoundPlaying and self.Owner:GetAmmoCount(self.Primary.Ammo)>=self.AmmoPerUse then
		                self.SoundObject:FadeOut (0.5)            
		                self.SoundPlaying = false
		            end
			end
			self.LastFrame = CurTime()
       			self.Weapon:SetNWBool ("on", self.SoundPlaying)
		end
	end
	// autoreload primary ammo
	local time = CurTime();
	local reserve =  10 // how much ammo is needed, before it stops slowing reload.
	local offset = 1 // higher is slower.
	
	if((self.LastThink or 0) + offset < time) then
		self.LastThink = time;
		//keep ammo reserver
		local ammo = self.Owner:GetAmmoCount(self.Primary.Ammo);
		if(ammo > reserve) then
			self.Owner:RemoveAmmo(ammo-reserve,self.Primary.Ammo);
		end

		//primary ammo
		local ammo = self.Weapon:Clip1();
		local set = math.Clamp(ammo+1,0,self.Primary.MaxAmmo);
		self.Weapon:SetClip1(set);
	end

	self.Weapon:NextThink(CurTime() + 1)
	return true
	
end

if CLIENT then
surface.CreateFont("Target", {
			size = 50, --Size
			weight = 900, --Boldness
			antialias = true,
			shadow = false,
			font = "Arial"
		})
function SWEP:DrawHUD()
	local smode = "Full Kill"
	local fm = self:GetNetworkedInt("XMode")
	local ammo = self.Weapon:Clip1()
	local z = self:GetNetworkedInt("Zoom")
	
	local ammopercent = ammo/100 * 90
	local ammoPrcnt = (ammo * (90 / self.Primary.MaxAmmo)) //percentage, counting up !
	local ammoPrcnt2 = ((90 / self.Primary.MaxAmmo)*(ammo-(ammo*2))+90) //reversed percentage, counting down !
	
	
		
	local Target;
			Target = self:GetNWEntity("TraceEnt",0)
	local Text = "World"
	surface.SetTextColor(255,0,0,255)
	surface.SetFont( "Target" )
	if IsValid(Target) then
		if Target:IsPlayer() then
			Text = Target:Name()
		else
			Text = Target:GetClass()
		end
		local w,h = surface.GetTextSize( Text )
		surface.SetTextPos(ScrW()/2-w/2,ScrH()/2+70)
	else
		Text = ""
		local w,h = surface.GetTextSize( Text )
		surface.SetTextPos(ScrW()/2-w/2,ScrH()/2+100)
	end
	surface.DrawText ( Text )
		
	
		
	
	
	if ammo >= 70 then
		ammocol = Color(127,255,0,255)
	elseif ammo < 70 and ammo >= 35 then
		ammocol = Color(225,255,0,255)
	elseif ammo < 35 then
		ammocol = Color(255,0,0,255)
	end
	
	if fm == 1 then
		smode = "Full Kill"
	elseif fm == 2 then
		smode = "Vaporise"
	end
	//Target Hud
	if z == 1 then
		
	--surface.CreateFont("Trebuchet24" ,40, 250, false, false,"Target") 
	
	--draw.RoundedBox( 0, ScrW()/2, ScrH()/2, 4, 4, Color(255, 0, 0, 100) )
	end
	//Ammo Hud
	draw.RoundedBox( 0, ScrW()/1.155, ScrH()/1.150, 220, 30, Color(100, 100, 100, 255) ) //Function hud
	draw.RoundedBox( 0, ScrW()/1.155, ScrH()/1.105, 220, 65, Color(255, 92, 0, 255) )	//Ammo hud
	draw.RoundedBox( 0, ScrW()/1.1825, ScrH()/1.15, 35, 96, Color(0, 0, 0, 255) )	//Design hud
	draw.RoundedBox( 0, ScrW()/1.176, ScrH()/1.145, 20, ammoPrcnt, ammocol )	//Design hud
	//draw.WordBox(10,ScrW()/1.155, ScrH()/1.15,"Mode: "..smode,"Default", Color(100, 100, 100, 255), Color(255, 100, 100, 255))
	draw.SimpleText("Mode: "..smode,"Trebuchet24",ScrW()/1.145, ScrH()/1.147, Color(255, 255, 255, 255),0,0)
		
end
end

/********************************************************
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378
	   
	   
	DESCRIPTION:
		This script is meant for experienced scripters 
		that KNOW WHAT THEY ARE DOING. Don't come to me 
		with basic Lua questions.
		
		Just copy into your SWEP or SWEP base of choice
		and merge with your own code.
		
		The SWEP.VElements, SWEP.WElements and
		SWEP.ViewModelBoneMods tables are all optional
		and only have to be visible to the client.
********************************************************/

function SWEP:Initialize()
	
	self.SMode = 1
	self.NextUse = CurTime()
	self:SetNWInt("Mode",1)
	self.changemode = 0

	self:SetWeaponHoldType( self.HoldType )
	
	self.Weapon:SetClip1(100);


	if CLIENT then
	
		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		
	end

end

function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )

		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end


