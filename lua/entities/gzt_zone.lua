AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Name = "Zonetool Zone"
ENT.Spawnable = false
ENT.Author = "Sarcly & Intox"
ENT.Editable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.FACE_ANGLES = {
	left = {"left", Angle(0, -180, 90), Angle(0, 0, 90)}, 
	foward = {"foward", Angle(0, 90, 90), Angle(0, -90, 90)}, 
	down = {"down", Angle(0, 90, 0), Angle(0, -90, 180)},
	right = {"right", Angle(0, 0, 90), Angle(180, 0, -90)}, 
	back = {"back", Angle(0, -90, 90), Angle(0, 90, 90)}, 
	up = {"up", Angle(180, -90, 0), Angle(180, -90, 180)}
}
ENT.FACE_ENUM = {
	ENT.FACE_ANGLES.left,   
	ENT.FACE_ANGLES.foward,
	ENT.FACE_ANGLES.down,
	ENT.FACE_ANGLES.right,
	ENT.FACE_ANGLES.back,
	ENT.FACE_ANGLES.up,
}

function ENT:SetupDataTables()
	self:NetworkVar("Vector",0,"MinBound")
	self:NetworkVar("Vector",1,"MaxBound")
	self:NetworkVar("String",0,"Type")
end

function ENT:Setup(min,max)
	vec1 = Vector(min)
	vec2 = Vector(max)
	OrderVectors(vec1,vec2)
	self:SetPos(Lerp(0.5,vec1,vec2))
	self:SetMinBound(vec1)
	self:SetMaxBound(vec2)
end


function ENT:Think()
	if CLIENT then
		if(self:GetMinBound() && self:GetMaxBound()) then
			self:SetRenderOrigin(Lerp(.5,self:GetMinBound(),self:GetMaxBound()))
			self:SetRenderBounds(self:GetMinBound()-self:GetPos(), self:GetMaxBound()-self:GetPos())
		end
	end
end

function ENT:Initialize()
	self:SetModel("")
	self:DrawShadow(false)
	self:SetMoveType(MOVETYPE_NONE)
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self:EnableCustomCollisions(true)
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
end

function ENT:Draw()
	print("FSDHJK")
	cam.Start3D()
		local rb1,rb2 = self:GetRenderBounds()
		render.DrawWireframeBox(Vector(), self:GetAngles(), self:GetMinBound(), self:GetMaxBound(), Color(255,0,0,255), false)
	cam.End3D()
	local center = Lerp(0.5, self:GetMinBound(), self:GetMaxBound())
	local diff_vector = self:GetMaxBound() - self:GetMinBound()
	local smallest_side = math.min(diff_vector.x, diff_vector.y, diff_vector.z)
	for k,v in pairs(self.FACE_ENUM) do
		local vec = Vector(
			k%3==2 and diff_vector.x/2*(math.floor(k/3)==1 and -1 or 1) or 0, // x
			k%3==1 and diff_vector.y/2*(math.floor(k/3)==1 and -1 or 1) or 0, // y
			k%3==0 and diff_vector.z/2*(math.floor(k/3)==1 and -1 or 1) or 0 // z
		)
		local cornerVector =  Vector(k%3!=2 and diff_vector.x/2 or 0, k%3!=1 and diff_vector.y/2 or 0, k%3!=0 and diff_vector.z/2 or 0)
		// for the component axis vector to get the corner we need the other two components * .5 added onto it respectively
		local c1 = center+vec - cornerVector
		local c2 = center+vec - -1*cornerVector
		local color = Color(bit.band(k, 4) * 255, bit.band(k, 2) * 255, bit.band(k, 1) * 255, 50)
		cam.Start3D()
			render.SetColorMaterial(color)
			render.DrawBox(Vector(), self:GetAngles(), c1, c2, color)
		cam.End3D()
		cam.Start3D2D(center+vec*.995, v[2], 1)
			surface.SetMaterial(Material("materials/face_" .. v[1] .. ".png"))
			surface.SetDrawColor(0, 0, 0, 200)
			surface.DrawTexturedRect(-smallest_side/2, -smallest_side/2, smallest_side, smallest_side)
		cam.End3D2D()
		cam.Start3D2D(center+vec, v[3], 1)
			surface.SetMaterial(Material("materials/face_" .. v[1] .. ".png"))
			surface.SetDrawColor(0, 0, 0, 200)
			surface.DrawTexturedRect(-smallest_side/2, -smallest_side/2, smallest_side, smallest_side)
		cam.End3D2D()
	end
end