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

ENT.Corners = {}
ENT.CornerEnts = {}

function ENT:SetupDataTables()
	self:NetworkVar("Vector",0,"MinBound")
	self:NetworkVar("Vector",1,"MaxBound")
	self:NetworkVar("Vector",2,"Position")
	self:NetworkVar("String",0,"Catagory")
	self:NetworkVar("Bool",0,"DrawFaces")
	self:NetworkVar("String",0,"Uuid")
end

function ENT:Resize(changedcorner)
	if CLIENT then return end
	local opposite = self.CornerEnts[(7-changedcorner:GetIndex())+1]
	local vec1 = opposite:GetPos()
	local vec2 = changedcorner:GetPos()
	OrderVectors(vec1,vec2)
	self:SetPos(Lerp(0.5,vec1,vec2))
	self:SetMinBound(vec1)
	self:SetMaxBound(vec2)
end

function ENT:BuildCorners()
	local vec1 = self:GetMinBound()
	local vec2 = self:GetMaxBound()
	self:PhysicsInitBox(vec1-self:GetPos(),vec2-self:GetPos())
	local diff_vector = self:GetMaxBound() - self:GetMinBound()
	local smallest_side = math.min(diff_vector.x, diff_vector.y, diff_vector.z)
	for i = 0, 7 do
		self.CornerEnts[i+1]:Setup(smallest_side, i)
		local x = bit.band(i, 1) == 0 and vec1.x or vec2.x
		local y = bit.band(i, 2) == 0 and vec1.y or vec2.y
		local z = bit.band(i, 4) == 0 and vec1.z or vec2.z
		self.Corners[i + 1] = Vector(x, y, z)
		self.CornerEnts[i + 1]:SetPos(self.Corners[i + 1])
		if(i==0 or i==7) then
			self.CornerEnts[i+1]:SetColor(Color(255,0,0))
		end
	end
end

function ENT:Setup(center,min,max,angle,uuid)
	if(self.CornerEnts && #self.CornerEnts != 0) then
		for k,v in pairs(self.CornerEnts) do
			if(IsValid(v)) then
				v:Remove()
			end
		end
	end
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
	self:PhysicsInitBox(vec1,vec2)
	local diff_vector = self:GetMaxBound() - self:GetMinBound()
	local smallest_side = math.min(diff_vector.x, diff_vector.y, diff_vector.z)
	// TODO: Change to local coords
	-- for i = 0, 7 do
	-- 	local maxBound = self:GetMaxBound()
	-- 	local minBound = self:GetMinBound()
	-- 	local x = bit.band(i, 1) == 0 and maxBound.x or minBound.x
	-- 	local y = bit.band(i, 2) == 0 and maxBound.y or minBound.y
	-- 	local z = bit.band(i, 4) == 0 and maxBound.z or minBound.z
	-- 	self.Corners[i + 1] = Vector(x, y, z)
	-- 	self.CornerEnts[i + 1] = ents.Create("gzt_zonecorner")
	-- 	self.CornerEnts[i+1]:Setup(smallest_side, i)
	-- 	self.CornerEnts[i+1]:SetOwner(self)
	-- 	self.CornerEnts[i+1]:Spawn()
	-- 	self.CornerEnts[i + 1]:SetPos(self.Corners[i + 1])
	-- 	if(i==0 or i==7) then
	-- 		self.CornerEnts[i+1]:SetColor(Color(255,0,0))
	-- 	end
	-- end
end

function ENT:Think()
	if CLIENT then
		self:SetRenderBounds(self:GetMinBound(),self:GetMaxBound())
	end
end

function ENT:Initialize()
	self:SetModel("models/props_c17/oildrum001.mdl")
	self:DrawShadow(false)
	self:SetMoveType(MOVETYPE_NONE)
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self:EnableCustomCollisions(true)
end

function ENT:TestCollision(startpos, delta, isbox, extents, mask)
	return
end

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
		if(LocalPlayer():GetActiveWeapon() && LocalPlayer():GetActiveWeapon():GetClass()=="gzt_zonetool" && LocalPlayer():GetActiveWeapon().gzt_CurrentZoneObj.gzt_uuid == self:GetUuid()) then
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
			if index!=1 then
				-- continue
			end
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
			face_offset_aa = Vector(face_offset)
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
		-- local center = self:GetPos()
		-- local diff_vector = self:GetMaxBound()
		-- local smallest_side = math.min(diff_vector.x, diff_vector.y, diff_vector.z)*2
		-- local curAng = self:GetAngles()
		-- for k,v in pairs(self.FACE_ENUM) do
		-- 	if(k%3!=0) then
		-- 		continue
		-- 	end
		-- 	local vec_x,vec_y,vec_z = 0, 0, 0
		-- 	local ang_p, ang_y, ang_r = 0, 0, 0
		-- 	local corn_x, corn_y, corn_z = 0, 0, 0
		-- 	local vec = Vector(
		-- 		k%3==2 and diff_vector.x*(math.floor(k/3)==1 and -1 or 1) or 0, // x
		-- 		k%3==1 and diff_vector.y*(math.floor(k/3)==1 and -1 or 1) or 0, // y
		-- 		k%3==0 and diff_vector.z*(math.floor(k/3)==1 and 1 or -1) or 0 // z
		-- 	)
		-- 	-- print(vec)
		-- 	local angle = Angle(
		-- 		k%3==2 and v[2].p+curAng.p*(math.floor(k/3)==1 and 1 or -1) or curAng.p,
		-- 		k%3==1 and v[2].y+curAng.y*(math.floor(k/3)==1 and 1 or -1) or curAng.y,
		-- 		k%3==0 and v[2].r+curAng.r*(math.floor(k/3)==1 and 1 or -1) or curAng.r
		-- 	)
		-- 	local cornerVector =  Vector(
		-- 		k%3!=2 and diff_vector.x or 0,
		-- 		k%3!=1 and diff_vector.y or 0, 
		-- 		k%3!=0 and diff_vector.z or 0
		-- 	)
		-- 	// for the component axis vector to get the corner we need the other two components * .5 added onto it respectively
		-- 	local color = Color(bit.band(k, 4) * 255, bit.band(k, 2) * 255, bit.band(k, 1) * 255, 100)
		-- 	local c1 = vec - cornerVector
		-- 	local c2 = vec - -1*cornerVector
		-- 	local angle_vec = Vector(vec)
		-- 	angle_vec:Rotate(angle)
		-- 	if(math.floor(k/3)!=1) then
		-- 		angle_vec = angle_vec*-1
		-- 	end
		-- 	cam.Start3D()
		-- 		render.SetColorMaterial(color)
		-- 		render.DrawBox(center,self:GetAngles(), c1, c2, color)
		-- 		render.DrawLine(center,angle_vec+center,color,true)
		-- 		render.DrawLine(center, center+diff_vector, Color(255,255,255,255))
		-- 	cam.End3D()
		-- 	cam.Start3D2D(center*.995,v[2], 1)
		-- 		surface.SetMaterial(Material("materials/face_" .. v[1] .. ".png"))
		-- 		surface.SetDrawColor(0, 0, 0, 200)
		-- 		surface.DrawTexturedRect(-smallest_side/2, -smallest_side/2, smallest_side, smallest_side)
		-- 	cam.End3D2D()
		-- 	cam.Start3D2D(center+angle_vec, v[3], 1)
		-- 		surface.SetMaterial(Material("materials/face_" .. v[1] .. ".png"))
		-- 		surface.SetDrawColor(0, 0, 0, 200)
		-- 		surface.DrawTexturedRect(-smallest_side/2, -smallest_side/2, smallest_side, smallest_side)
		-- 	cam.End3D2D()
		-- end
	end
end

function ENT:OnRemove()
	if(SERVER && self.CornerEnts &&  #self.CornerEnts!=0) then
		for k,v in pairs(self.CornerEnts) do
			v:Remove()
		end
	end
end