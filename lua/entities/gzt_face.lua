AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Name = "Zonetool Face"
ENT.Spawnable = true
ENT.Author = "Sarcly & Intox"
ENT.Editable = true

function ENT:SetupDataTables()
    self:NetworkVar("Vector",0,"Min")
    self:NetworkVar("Vector",1,"Max")
    self:NetworkVar("String",0,"Uuid")
end


function ENT:Initialize()
	self:DrawShadow(false)
    self:SetCollisionGroup(COLLISION_GROUP_NONE)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:EnableCustomCollisions(true)
    self:SetCustomCollisionCheck(true)
    self:Setup(self:GetMin(),self:GetMax())
    self:CollisionRulesChanged()
    if SERVER then
        self.CollisionInfo = { 
            CollisionClassListShouldCollide = true,
            CollisionClassList = {"prop_physics"},
            CollisionTeamListShouldCollide = true,
            CollisionTeamList = {10}
        }
    end
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

function ShouldCollide(ent1, ent2)
    if (ent1:GetClass() != "gzt_face" && ent2:GetClass()!="gzt_face") or (ent1:GetClass()=="gzt_face" && ent2:GetClass() == "gzt_face")  then
        return
    end
    local face = ent1:GetClass()=="gzt_face" and ent1 or ent2
    local not_face = ent1:GetClass() == "gzt_face" and ent2 or ent1
    if !face.CollisionInfo then return false end
    if !not_face:IsPlayer() then
        for k,v in pairs(face.CollisionInfo.CollisionClassList) do -- check to see if entity is in the lsit
            if not_face:GetClass()==v then
                return face.CollisionInfo.CollisionClassListShouldCollide
            end
        end
        return !face.CollisionInfo.CollisionClassListShouldCollide -- do the OPPOSITE of whatever is in the list does
    else
        for k,v in pairs(face.CollisionInfo.CollisionTeamList) do
            if not_face:Team()==v then
                return face.CollisionInfo.CollisionTeamListShouldCollide
            end
        end
    end
    return false
end
hook.Add("ShouldCollide", "gzt_face_shouldcolide", ShouldCollide)