AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()   --Standard Stuff
	self.Entity:PhysicsInit( SOLID_VPHYSICS )  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )      
	local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:SetMass(100000)
		end
	
	self.NextUse = CurTime()
	if WireLib then
		self.Outputs = Wire_CreateOutputs( self.Entity, { "Ship:ENTITY", "Ship Health", "Progress" })
	end
end

function ENT:Use(ply)--What happens when we press use on the dock?
		if self.NextUse < CurTime() then--This is to avoid that we open multiple windows
		self.NextUse = CurTime()+1;
		umsg.Start("Drydock",ply)--Ply = Player who is preesing "use"
	    umsg.Entity(self.Entity);
	    umsg.End()
		self.Player = ply;
		end
end

function ENT:Think()
	--We dont need to "think"
end

function ENT:Create(Class, Name)--For later use
	local pos = self:GetPos()
	local Ship = ents.Create(Class)
		Ship:SetPos()
		Ship:SetAngle(self:GetAngles())
		Ship:SetName(Name)


end

util.AddNetworkString("Drydock")--This happens when we click the create button
net.Receive("Drydock",function(len,ply)
	local self = net.ReadEntity()--We
	local NetClass = net.ReadString()--What type do we want to create?
	local ShipName = net.ReadString()--The Name
	local RealClass 
	if NetClass == "Shuttle Type 11" then--Converting the Net Name into ENTITY name
		RealClass = "shuttle_11"
	elseif NetClass == "Shuttle Type 9" then
		RealClass = "shuttle_9"
	elseif NetClass == "Shuttle Type 6" then
		RealClass = "shuttle_6"
	end
	
	local pos = self:GetPos()--The position to spawn the ship
	local Ship = ents.Create(RealClass)-- Here we create our ship
		Ship:SetPos(self.Entity:GetPos()+self.Entity:GetUp()*50)--Set the position
		Ship:Spawn()--Spawn it!
		--Ship:SetAngle(self.Entity:GetAngles())
		Ship:SetVar("Owner",self.Player);--Who is the owner? We!
		Ship.Owner = self.Player;--Needs to be done two times. Why? I have no idea-
		Ship:SetName(ShipName)--Set the Ship name
		ply:AddCount("Drydock Spawned Ship", Ship)--Register the new entity
		ply:AddCleanup ( "Drydock Spawned Ship", Ship )--We want to make it to be removable
		undo.Create( "Drydock Spawned Ship" )--We want to make it to be removable
			undo.AddEntity( Ship )
			undo.SetPlayer( ply )
		undo.Finish()
end);