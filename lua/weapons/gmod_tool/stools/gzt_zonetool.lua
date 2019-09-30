AddCSLuaFile()

TOOL.Category = "Zone Tool"
TOOL.Name = "#tool.gzt_zonetool.name"
TOOL.Command = "gmod_toolmode gzt_zonetool"
TOOL.Author = "Sarcly & Intox"
--Sarcly's comments
//Intox's comments
TOOL.InfoBoxHeight = 0;
TOOL.ToolNameHeight = 0;
TOOL.KeepNoHUDCL = false
TOOL.PreviousDrawHelpState = -1
TOOL.Modes = {
	Loading = "Loading",
	Create = "Create",
	Edit = "Edit",
	Program = "Program Mode"
}
TOOL.ModeList = {
	TOOL.Modes.Loading,
	TOOL.Modes.Create,
	TOOL.Modes.Edit,
	TOOL.Modes.Program
}
TOOL.KeyTable = {}
TOOL.KeyCreationQueue = {}
TOOL.KeyExecutionQueue = {}
TOOL.ModifierKeys = {}
TOOL.ModifierKeys[KEY_LCONTROL] = true
TOOL.ModifierKeys[KEY_LSHIFT] = true
TOOL.ModifierKeys[KEY_LALT] = true
TOOL.CurrentBox = {
	MinBound=nil,
	MaxBound=nil,
	Ent=nil
}
TOOL.SelectedCorner = nil
TOOL.GrabMagnitude = -1

local PausedPlayers={}
local HoveringPlayers={}

if(SERVER) then

	util.AddNetworkString("playerPaused")
	util.AddNetworkString("playerUnpaused")
	util.AddNetworkString("PlayerIsHovering")
	util.AddNetworkString("SetGrabMag")
	util.AddNetworkString("SetCurrentBox")
	util.AddNetworkString("SetToolMode")
	net.Receive("playerPaused", function(len, ply)
		if (IsValid(ply) and ply:IsPlayer()) then
			PausedPlayers[ply:AccountID()] = true
			local toolInst = ply:GetActiveWeapon():GetTable().Tool.gzt_zonetool
			toolInst.KeyCreationQueue = {}
			toolInst.KeyExecutionQueue = {}
		end
	end)

	net.Receive("playerUnpaused", function(len, ply)
		if (IsValid(ply) and ply:IsPlayer()) then
			PausedPlayers[ply:AccountID()] = nil
			local toolInst = ply:GetActiveWeapon():GetTable().Tool.gzt_zonetool
			toolInst.KeyCreationQueue = {}
			toolInst.KeyExecutionQueue = {}
		end
	end)

	net.Receive("SetGrabMag", function(len, ply)
		local toolInst = ply:GetActiveWeapon():GetTable().Tool.gzt_zonetool
		toolInst.GrabMagnitude = net.ReadFloat() 
	end)

	net.Receive("SetToolMode", function(len, ply)
		if (IsValid(ply) and ply:IsPlayer()) then
			local toolInst = ply:GetActiveWeapon():GetTable().Tool.gzt_zonetool
			toolInst:SetOperation(net.ReadInt(len,4))
		end
	end)

	net.Receive("PlayerIsHovering", function(len, ply)
		if(HoveringPlayers[ply]==true) then
			HoveringPlayers[ply] = nil
			local toolInst = ply:GetActiveWeapon():GetTable().Tool.gzt_zonetool
			toolInst.KeyCreationQueue = {}
			toolInst.KeyExecutionQueue = {}
		else
			HoveringPlayers[ply] = true
		end
	end)

else // in client
	net.Receive("SetCurrentBox", function()
		TOOL.CurrentBox.Ent = net.ReadEntity()
		TOOL.CurrentBox.MinBound = TOOL.CurrentBox.Ent:GetMinBound()
		TOOL.CurrentBox.MaxBound = TOOL.CurrentBox.Ent:GetMaxBound()
	end)
end

for k,v in pairs(TOOL.Modes) do
	TOOL["KF"..v..KEY_R] = function(self, KeyCombo)
		if KeyCombo.processed then return end
		self:UpdateToolMode()
	end
	TOOL["KF"..v..KEY_H] = function(self, KeyCombo)
		if !KeyCombo.processed && !KeyCombo.released && CLIENT then
			if(!GZT_PANEL) then
				GZT_PANEL = vgui.Create("gzt_gui")
			end
			GZT_PANEL:SetVisible(true)
			GZT_PANEL:SetToolRef(self)
			GZT_PANEL:PopulateUI()
		end	
	end
end

TOOL["KF"..TOOL.Modes.Create..MOUSE_LEFT] = function(self, KeyCombo)
	if KeyCombo.processed then return end
	self.CurrentBox.MinBound=self:GetOwner():GetPos()
	if self.CurrentBox && self.CurrentBox.MinBound && self.CurrentBox.MaxBound then
		self:MakeBox()
	end
end

TOOL["KF"..TOOL.Modes.Create..MOUSE_RIGHT] = function(self, KeyCombo)
	if KeyCombo.processed then return end
	self.CurrentBox.MaxBound=self:GetOwner():GetPos()
	if self.CurrentBox && self.CurrentBox.MinBound && self.CurrentBox.MaxBound then
		self:MakeBox()
	end
end

TOOL["KF"..TOOL.Modes.Create..KEY_LCONTROL..MOUSE_LEFT] = function(self, KeyCombo)
	if KeyCombo.processed then return end
	if self.CurrentBox.Ent then
		self:DeleteBox()
		self.CurrentBox.Ent=nil
	end
	if self.CurrentBox.MinBound then
		self.CurrentBox.MinBound=nil
	end
end

TOOL["KF"..TOOL.Modes.Create..KEY_LCONTROL..MOUSE_RIGHT] = function(self, KeyCombo)
	if KeyCombo.processed then return end
	if self.CurrentBox.Ent then
		self:DeleteBox()
		self.CurrentBox.Ent=nil
	end
	if self.CurrentBox.MaxBound then
		self.CurrentBox.MaxBound=nil
	end
end

TOOL["KF"..TOOL.Modes.Create..KEY_LALT..MOUSE_LEFT] = function(self, KeyCombo)
	if !KeyCombo.processed && !KeyCombo.released then
		if(!IsValid(self.SelectedCorner)) then
			tr = self:GetOwner():GetEyeTrace()
			if(tr.Hit && IsValid(tr.Entity) && tr.Entity.ClassName=="gzt_zonecorner") then
				self.SelectedCorner = tr.Entity
				self.SelectedCorner:SetColor(Color(0,0,255,255))
				self.GrabMagnitude=self.SelectedCorner:GetPos():Distance(self:GetOwner():EyePos())
			end
		end
	elseif KeyCombo.processed && !KeyCombo.released then
		if IsValid(self.SelectedCorner) then
			self.SelectedCorner:SetPos(self:GetOwner():EyePos()+self:GetOwner():GetAimVector()*self.GrabMagnitude)
			self.SelectedCorner:GetOwner():Resize(self.SelectedCorner)
		end
	elseif KeyCombo.processed && KeyCombo.released then
		if IsValid(self.SelectedCorner) then
			self.SelectedCorner:SetColor(Color(255,255,255,255))
			if(SERVER) then
				self.SelectedCorner:GetOwner():BuildCorners()
			end
			self.SelectedCorner = nil 
		end
	end
end

function TOOL.BuildCPanel(CPanel)
	local button = vgui.Create("DButton")
	CPanel:AddItem(button)
end

function TOOL:GetToolMode()
    return self.ModeList[self:GetOperation()+1]
	--+1 because glua tables start at 1 smh
end

function TOOL:GetToolModeOperation(operation)
	return self.ModeList[operation+1]
end

function TOOL:SetToolMode(mode)

	local toMode = 2 -- defualt to create mode
	for i,m in pairs(self.ModeList) do
		if m==mode then
			toMode=i
		end
	end
	if CLIENT then
		net.Start("SetToolMode")
		net.WriteInt(toMode-1, 4)
		net.SendToServer()
	end
	self:SetOperation(toMode-1)
end
 
function TOOL:UpdateToolMode()
	if(CLIENT) then print(self) end
	if self:GetOperation() == 0 then
        self:SetOperation(1)
    elseif self:GetOperation() < #self.ModeList - 1 then
        self:SetOperation(self:GetOperation() + 1)
    elseif self:GetOperation() >= #self.ModeList - 1 then
        self:SetOperation(1)
    end
end

TOOL.HoverStatus = false

function TOOL:Think()
	if CLIENT then
		if((vgui.GetHoveredPanel()!=nil)!=self.HoverStatus) then
			net.Start("PlayerIsHovering")
			net.SendToServer()
			self.HoverStatus = !self.HoverStatus
			if(!self.HoverStatus) then
				self.KeyCreationQueue = {}
				self.KeyExecutionQueue = {}
			end
		end
	end
	if CLIENT && (gui && gui.IsGameUIVisible()) && !self.isPaused then
		self.isPaused = true
		net.Start("playerPaused")
			net.WriteString("")
		net.SendToServer()
		self.KeyExecutionQueue = {}
		self.KeyCreationQueue = {}
	elseif CLIENT && (gui && !gui.IsGameUIVisible()) && self.isPaused then
		self.isPaused = false
		net.Start("playerUnpaused")
			net.WriteString("")
		net.SendToServer()
		self.KeyExecutionQueue = {}
		self.KeyCreationQueue = {}
	end
	if ( (gui && !gui.IsGameUIVisible() && vgui.GetHoveredPanel()==nil) || (SERVER && !PausedPlayers[self:GetOwner():AccountID()] && !HoveringPlayers[self:GetOwner()])) then
		self:ProcessInput()
	end
	if self:GetToolMode() == self.Modes.Loading then
		if CLIENT then	
			GZT_ZONETOOL = self
		end
		self:UpdateToolMode()
	end
end

function PlayerBindPress(ply, bind, pressed)
	if(ply:GetActiveWeapon():IsValid() && ply:GetActiveWeapon():GetClass()=="gmod_tool" && ply:GetActiveWeapon():GetTable().current_mode=="gzt_zonetool") then
		local self = ply:GetActiveWeapon():GetTable().Tool.gzt_zonetool
		if IsValid(self.SelectedCorner) then
			local tempGM = self.GrabMagnitude
			if(bind == "invprev") then
				--TODO:scale amount moved on scroll by how far away the box is
				tempGM = math.max(tempGM+5, 10)
				net.Start("SetGrabMag")
				net.WriteFloat(tempGM)
				net.SendToServer()
				self.GrabMagnitude=tempGM
				return true
			elseif bind == "invnext" then
				tempGM = math.max(tempGM-5, 10)
				net.Start("SetGrabMag")
				net.WriteFloat(tempGM)
				net.SendToServer()
				self.GrabMagnitude=tempGM				
				return true
			end
		end
	end
end
hook.Add("PlayerBindPress", "ZoneToolScrollHandle", PlayerBindPress)

function TOOL:MakeBox() --SERVER ONLY
	if CLIENT then return end
	if !IsValid(self.CurrentBox.Ent) then
		self.CurrentBox.Ent=ents.Create("gzt_zone")
		self.CurrentBox.Ent:Spawn()
	end
	self.CurrentBox.Ent:Setup(self.CurrentBox.MinBound, self.CurrentBox.MaxBound)
end

function TOOL:DeleteBox() 
	if CLIENT then return end
	if(self.CurrentBox && IsValid(self.CurrentBox.Ent)) then
		self.CurrentBox.Ent:Remove()
	end
end


function TOOL:PlayerButtonDown(key, ply)
	--In this function self refers to the player holding the tool, not the tool itself
	if CLIENT && !IsFirstTimePredicted() then return end 
	if(self:GetActiveWeapon():IsValid() && self:GetActiveWeapon():GetClass()=="gmod_tool" && self:GetActiveWeapon():GetTable().current_mode=="gzt_zonetool") then
		local toolInst = self:GetActiveWeapon():GetTable().Tool.gzt_zonetool
		toolInst.KeyTable[key] = {key=key, time=SysTime()} 
		toolInst.KeyCreationQueue[#toolInst.KeyCreationQueue+1] = {key=key, time=SysTime()}
	end
end
hook.Add("PlayerButtonDown", "ZoneToolKeyDown", TOOL.PlayerButtonDown)

function TOOL:PlayerButtonUp(key, ply)
    --In this function self refers to the player holding the tool, not the tool itself
	if(self:GetActiveWeapon():IsValid() && self:GetActiveWeapon():GetClass()=="gmod_tool" && self:GetActiveWeapon():GetTable().current_mode=="gzt_zonetool") then
		local toolInst = self:GetActiveWeapon():GetTable().Tool.gzt_zonetool
		toolInst.KeyTable[key] = nil
		if(toolInst.ModifierKeys[key]) then
			for i,v in pairs(toolInst.KeyCreationQueue) do
				if v.key == key then
					toolInst.KeyCreationQueue[i] = nil
				end
			end
		end
	end
end
hook.Add("PlayerButtonUp","ZoneToolKeyUp", TOOL.PlayerButtonUp)

function TOOL:ProcessInput()
	--CREATION OF KEY COMBOS
	for i,key in pairs(self.KeyCreationQueue) do
		if !self.KeyCreationQueue[i] then continue end
		if self.KeyCreationQueue[i] && self.KeyCreationQueue[i+1] && self.KeyCreationQueue[i+2] && self.KeyCreationQueue[i+3] then
			if self.KeyCreationQueue[i].key != self.KeyCreationQueue[i+1].key && self.KeyCreationQueue[i].key != self.KeyCreationQueue[i+2].key && self.KeyCreationQueue[i].key != self.KeyCreationQueue[i+3].key && self.KeyCreationQueue[i+1].key != self.KeyCreationQueue[i+2].key && self.KeyCreationQueue[i+1].key != self.KeyCreationQueue[i+3].key && self.KeyCreationQueue[i+2].key != self.KeyCreationQueue[i+3].key then
				if self.ModifierKeys[self.KeyCreationQueue[i].key] && self.ModifierKeys[self.KeyCreationQueue[i+1].key] && self.ModifierKeys[self.KeyCreationQueue[i+2].key] then
					if !self.ModifierKeys[self.KeyCreationQueue[i+3].key] then
						self.KeyExecutionQueue[#self.KeyExecutionQueue+1] = {key1=self.KeyCreationQueue[i], key2=self.KeyCreationQueue[i+1], key3=self.KeyCreationQueue[i+2], key4=self.KeyCreationQueue[i+3], comboType="QUADRUPLE", processed=false, released=false}
						if !self.KeyTable[self.KeyCreationQueue[i].key] then
							self.KeyCreationQueue[i] = nil
						end
						if !self.KeyTable[self.KeyCreationQueue[i+1].key] then
							self.KeyCreationQueue[i+1] = nil
						end
						if !self.KeyTable[self.KeyCreationQueue[i+2].key] then
							self.KeyCreationQueue[i+2] = nil
						end
						self.KeyCreationQueue[i+3]=nil
					end
				end
			end
		elseif self.KeyCreationQueue[i] && self.KeyCreationQueue[i+1] && self.KeyCreationQueue[i+2] && (self.KeyCreationQueue[i].key != self.KeyCreationQueue[i+1].key && self.KeyCreationQueue[i+1].key != self.KeyCreationQueue[i+2].key && self.KeyCreationQueue[i].key != self.KeyCreationQueue[i+2].key) then
			if self.ModifierKeys[self.KeyCreationQueue[i].key] && self.ModifierKeys[self.KeyCreationQueue[i+1].key] then
				if !self.ModifierKeys[self.KeyCreationQueue[i+2].key] then
					self.KeyExecutionQueue[#self.KeyExecutionQueue+1] = {key1=self.KeyCreationQueue[i], key2=self.KeyCreationQueue[i+1], key3=self.KeyCreationQueue[i+2], comboType="TRIPLE", processed=false, released=false}
					if !self.KeyTable[self.KeyCreationQueue[i].key] then
						self.KeyCreationQueue[i] = nil
					end
					if !self.KeyTable[self.KeyCreationQueue[i+1].key] then
						self.KeyCreationQueue[i+1] = nil
					end
					self.KeyCreationQueue[i+2]=nil
				end
			end
		elseif self.KeyCreationQueue[i] && self.KeyCreationQueue[i+1] && (self.KeyCreationQueue[i].key != self.KeyCreationQueue[i+1].key) then
			if self.ModifierKeys[self.KeyCreationQueue[i].key] then
				if !self.ModifierKeys[self.KeyCreationQueue[i+1].key] then
					self.KeyExecutionQueue[#self.KeyExecutionQueue+1] = {key1=self.KeyCreationQueue[i], key2=self.KeyCreationQueue[i+1], comboType="DOUBLE", processed=false, released=false}
					if !self.KeyTable[self.KeyCreationQueue[i].key] then
						self.KeyCreationQueue[i] = nil
					end
					self.KeyCreationQueue[i+1]=nil
				end
			end
		elseif self.KeyCreationQueue[i] then
			if !self.ModifierKeys[self.KeyCreationQueue[i].key] then
				self.KeyExecutionQueue[#self.KeyExecutionQueue+1] = {key1=self.KeyCreationQueue[i], comboType="SINGLE", processed=false, released=false}
				self.KeyCreationQueue[i]=nil
			end
		end
	end
	--EXECUTION OF KEY COMBOS
	for i,KeyCombo in pairs(self.KeyExecutionQueue) do
		--if key combo has been processed and is not held then remove it
		if !self.KeyExecutionQueue[i] then continue end
		if self.KeyExecutionQueue[i].processed then
			if self.KeyExecutionQueue[i].comboType == "SINGLE" then
				if !self.KeyTable[self.KeyExecutionQueue[i].key1.key] then
					self.KeyExecutionQueue[i].released=true
				end
			elseif self.KeyExecutionQueue[i].comboType == "DOUBLE" then
				if !self.KeyTable[self.KeyExecutionQueue[i].key1.key] || !self.KeyTable[self.KeyExecutionQueue[i].key2.key] then
					self.KeyExecutionQueue[i].released=true
				end
			elseif self.KeyExecutionQueue[i].comboType == "TRIPLE" then
				if !self.KeyTable[self.KeyExecutionQueue[i].key1.key] || !self.KeyTable[self.KeyExecutionQueue[i].key2.key] || !self.KeyTable[self.KeyExecutionQueue[i].key3.key] then
					self.KeyExecutionQueue[i].released=true
				end
			elseif self.KeyExecutionQueue[i].comboType == "QUADRUPLE" then
				if !self.KeyTable[self.KeyExecutionQueue[i].key1.key] || !self.KeyTable[self.KeyExecutionQueue[i].key2.key] || !self.KeyTable[self.KeyExecutionQueue[i].key3.key] || !self.KeyTable[self.KeyExecutionQueue[i].key4.key] then
					self.KeyExecutionQueue[i].released=true
				end
			end
		end
		--run the fuction for the key combo if it exists
		if self.KeyExecutionQueue[i].comboType == "SINGLE" then
			if self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key1.key] then
				self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key1.key](self,self.KeyExecutionQueue[i])
				self.KeyExecutionQueue[i].processed=true 
			end
		elseif self.KeyExecutionQueue[i].comboType == "DOUBLE" then
			if self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key1.key..self.KeyExecutionQueue[i].key2.key] then
				self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key1.key..self.KeyExecutionQueue[i].key2.key](self,self.KeyExecutionQueue[i])
				self.KeyExecutionQueue[i].processed=true 
			elseif self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key2.key] then
				self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key2.key](self,self.KeyExecutionQueue[i])
				self.KeyExecutionQueue[i].processed=true 
			end
		elseif self.KeyExecutionQueue[i].comboType == "TRIPLE" then
			if self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key1.key..self.KeyExecutionQueue[i].key2.key..self.KeyExecutionQueue[i].key3.key] then
				self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key1.key..self.KeyExecutionQueue[i].key2.key..self.KeyExecutionQueue[i].key3.key](self,self.KeyExecutionQueue[i])
				self.KeyExecutionQueue[i].processed=true 
			elseif self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key2.key..self.KeyExecutionQueue[i].key1.key..self.KeyExecutionQueue[i].key3.key] then
				self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key2.key..self.KeyExecutionQueue[i].key1.key..self.KeyExecutionQueue[i].key3.key](self,self.KeyExecutionQueue[i])
				self.KeyExecutionQueue[i].processed=true 
			elseif self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key3.key] then
				self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key3.key](self,self.KeyExecutionQueue[i])
				self.KeyExecutionQueue[i].processed=true 
			end
		elseif self.KeyExecutionQueue[i].comboType == "QUADRUPLE" then
			if self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key1.key..self.KeyExecutionQueue[i].key2.key..self.KeyExecutionQueue[i].key3.key..self.KeyExecutionQueue[i].key4.key] then
				self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key1.key..self.KeyExecutionQueue[i].key2.key..self.KeyExecutionQueue[i].key3.key..self.KeyExecutionQueue[i].key4.key](self,self.KeyExecutionQueue[i])
				self.KeyExecutionQueue[i].processed=true 
			elseif self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key1.key..self.KeyExecutionQueue[i].key3.key..self.KeyExecutionQueue[i].key2.key..self.KeyExecutionQueue[i].key4.key] then
				self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key1.key..self.KeyExecutionQueue[i].key3.key..self.KeyExecutionQueue[i].key2.key..self.KeyExecutionQueue[i].key4.key](self,self.KeyExecutionQueue[i])
				self.KeyExecutionQueue[i].processed=true 
			elseif self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key2.key..self.KeyExecutionQueue[i].key1.key..self.KeyExecutionQueue[i].key3.key..self.KeyExecutionQueue[i].key4.key] then
				self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key2.key..self.KeyExecutionQueue[i].key1.key..self.KeyExecutionQueue[i].key3.key..self.KeyExecutionQueue[i].key4.key](self,self.KeyExecutionQueue[i])
				self.KeyExecutionQueue[i].processed=true
			elseif self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key2.key..self.KeyExecutionQueue[i].key3.key..self.KeyExecutionQueue[i].key1.key..self.KeyExecutionQueue[i].key4.key] then
				self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key2.key..self.KeyExecutionQueue[i].key3.key..self.KeyExecutionQueue[i].key1.key..self.KeyExecutionQueue[i].key4.key](self,self.KeyExecutionQueue[i])
				self.KeyExecutionQueue[i].processed=true
			elseif self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key3.key..self.KeyExecutionQueue[i].key1.key..self.KeyExecutionQueue[i].key2.key..self.KeyExecutionQueue[i].key4.key] then
				self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key3.key..self.KeyExecutionQueue[i].key1.key..self.KeyExecutionQueue[i].key2.key..self.KeyExecutionQueue[i].key4.key](self,self.KeyExecutionQueue[i])
				self.KeyExecutionQueue[i].processed=true
			elseif self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key3.key..self.KeyExecutionQueue[i].key2.key..self.KeyExecutionQueue[i].key1.key..self.KeyExecutionQueue[i].key4.key] then
				self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key3.key..self.KeyExecutionQueue[i].key2.key..self.KeyExecutionQueue[i].key1.key..self.KeyExecutionQueue[i].key4.key](self,self.KeyExecutionQueue[i])
				self.KeyExecutionQueue[i].processed=true
			elseif self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key4.key] then
				self["KF"..self:GetToolMode()..self.KeyExecutionQueue[i].key4.key](self,self.KeyExecutionQueue[i])
				self.KeyExecutionQueue[i].processed=true 
			end
		end
		if self.KeyExecutionQueue[i].processed && self.KeyExecutionQueue[i].released then
			if self.KeyExecutionQueue[i].comboType == "SINGLE" then
				if !self.KeyTable[self.KeyExecutionQueue[i].key1.key] then
					self.KeyExecutionQueue[i]=nil
					continue
				end
			elseif self.KeyExecutionQueue[i].comboType == "DOUBLE" then
				if !self.KeyTable[self.KeyExecutionQueue[i].key1.key] || !self.KeyTable[self.KeyExecutionQueue[i].key2.key] then
					self.KeyExecutionQueue[i]=nil
					continue
				end
			elseif self.KeyExecutionQueue[i].comboType == "TRIPLE" then
				if !self.KeyTable[self.KeyExecutionQueue[i].key1.key] || !self.KeyTable[self.KeyExecutionQueue[i].key2.key] || !self.KeyTable[self.KeyExecutionQueue[i].key3.key] then
					self.KeyExecutionQueue[i]=nil
					continue 
				end
			elseif self.KeyExecutionQueue[i].comboType == "QUADRUPLE" then
				if !self.KeyTable[self.KeyExecutionQueue[i].key1.key] || !self.KeyTable[self.KeyExecutionQueue[i].key2.key] || !self.KeyTable[self.KeyExecutionQueue[i].key3.key] || !self.KeyTable[self.KeyExecutionQueue[i].key4.key] then
					self.KeyExecutionQueue[i]=nil
					continue 
				end
			end
		end
		if(!self.KeyExecutionQueue[i].processed) then
			self.KeyExecutionQueue[i]=nil
		end
	end
end

function TOOL:Holster()
	self:DeleteBox()
	self.CurrentBox.Ent=nil
	self.CurrentBox.MinBound=nil 
	self.CurrentBox.MaxBound=nil
    self:SetOperation(0)
	if CLIENT then
		GetConVar("gmod_drawhelp"):SetInt(self.PreviousDrawHelpState)
		self.PreviousDrawHelpState = -1
	end
end

function TOOL:Reload() // otherwise when u hit r it sets operation to 0 
	return --this is bullshit and i hate it
end

function TOOL:DrawHUD() --CLIENT ONLY
	if self.PreviousDrawHelpState == -1 then
		self.PreviousDrawHelpState = GetConVar("gmod_drawhelp"):GetInt()
		GetConVar("gmod_drawhelp"):SetInt(0)
	end
	if(self.SecondKeyQueue) then
		draw.DrawText(table.ToString(self.SecondKeyQueue,"KeyCreationQueue", true), "DermaDefault",surface.ScreenWidth()-450, 150, Color(0,0,0))
	end
	if self.KeepNoHUDCL then return end
	--Small rewrite of the sandbox STool draw HUD because I wanted to be able to use shift and ctrl as modifier keys for keybinds. Im very extra =)
	local mode = "gzt_zonetool"
	if (not self) then return end
	local x, y = 50, 40
	local w, h = 0, 0
	local TextTable = {}
	local QuadTable = {}
	--Draws the gradient under the tool name and description
	QuadTable.texture = surface.GetTextureID("gui/gradient")
	QuadTable.color = Color(10, 10, 10, 180)
	QuadTable.x = 0
	QuadTable.y = y - 8
	QuadTable.w = 600
	QuadTable.h = self.ToolNameHeight - (y - 8)
	draw.TexturedQuad(QuadTable)
	--Draws the tool name text
	TextTable.font = "GModToolName"
	TextTable.color = Color(240, 240, 240, 255)
	TextTable.pos = {x, y}
	TextTable.text = "#tool." .. mode .. ".name"
	w, h = draw.TextShadow(TextTable, 2)
	y = y + h
	--Draws the description text
	TextTable.font = "GModToolSubtitle"
	TextTable.pos = {x, y}
	TextTable.text = "#tool." .. mode .. ".desc"
	w, h = draw.TextShadow(TextTable, 1)
	y = y + h + 8
	self.ToolNameHeight = y
	--Draws gradient under the info
	QuadTable.y = y
	QuadTable.h = self.InfoBoxHeight
	local alpha = math.Clamp(255 + (self.LastMessage - CurTime()) * 800, 10, 255)
	QuadTable.color = Color(alpha, alpha, alpha, 230)
	draw.TexturedQuad(QuadTable)
	y = y + 4
	TextTable.font = "GModToolHelp"
	if (not self.formation) then
		TextTable.pos = {x + self.InfoBoxHeight, y}
		TextTable.text = self:GetHelpText()
		w, h = draw.TextShadow(TextTable, 1)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetTexture(surface.GetTextureID("gui/info"))
		surface.DrawTexturedRect(x + 1, y + 1, h - 3, h - 3)
		self.InfoBoxHeight = h + 8
		return
	end
	local h2 = 0
	--Loop over all entrys in Information and populate them
	for k, v in pairs(self.Information) do
		-- If element of Information is just a string then make it a table containg the string in name ("string"->{name="string"})
		if (type(v) == "string") then
			v = {
				name = v
			}
		end
		if (not v.name) then continue end --If no name then skip
		if (v.stage and v.stage ~= self:GetStage()) then continue end --If stage if not correct then skip
		if (v.op and v.op ~= self:GetOperation()) then continue end --If operation not correct then skip
		local txt = "#tool." .. GetConVarString("gmod_toolmode") .. "." .. v.name
		if (v.name == "info") then
			txt = self:GetHelpText()
		end
		TextTable.text = txt
		TextTable.pos = {x + 21, y + h2}
		w, h = draw.TextShadow(TextTable, 1)
		--Shortcuts for icons in info space
		if (not v.icon) then
			if (v.name:StartWith("info")) then
				v.icon = "gui/info"
			end

			if (v.name:StartWith("left")) then
				v.icon = "gui/lmb.png"
			end

			if (v.name:StartWith("right")) then
				v.icon = "gui/rmb.png"
			end

			if (v.name:StartWith("reload")) then
				v.icon = "gui/r.png"
			end

			if (v.name:StartWith("use")) then
				v.icon = "gui/e.png"
			end
		end
		if (not v.icon2) then
			if (not v.name:StartWith("use") and v.name:EndsWith("use")) then
				v.icon2 = "gui/e.png"
			end
			--added shift to modifer keys
			if (not v.name:StartWith("shift") and v.name:EndsWith("shift")) then
				v.icon2 = "materials/shift.png"
			end
			--added ctrl to modifer keys
			if (not v.name:StartWith("ctrl") and v.name:EndsWith("ctrl")) then
				v.icon2 = "materials/ctrl.png"
			end
		end
		self.Icons = self.Icons or {}
		if (v.icon and not self.Icons[v.icon]) then
			self.Icons[v.icon] = Material(v.icon)
		end
		if (v.icon2 and not self.Icons[v.icon2]) then
			self.Icons[v.icon2] = Material(v.icon2)
		end
		if (v.icon and self.Icons[v.icon] and not self.Icons[v.icon]:IsError()) then
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(self.Icons[v.icon])
			surface.DrawTexturedRect(x, y + h2, 16, 16) --Icon1 draw (must be 16x16 png)
		end
		if (v.icon2 and self.Icons[v.icon2] and not self.Icons[v.icon2]:IsError()) then
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(self.Icons[v.icon2])
			surface.DrawTexturedRect(x - (11 + (self.Icons[v.icon2]:Width())), y + h2, self.Icons[v.icon2]:Width(), self.Icons[v.icon2]:Height()) --Icon2 draw (must be #x16 png)
			draw.SimpleText("+", "default", x - 8, y + h2 + 2, color_white)
		end
		h2 = h2 + h
	end
	self.InfoBoxHeight = h2 + 8
end

function TOOL:DrawToolScreen(width, height)
	surface.SetDrawColor( Color( 20, 20, 20 ) )
	surface.DrawRect( 0, 0, width, height )
	draw.SimpleText( self:GetToolMode(), "DermaLarge", width / 2, height / 4, Color( 200, 200, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	if self.CurrentBox.MinBound && self:GetToolMode()=="Create" then
		draw.SimpleText( math.Round(self.CurrentBox.MinBound.x,2), "DermaLarge", width / 5, height / 2.5, Color( 200, 200, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( math.Round(self.CurrentBox.MinBound.y,2), "DermaLarge", width / 5, height / 1.9, Color( 200, 200, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( math.Round(self.CurrentBox.MinBound.z,2), "DermaLarge", width / 5, height / 1.5, Color( 200, 200, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	if self.CurrentBox.MaxBound && self:GetToolMode()=="Create" then
		draw.SimpleText( math.Round(self.CurrentBox.MaxBound.x,2), "DermaLarge", width / 1.35, height / 2.5, Color( 200, 200, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( math.Round(self.CurrentBox.MaxBound.y,2), "DermaLarge", width / 1.35, height / 1.9, Color( 200, 200, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( math.Round(self.CurrentBox.MaxBound.z,2), "DermaLarge", width / 1.35, height / 1.5, Color( 200, 200, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	if self:GetToolMode()=="Create" then
		draw.SimpleText(self.GrabMagnitude, "DermaLarge", width/2, height/1.1, Color( 200, 200, 200, 200 ),TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
end
--local toolInst = self:GetActiveWeapon():GetTable().Tool.gzt_zonetool
function SWEP:PostDrawViewModel(viewmodel, weapon, ply)
	local toolInst = weapon:GetTable().Tool.gzt_zonetool
	if IsValid(toolInst.SelectedCorner) then
		cam.Start3D()
			render.SetMaterial(Material("cable/physbeam"))
			local plane = ply:EyePos()
			local vec, ang = viewmodel:GetBonePosition(42)
			// perpendicular to the aim vector + bone vector
			//TODO: make beam look nicer
			local FOVScale = (ply:GetFOV()-75)/10
			render.DrawBeam(vec + ply:GetAimVector():Angle():Right()*FOVScale, toolInst.SelectedCorner:GetPos(), 1, 1,1, Color(0,230,100))
			render.DrawLine(toolInst.SelectedCorner:GetOwner():GetPos(),toolInst.SelectedCorner:GetOwner():GetPos()+toolInst.SmallerDifVector, Color(255,255,0,255))
		cam.End3D()
	end
end

function SWEP:DrawWorldModel()
	--TODO: Draw beam on worldmodel
	self:DrawModel()
	-- local toolInst = self:GetTable().Tool.gzt_zonetool
	-- print("dwm",self)
	-- --print(toolInst.SelectedCorner)
	-- if(IsValid(toolInst.SelectedCorner)) then
	-- 	cam.Start3D()
	-- 		render.SetMaterial(Material("cable/physbeam"))
	-- 		print("===================")
	-- 		for i = 1, self:GetBoneCount() do
	-- 			print(i, self:GetBoneName(i))
	-- 			local vec, ang = self:GetBonePosition(i)
	-- 			print(i, vec)
	-- 			local FOVScale = (self:GetOwner():GetFOV()-75)/10
	-- 			render.DrawBeam(vec + self:GetOwner():GetAimVector():Angle():Right()*FOVScale, toolInst.SelectedCorner:GetPos(), 1, 1,1, Color(0,230,100))
	-- 		end
	-- 		// perpendicular to the aim vector + bone vector
	-- 	cam.End3D()
	-- end
end

if CLIENT then
    TOOL.Information={
		{name=TOOL.Modes.Loading, op=0},
		{name=TOOL.Modes.Create, op=1},
		{name=TOOL.Modes.Edit, op=2}
	}

	language.Add("tool.gzt_zonetool.name", "Zone Tool")
	language.Add("tool.gzt_zonetool.desc", "stuff and shit")
	language.Add("tool.gzt_zonetool."..TOOL.Modes.Loading, TOOL.Modes.Loading)
	language.Add("tool.gzt_zonetool."..TOOL.Modes.Create, TOOL.Modes.Create)
	language.Add("tool.gzt_zonetool."..TOOL.Modes.Edit, TOOL.Modes.Edit)
end

if CLIENT then
	GZT_ZONETOOL = TOOL
end

include("modules/cl_gui.lua")
