AddCSLuaFile()
ENT.Type="anim"
ENT.Base="base_anim"
ENT.Spawnable = true
ENT.Category = "Other"
ENT.Author = "Sarcly & Intox"

function ENT:Initialize()
	self:SetModel("models/props_lab/blastdoor001a.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetSolid(SOLID_VPHYSICS)
end

function ENT:Think()

end