AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Name = "Zonetool Zone"
ENT.Spawnable = false
ENT.Author = "Sarcly & Intox"
ENT.Editable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.FACE_ANGLES = {
	foward = {name="foward",mat=Material("materials/face_foward.png"), letter_out=90, letter_in=270, face_out=Angle(90,0,0),face_in=Angle(-90,0,0)},
	left = {name="left",mat=Material("materials/face_left.png"), letter_out=270, letter_in=90, face_out=Angle(-90, 0, -90),face_in=Angle(90,0,90)},
	up = {name="up",mat=Material("materials/face_up.png"), letter_out=270, letter_in=90, face_out=Angle(0,0,0),face_in=Angle(180,0,0)},
	back = {name="back",mat=Material("materials/face_back.png"), letter_out=270, letter_in=90, face_out=Angle(-90,0,0),face_in=Angle(90,0,0)},
	right = {name="right",mat=Material("materials/face_right.png"), letter_out=270, letter_in=90, face_out=Angle(-90,0,90),face_in=Angle(90,0,-90)},
	down = {name="down",mat=Material("materials/face_down.png"), letter_out=270, letter_in=270, face_out=Angle(-180,0,0),face_in=Angle(0,0,0)},
}

ENT.FACE_ENUM = {
	ENT.FACE_ANGLES.foward,
	ENT.FACE_ANGLES.left,
	ENT.FACE_ANGLES.up,
	ENT.FACE_ANGLES.back,  
	ENT.FACE_ANGLES.right,
	ENT.FACE_ANGLES.down,
}
ENT.Faces = {}

function ENT:SetupDataTables()
	self:NetworkVar("Vector",0,"MinBound")
	self:NetworkVar("Vector",1,"MaxBound")
	self:NetworkVar("Vector",2,"Position")
	self:NetworkVar("String",0,"Catagory")
	self:NetworkVar("Bool",0,"DrawFaces")
	self:NetworkVar("String",0,"Uuid")
end

function ENT:Initialize()
	self:SetModel("models/props_c17/oildrum001.mdl")
	self:DrawShadow(false)
	self:SetMoveType(MOVETYPE_NONE)
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self:EnableCustomCollisions(true)
end

function ENT:Setup(center,min,max,angle,uuid)
	vec1 = Vector(min)
	vec2 = Vector(max)
	OrderVectors(vec1,vec2)
	self.gzt_uuid = uuid
	self:SetUuid(uuid)
	self:SetPosition(center)
	self:SetPos(center)
	self:SetMinBound(vec1)
	self:SetMaxBound(vec2)
	self:SetDrawFaces(self:GetDrawFaces())
	self:SetAngles(angle)
	self:SetupFaces()
end

function ENT:SetupFaces()
	local THICKNESS = 1
	local dist_vec = self:GetMaxBound()
	local pos = self:GetPos()
	local angles = self:GetAngles()
	if self.Faces then
		for k,v in pairs(self.Faces) do
			v:Remove()
		end
	end
	self.Faces = {}
	for i,face in pairs(self.FACE_ENUM) do 
		local face_offset = Vector(
			i%3==1 and dist_vec.x or 0,
			i%3==2 and dist_vec.y or 0,
			i%3==0 and dist_vec.z or 0)
		if math.floor((i-1)/3)>=1 then
			face_offset = face_offset*-1
		end
		self.Faces[i] = ents.Create("gzt_face")
		local size_vector_3d = dist_vec - (face_offset*((i/3)>1 and -1 or 1))
		local min = Vector(-size_vector_3d)
		local max = Vector(size_vector_3d)
		local verts = {}
		if size_vector_3d.x==0 then
			min.x = -THICKNESS
			max.x = THICKNESS
		elseif size_vector_3d.y==0 then
			min.y = -THICKNESS
			max.y = THICKNESS
		else
			min.z = -THICKNESS
			max.z = THICKNESS
		end
		face_offset_aa = Vector(face_offset) --face_offset_axis_aligned
		face_offset:Rotate(angles)
		self.Faces[i]:SetPos(pos+face_offset)
		self.Faces[i]:SetAngles(angles)
		self.Faces[i]:SetMin(min)
		self.Faces[i]:SetMax(max)
		self.Faces[i]:Spawn()
	end
end

function ENT:Think()
	if CLIENT then
		self:SetRenderBounds(self:GetMinBound(),self:GetMaxBound())
	end
end

function ENT:TestCollision(startpos, delta, isbox, extents, mask)
	return
end

function PhysgunPickup(ply,ent)
    if ent:GetClass() == "gzt_face" || ent:GetClass() == "gzt_zone" then
        return false
    end 
    return true
end
hook.Add("PhysgunPickup", "gzt_pickup", PhysgunPickup)

function ENT:ToggleFaces()
	if self:GetDrawFaces() then
		self:SetDrawFaces(false)
	else
		self:SetDrawFaces(true)
	end
end


local color_mat = Material("color")
function ENT:Draw()
	cam.Start3D()
		if IsValid(LocalPlayer():GetActiveWeapon()) && LocalPlayer():GetActiveWeapon() && LocalPlayer():GetActiveWeapon():GetClass()=="gzt_zonetool" && LocalPlayer():GetActiveWeapon().gzt_CurrentZoneObj.gzt_uuid == self:GetUuid() then
			render.DrawWireframeBox(self:GetPos(), self:GetAngles(), self:GetMinBound(), self:GetMaxBound(), Color(150,0,0,255), true)
			if input.IsKeyDown(KEY_G) then
				local tr = LocalPlayer():GetEyeTrace()
				local pos = tr.HitPos
				render.DrawLine(self:GetPos(), pos, Color(0,255,255), true)
			end
		else
			render.DrawWireframeBox(self:GetPos(), self:GetAngles(), self:GetMinBound(), self:GetMaxBound(), Color(0,0,0,255), false)	
		end
	cam.End3D()
	if self:GetDrawFaces() then
		local center = self:GetPos()
		local angles = self:GetAngles()
		local dist_vec = self:GetMaxBound()
		local smallest_side = math.min(dist_vec.x, dist_vec.y, dist_vec.z)*2
		for index,face in pairs(self.FACE_ENUM) do
			local color = Color(
				index%3==1 and (math.floor((index-1)/3)==1 and 0 or 255) or (math.floor((index-1)/3)==1 and 255 or 0),
				index%3==2 and (math.floor((index-1)/3)==1 and 0 or 255) or (math.floor((index-1)/3)==1 and 255 or 0),
				index%3==0 and (math.floor((index-1)/3)==1 and 0 or 255) or (math.floor((index-1)/3)==1 and 255 or 0),
				15
			)
			local face_offset = Vector(
				index%3==1 and dist_vec.x or 0,
				index%3==2 and dist_vec.y or 0,
				index%3==0 and dist_vec.z or 0
			)
			if math.floor((index-1)/3)>=1 then
				face_offset = face_offset*-1
			end
			face_offset_aa = Vector(face_offset) --face_offset_axis_aligned
			face_offset:Rotate(angles)
			local size_vector_3d = dist_vec-(face_offset_aa*((index/3)>1 and -1 or 1))
			local verts = {}
			if size_vector_3d.x==0 then
				verts = {
					{x=size_vector_3d.z,y=size_vector_3d.y},
					{x=-size_vector_3d.z,y=size_vector_3d.y},
					{x=-size_vector_3d.z,y=-size_vector_3d.y},
					{x=size_vector_3d.z,y=-size_vector_3d.y},
				}
			elseif size_vector_3d.y==0 then
				verts = {
					{x=size_vector_3d.z,y=size_vector_3d.x},
					{x=-size_vector_3d.z,y=size_vector_3d.x},
					{x=-size_vector_3d.z,y=-size_vector_3d.x},
					{x=size_vector_3d.z,y=-size_vector_3d.x},
				}
			else
				verts = {
					{x=size_vector_3d.x,y=size_vector_3d.y},
					{x=-size_vector_3d.x,y=size_vector_3d.y},
					{x=-size_vector_3d.x,y=-size_vector_3d.y},
					{x=size_vector_3d.x,y=-size_vector_3d.y},
				}
			end
			cam.Start3D2D(center+face_offset, angles+face.face_out, 1)
				surface.SetMaterial(color_mat)
				surface.SetDrawColor(color)
				surface.DrawPoly(verts)
			cam.End3D2D()
			cam.Start3D2D(center+face_offset, angles+face.face_in, 1)
				surface.SetMaterial(color_mat)
				surface.SetDrawColor(color)
				surface.DrawPoly(verts)
			cam.End3D2D()
			cam.Start3D2D(center+face_offset, angles+face.face_out, 1)
				surface.SetMaterial(face.mat)
				surface.SetDrawColor(0, 0, 0, 200)
				surface.DrawTexturedRectRotated(0,0, smallest_side, smallest_side,face.letter_out)
			cam.End3D2D()
			cam.Start3D2D(center+face_offset, angles+face.face_in, 1)
				surface.SetMaterial(face.mat)
				surface.SetDrawColor(0, 0, 0, 200)
				surface.DrawTexturedRectRotated(0,0, smallest_side, smallest_side,face.letter_in)
			cam.End3D2D()
			cam.Start3D()
				render.DrawLine(center,face_offset+center,color,true)
			cam.End3D()
		end
	end
end

function ENT:OnRemove()
	if(SERVER && self.CornerEnts &&  #self.CornerEnts!=0) then
		for k,v in pairs(self.CornerEnts) do
			v:Remove()
		end
	end
end