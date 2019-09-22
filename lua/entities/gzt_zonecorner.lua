AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Name = "Zonetool Corner"
ENT.Spawnable = false
ENT.Author = "Sarcly & Intox"
ENT.Editable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
 
function ENT:Initialize()
    self:SetModel("")
    self:SetMoveType(MOVETYPE_FLY)
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self:EnableCustomCollisions(true)
    self:DrawShadow(false)
    if(SERVER) then
        //self:Wake()
    end
end

-- function ENT:PhysicsCollide(colData, collider)
--     if(colData.HitEntity) then
        
--     end
-- end

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Size")
end

function ENT:Setup(size)
    local size = math.max(math.min(size/8,150),10)
    self:PhysicsInitBox(self:GetPos()-Vector(1,1,1)*size, self:GetPos()+Vector(1,1,1)*size)
    self:SetSize(size)
end

function ENT:Think()        
    self:SetCollisionBounds(Vector(1,1,1)*-self:GetSize(), Vector(1,1,1)*self:GetSize())
end

function ENT:Draw()
    local cb1 ,cb2 = self:GetCollisionBounds()
    cam.Start3D()
        render.DrawWireframeBox(self:GetPos(), self:GetAngles(), cb1, cb2, self:GetColor())
    cam.End3D()
end