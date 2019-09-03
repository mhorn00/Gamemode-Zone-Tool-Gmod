AddCSLuaFile()
include("includes/util/table.lua")
include("includes/util/math.lua")

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
	TESTMODE1 = "Test Mode 1",
	TESTMODE2 = "Test Mode 2",
	TESTMODE3 = "Test Mode 3"
}
TOOL.ModeList = {
	TOOL.Modes.Loading,
	TOOL.Modes.Create,
	TOOL.Modes.Edit,
	TOOL.Modes.TESTMODE1,
	TOOL.Modes.TESTMODE2,
	TOOL.Modes.TESTMODE3
}
TOOL.KeyTable = {}
TOOL.KeyCreationQueue = {}
TOOL.KeyExecutionQueue = {}


TOOL["KF"..TOOL.Modes.Create..MOUSE_LEFT] = function(self, key1)
	if key1.processed then return end  
	print("==================")
	print("THIS IS SINGLE")
	PrintTable(key1)
	print("==================")
end

TOOL["KF"..TOOL.Modes.Create..MOUSE_LEFT..MOUSE_RIGHT] = function(self,key1,key2)
	if key1.processed || key2.processed then return end  
	print("==================")
	print("THIS IS DOUBLE (MLEFT+MRIGHT)")
	PrintTable(key1)
	print("===========")
	PrintTable(key2) 
	print("==================")
end

TOOL["KF"..TOOL.Modes.Create..MOUSE_LEFT..MOUSE_RIGHT..MOUSE_MIDDLE] = function(self,key1,key2,key3)
	if key1.processed || key2.processed || key3.processed then return end  
	print("==================")
	print("THIS IS TRIPLE (MLEFT+MRIGHT+MMIDDLE)", self.COUNT)
	PrintTable(key1)
	print("===========")
	PrintTable(key2) 
	print("===========")
	PrintTable(key3)
	print("==================")
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
 
function TOOL:UpdateToolMode()
	if self:GetOperation() == 0 then
        self:SetOperation(1)
    elseif self:GetOperation() < #self.ModeList - 1 then
        self:SetOperation(self:GetOperation() + 1)
    elseif self:GetOperation() >= #self.ModeList - 1 then
        self:SetOperation(1)
    end
end

function TOOL:Think()
	self:ProcessInput()
	if self:GetToolMode() == self.Modes.Loading then
		self:UpdateToolMode()
	end
end

function TOOL:PlayerButtonDown(key, ply)
	--In this function self refers to the player holding the tool, not the tool itseld
	if CLIENT && !IsFirstTimePredicted() then return end 
	if SERVER && !game.SinglePlayer() then return end
	if(self:GetActiveWeapon():IsValid() && self:GetActiveWeapon():GetClass()=="gmod_tool" && self:GetActiveWeapon():GetTable().current_mode=="gzt_zonetool") then
		local toolInst = self:GetActiveWeapon():GetTable().Tool.gzt_zonetool
		toolInst.KeyTable[key] = {key=key, time=SysTime()} 
		toolInst.KeyCreationQueue[#toolInst.KeyCreationQueue+1] = {key=key, time=SysTime()}
	end
end
hook.Add("PlayerButtonDown", "ZoneToolKeyDown", TOOL.PlayerButtonDown)

function TOOL:PlayerButtonUp(key, ply)
    --In this function self refers to the player holding the tool
	if(self:GetActiveWeapon():IsValid() && self:GetActiveWeapon():GetClass()=="gmod_tool" && self:GetActiveWeapon():GetTable().current_mode=="gzt_zonetool") then
		local toolInst = self:GetActiveWeapon():GetTable().Tool.gzt_zonetool
		-- --PrintTable(toolInst.KeyTable)
		toolInst.KeyTable[key] = nil
	end
end
hook.Add("PlayerButtonUp","ZoneToolKeyUp", TOOL.PlayerButtonUp)

TOOL.KEY_THRESHHOLD={0.15,0.2}
TOOL.KEY_DELAY = {0.2,0.3,0.3}

function TOOL:ProcessInput()
	for i,key in pairs(self.KeyCreationQueue) do
		if !key then continue end
		if self.KeyCreationQueue[i] && self.KeyCreationQueue[i+1] && self.KeyCreationQueue[i+2] then
			if math.min(SysTime()-self.KeyCreationQueue[i].time, SysTime()-self.KeyCreationQueue[i+1].time,SysTime()-self.KeyCreationQueue[i+2].time) >= self.KEY_DELAY[1] then
				if math.abs(self.KeyCreationQueue[i].time-self.KeyCreationQueue[i+1].time) <= self.KEY_THRESHHOLD[1] && math.abs(self.KeyCreationQueue[i+1].time-self.KeyCreationQueue[i+2].time) <= self.KEY_THRESHHOLD[1] then
					self.KeyExecutionQueue[#self.KeyExecutionQueue+1] = {key1=self.KeyCreationQueue[i],key2=self.KeyCreationQueue[i+1],key3=self.KeyCreationQueue[i+2],type="TRIPLE"}
					self.KeyCreationQueue[i]=nil
					self.KeyCreationQueue[i+1]=nil
					self.KeyCreationQueue[i+2]=nil
				end
			end
		elseif self.KeyCreationQueue[i] && self.KeyCreationQueue[i+1] then
			if math.min(SysTime()-self.KeyCreationQueue[i].time, SysTime()-self.KeyCreationQueue[i+1].time) >= self.KEY_DELAY[2] then
				if math.abs(self.KeyCreationQueue[i].time-self.KeyCreationQueue[i+1].time) <= self.KEY_THRESHHOLD[2] then
					self.KeyExecutionQueue[#self.KeyExecutionQueue+1] = {key1=self.KeyCreationQueue[i],key2=self.KeyCreationQueue[i+1],type="DOUBLE"}
					self.KeyCreationQueue[i]=nil
					self.KeyCreationQueue[i+1]=nil
				end
			end 
		elseif self.KeyCreationQueue[i] then
			if SysTime()-self.KeyCreationQueue[i].time >= self.KEY_DELAY[3] then
				self.KeyExecutionQueue[#self.KeyExecutionQueue+1] = {key1=self.KeyCreationQueue[i],type="SINGLE"}
				self.KeyCreationQueue[i]=nil
			end
		end
	end
end

function TOOL:Holster()
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
	draw.SimpleText( self:GetToolMode(), "DermaLarge", width / 2, height / 2, Color( 200, 200, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
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