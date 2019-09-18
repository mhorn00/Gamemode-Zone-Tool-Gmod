AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Name = "Zonetool Zone"
ENT.Spawnable = true
ENT.Category = "Other"
ENT.Author = "Sarcly & Intox"
ENT.Editable = true
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.FACE_ANGLES = {
	left = {"left", Angle(0, -180, 90), Angle(0, 0, 90)}, 
	foward = {"foward", Angle(0, 90, 90), Angle(0, -90, 90)}, 
	up = {"up", Angle(0, 90, 0), Angle(0, -90, 180)},
	right = {"right", Angle(0, 0, 90), Angle(180, 0, -90)}, 
	back = {"back", Angle(0, -90, 90), Angle(0, 90, 90)}, 
	down = {"down", Angle(180, -90, 0), Angle(180, -90, 180)}
}
ENT.FACE_ENUM = {
	ENT.FACE_ANGLES.left,   
	ENT.FACE_ANGLES.foward,
	ENT.FACE_ANGLES.up,
	ENT.FACE_ANGLES.right,
	ENT.FACE_ANGLES.back,
	ENT.FACE_ANGLES.down,
}

function ENT:SetupDataTables()
	self:NetworkVar("Vector",0,"MinBound")
	self:NetworkVar("Vector",1,"MaxBound")
	self:NetworkVar("String",0,"Type")

	self:NetworkVarNotify("MinBound", self.OnMinBoundChanged)
	self:NetworkVarNotify("MaxBound", self.OnMaxBoundChanged)
	
end

function ENT:OnMinBoundChanged(name,old, new)
	if(CLIENT) then
		self:SetRenderBoundsWS(new, self:GetMaxBound())
	end
end

function ENT:Setup(min,max)
	vec1 = Vector(min)
	vec2 = Vector(max)
	OrderVectors(vec1,vec2)
	self:SetMinBound(vec1)
	self:SetMaxBound(vec2)
end

function ENT:OnMaxBoundChanged(name,old, new)
	if(self:GetMinBound() && self:GetMaxBound() && CLIENT) then
		self:SetRenderBoundsWS(new, self:GetMinBound())
	end	
end

function ENT:Think()
	if CLIENT then
		if(self:GetMinBound() && self:GetMaxBound()) then
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
	local i = 0
	local center = Lerp(0.5, self:GetMinBound(), self:GetMaxBound())
	local diff_vector = self:GetMaxBound() - self:GetMinBound()
	local smallest_side = math.min(diff_vector.x, diff_vector.y, diff_vector.z)
	for k,v in pairs(self.FACE_ENUM) do
		//Vector(i%3==2?1*(math.floor(i/3)==1?-1:1):0,i%3==1?1*(math.floor(i/3)==1?-1:1):0,i%3==0?1*(math.floor(i/3)==1?-1:1):0)
		local vec = Vector(
			k%3==2 and diff_vector.x/2*(math.floor(i/3)==1 and -1 or 1) or 0, // x
			k%3==1 and diff_vector.y/2*(math.floor(i/3)==1 and -1 or 1) or 0, // y
			k%3==0 and diff_vector.z/2*(math.floor(i/3)==1 and -1 or 1) or 0 // z
		)
		local color = Color(bit.band(k, 4) * 255, bit.band(k, 2) * 255, bit.band(k, 1) * 255, 255)
		vec = center+vec
		cam.Start3D()
			render.DrawWireframeSphere(vec,5, 5, 5, color)
		cam.End3D()
		cam.Start3D2D(vec, v[2], 1)
			surface.SetMaterial(Material("materials/face_" .. v[1] .. ".png"))
			surface.SetDrawColor(0, 0, 0, 200)
			surface.DrawTexturedRect(-smallest_side/2, -smallest_side/2, smallest_side, smallest_side)
		cam.End3D2D()
		cam.Start3D2D(vec, v[3], 1)
			surface.SetMaterial(Material("materials/face_" .. v[1] .. ".png"))
			surface.SetDrawColor(0, 0, 0, 200)
			surface.DrawTexturedRect(-smallest_side/2, -smallest_side/2, smallest_side, smallest_side)
		cam.End3D2D()
		i = i + 1
	end
end