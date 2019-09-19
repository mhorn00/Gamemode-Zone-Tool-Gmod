AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Name = "Zonetool Corner"
ENT.Spawnable = false
ENT.Author = "Sarcly & Intox"
ENT.Editable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
 
function ENT:Initialize()
    self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
    self:SetMoveType(MOVETYPE_FLY)
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    //self:EnableCustomCollisions(true)
    self:DrawShadow(false)
    self:PhysicsInit()
    if(SERVER) then
        self:Wake()
    end
end

function ENT:Draw()
    self:DrawModel()
    cam.Start3D()
        render.DrawWireframeSphere(self:GetPos(),10, 5, 5)
    cam.End3D()
end

function ENT:Think()
    -- if(SERVER && !IsValid(self:GetParent())) then
        -- self:Remove()
    -- end
end