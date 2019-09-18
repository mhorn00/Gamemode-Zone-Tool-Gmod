AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Name = "Zonetool Zone"
ENT.Spawnable = true
ENT.Category = "Other"
ENT.Author = "Sarcly & Intox"
ENT.Editable = true
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
	self:NetworkVar("Vector",0,"MinBound")
	self:NetworkVar("Vector",1,"MaxBound")
	self:NetworkVar("String",0,"Type")

	if(SERVER) then
		self:NetworkVarNotify("MinBound", self.OnMinBoundChanged)
		self:NetworkVarNotify("MaxBound", self.OnMaxBoundChanged)
	end
end

function ENT:OnMinBoundChanged(name,old, new)
	if CLIENT then
		if(self:GetMinBound() && self:GetMaxBound()) then
			self:SetRenderBoundsWS(new, self:GetMaxBound())
		end	
	end
end

function ENT:OnMaxBoundChanged(name,old, new)
	if CLIENT then
		if(self:GetMinBound() && self:GetMaxBound()) then
			self:SetRenderBoundsWS(self:GetMinBound(), new)
		end
	end
end

function ENT:Think()
	if(CLIENT) then
		if(self:GetMinBound() and self:GetMaxBound()) then
			self:SetRenderBoundsWS(self:GetMinBound(), self:GetMaxBound())
		end
	end
end

function ENT:SpawnFunction(ply, tr, ClassName)
	if SERVER then
		local box = ents.Create(ClassName)
		box:SetMinBound(tr.HitNormal*10 + Vector(-10,-10,-10))
		box:SetMaxBound(tr.HitNormal*10 + Vector(10,10,10))

	end

end

function ENT:Initialize()
	self:SetModel("")
	self:SetMoveType(MOVETYPE_NONE)
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self:EnableCustomCollisions(true)
end

function ENT:DrawTranslucent()
	cam.Start3D()
		local rb1,rb2 = self:GetRenderBounds()
		render.DrawWireframeBox(Vector(), self:GetAngles(), self:GetMinBound(), self:GetMaxBound(), self:GetColor(), false)
	cam.End3D()
end