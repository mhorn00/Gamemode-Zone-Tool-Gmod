AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Name = "Zonetool Face"
ENT.Spawnable = true
ENT.Author = "Sarcly & Intox"
ENT.Editable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT


function ENT:SetupDataTables()
    self:NetworkVar("Float",0,"Width")
	self:NetworkVar("Float",1,"Height")
    self:NetworkVar("Vector",0, "Min")
    self:NetworkVar("Vector",1,"Max")
end

function ENT:Spawn()

end

function ENT:Initialize()
    self:SetSolid(SOLID_OBB)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_NONE)
    self:SetCustomCollisionCheck(true)
end

function ENT:Setup(min,max)
    self:SetMin(min)
    self:SetMax(max)
    local verts = {}
	for i = 0, 7 do
		local x = bit.band(i, 1) == 0 and min.x or max.x
		local y = bit.band(i, 2) == 0 and min.y or max.y
		local z = bit.band(i, 4) == 0 and min.z or max.z
        table.insert(verts, Vector(x,y,z))
    end
    --PrintTable(verts)
    --print('===')
    self:PhysicsInitConvex(verts)
    --for some reason this is being placed at -24000 or smthin
    local phys = self:GetPhysicsObject()
    if(IsValid(phys)) then phys:Wake() end
    -- phys:EnableMotion(false)
end

function ENT:Think()
end

function shouldCollide(ent1, ent2)
    print(ent1,ent2)
    return false
end
hook.Add("ShouldCollide", "gzt_test_shouldcollide", shouldCollide)

local hitPos = nil

function ENT:PhysicsCollide(colData, collider)
    PrintTable(colData)
    print("!!!!!!!!!!!!!!!")
    hitPos = colData.hitPos
end

function ENT:Think()
    --print(self:GetPos())
    if CLIENT then
        self:SetRenderBounds(self:GetMin(), self:GetMax())
    end
end

function ENT:Draw()
    cam.Start3D()
        local c1, c2 = self:GetCollisionBounds()
        local r1, r2 = self:GetRenderBounds()
        render.DrawWireframeBox(self:GetPos(), Angle(), c1+Vector(5,5,5), c2, Color(255,255,255,255))
        render.DrawWireframeBox(self:GetPos(), Angle(), r1, r2, Color(255,0,0,255))
        render.DrawWireframeSphere(self:GetPos(), 5, 5, 5, Color(0,255,0,255))
    cam.End3D()
end