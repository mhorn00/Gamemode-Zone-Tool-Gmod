AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Name = "Zonetool Face"
ENT.Spawnable = true
ENT.Author = "Sarcly & Intox"
ENT.Editable = true

function ENT:SetupDataTables()
    self:NetworkVar("Vector",0, "Min")
    self:NetworkVar("Vector",1,"Max")
end


function ENT:Initialize()
	--self:SetModel("models/props_c17/oildrum001.mdl")
	self:DrawShadow(false)
    self:SetCollisionGroup(COLLISION_GROUP_NONE)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:EnableCustomCollisions(true)
    self:SetCustomCollisionCheck(true)
    self:Setup(self:GetMin(),self:GetMax())
end

function ENT:Setup(min,max)
    local verts = {}
	for i = 0, 7 do
		local x = bit.band(i, 1) == 0 and min.x or max.x
		local y = bit.band(i, 2) == 0 and min.y or max.y
		local z = bit.band(i, 4) == 0 and min.z or max.z
        table.insert(verts, Vector(x,y,z))
    end
    self:SetCollisionBounds(min,max)
    self:PhysicsInitConvex(verts)
    if IsValid(self:GetPhysicsObject()) then
        self:GetPhysicsObject():EnableGravity(false)
        self:GetPhysicsObject():EnableMotion(false)
        self:PhysWake()
    end
end

function ENT:Think()
    if CLIENT then
        self:SetRenderBounds(self:GetMin(), self:GetMax())
    end
end

function ENT:Draw()
    cam.Start3D()
        render.DrawWireframeBox(self:GetPos(), self:GetAngles(), self:GetMin(), self:GetMax(), Color(255,0,0,255))
        render.DrawWireframeSphere(self:GetPos(), 5, 10, 10, Color(0,255,0,255))
    cam.End3D()
end