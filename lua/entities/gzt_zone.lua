AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Name = "Zonetool Zone"
ENT.Spawnable = true
ENT.Category = "Other"
ENT.Author = "Sarcly & Intox"
ENT.Editable = true

function ENT:SpawnFunction(ply, tr, ClassName)
	if (not tr.Hit) then return end
	local ent = ents.Create(ClassName)
	ent:SetPos(tr.HitPos + tr.HitNormal * 20)
	ent:Spawn()
	ent:Activate()
    ent:SetMinBound(Vector(-10,-10,-10))
    ent:SetMaxBound(Vector(10,10,10))
    //ent:RebuildPhysics()
	return ent
end

function ENT:SetupDataTables()
	self:NetworkVar("Vector", 0, "MinBound", {
		KeyName = "minbound",
		Edit = {
			type = "Vector",
			order = 1
		}
	})

	self:NetworkVar("Vector", 1, "MaxBound", {
		KeyName = "maxbound",
		Edit = {
			type = "Vector",
			order = 2
		}
	})
    
	self:NetworkVarNotify("MinBound", self.OnBoundsChanged)
	self:NetworkVarNotify("MaxBound", self.OnBoundsChanged)

	if (SERVER) then
		self:SetMinBound(Vector(-10, -10, -10))
		self:SetMaxBound(Vector(10, 10, 10))
		self:SetColor(Vector(255, 0, 0))
	end
end

function ENT:OnBoundsChanged()
	self:RebuildPhysics()
end

function ENT:Initialize()
	self:SetModel("")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:DrawShadow(false)
end

function ENT:RebuildPhysics(MinBound, MaxBound)
	if SERVER then
		MinBound = MinBound or self:GetMinBound()
		MaxBound = MaxBound or self:GetMaxBound()
        OrderVectors(MinBound,MaxBound)
		self.PhysCollide = CreatePhysCollideBox(MinBound, MaxBound)
		self:SetCollisionBounds(MinBound, MaxBound)
		self:SetGravity(1)
		self:PhysicsInitBox(MinBound, MaxBound)
		self:SetSolid(SOLID_BBOX)
		--self:EnableCustomCollisions(true)
		self:DrawShadow(false)
	end
end

-- function ShouldBoxCollide(ent1, ent2)
-- 	if (ent1 == "gzt_zone" or ent2 == "gzt_zone") then return false end
-- end

-- hook.Add("ShouldCollide", "gzt_boxnocollide", ShouldBoxCollide)

function EditableBoxPhysgunPickup(ply, entity)
	if (entity.ClassName == "gzt_zone") then
		return false
	end
end

//hook.Add("PhysgunPickup", "gzt_nopickup", EditableBoxPhysgunPickup)

function ENT:Draw()
	local vec1, vec2 = self:GetCollisionBounds()
    cam.Start3D()
	render.DrawWireframeBox(self:GetPos(), self:GetAngles(), self:GetMinBound(), self:GetMaxBound(), self:GetColor())
	render.DrawWireframeBox(self:GetPos(), self:GetAngles(), vec1, vec2, Color(0,255,0))
    cam.End3D()
end