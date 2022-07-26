-----------------------------------------------------------------------------------------------
-- LandMarks
--- Vim Exe @ Jabbit, <Codex>
--
--- TODO
--
--- Make up a witty name for addon
--- refactor so I can pretend it doesn't look bad
--- zone check
--- save/load drawings
--- undo/redo
--- interface
---- draw modes
---- color picker
---- line style

LandMarks = {
	name = "LandMarks",
	version = "0.0.2",
	nLineWidth = 5,
	crLineColor = ApolloColor.new(0/255, 160/255,  200/255, 1),
	fCircleRadius = 1.5,
	nCircleSides = 3,
	nLandMarkHeight = 2,
	fCircleHoverHeight = 0.5,
	
	tUnitLandMarks = {},
	tLandMarks = {},
	tCurrentPath = {},
	tPaths = {},
	tMembers = {},
} 

function LandMarks:OnLoad()
	self:LoadInterface()

	Apollo.RegisterSlashCommand("lmdraw",    "OnLmDraw", self)
	Apollo.RegisterEventHandler("GameClickWorld", "OnGameClickWorld", self)
	Apollo.RegisterEventHandler("NextFrame",   "OnFrame",   self)

	Apollo.RegisterEventHandler("Group_Add",    "OnGroup_Add",    self)
	Apollo.RegisterEventHandler("Group_Remove", "OnGroup_Remove", self)
	Apollo.RegisterEventHandler("Group_Join",   "OnGroup_Join",    self)
	Apollo.RegisterEventHandler("Group_Left",   "OnGroup_Left",   self)
	
	self.tmrDelayClickToMove = ApolloTimer.Create(0.01, false, "OnDelayClickToMove", self)
	self.tmrDelayClickToMove:Stop()
		
	self.vCircle = self:CalcCircleVectors()
	
	--self.channel = ICCommLib.JoinChannel("LandMarks", "OnICCommMessageReceived", self)
	self.channel = setmetatable({}, {__index = function() return function() end end}) -- stubby stub
	
	self.tmrInit = ApolloTimer.Create(5, false, "InitGroup", self)
end


function LandMarks:ClearLandMarks()
	for i,lm in pairs(self.tUnitLandMarks) do lm.unit:Destroy() end
	self.tUnitLandMarks = {}
end

function LandMarks:Update(tLandMarks,tPaths)
	if tLandMarks then self.tLandMarks = tLandMarks end
	if tPaths then self.tPaths = tPaths end
	self:ClearLandMarks()
	for sprite,pos in pairs(self.tLandMarks) do
		local unitLandMark = Apollo.LoadForm(self.xmlDoc, "unitLandMark", "FixedHudStratumHigh", self)
		unitLandMark:SetSprite(sprite)
		self.tUnitLandMarks[#self.tUnitLandMarks+1] = {unit = unitLandMark, pos = Vector3.New(pos)}
	end
	if GroupLib.AmILeader() then self:Send() end
end

function LandMarks:PlaceLandMark(sprite, pos)
	self.tLandMarks[sprite] = {x = pos.x, y = pos.y, z = pos.z} -- convert from Vector3 to regular table
	self:Update()                                               -- so it can be sent over ICCommLib
end

function LandMarks:DestroyLandMark(sprite)
	self.tLandMarks[sprite] = nil
	self:Update()
end

function LandMarks:OnGameClickWorld(vPos)
	if Apollo.GetConsoleVariable("player.clickToMove") then
		if self.lmMode == "Draw" then
			Print(vPos.x .. ", " .. vPos.y .. ", " .. vPos.z)
			Apollo.SetConsoleVariable("player.clickToMove",false)
			self.tCurrentPath[#self.tCurrentPath+1] = vPos
			self.tmrDelayClickToMove:Start()
		elseif self.lmActive then
			Apollo.SetConsoleVariable("player.clickToMove",false)
			self:PlaceLandMark(self.lmActive.sprite, vPos)
			self.lmActive.wndControl:SetCheck(false)
			self.lmActive = nil
		end
	end
end

function LandMarks:OnLmDraw()
	self.tPaths = {}
	self.tCurrentPath = {}
	self.lmMode = "Draw"
	Apollo.SetConsoleVariable("player.clickToMove",true)
end 

function LandMarks:OnClick(wndHandler, wndControl, eMouseButton)
	if eMouseButton == GameLib.CodeEnumInputMouse.Right then
		if self.lmMode == "Draw" then
			self.tPaths[#self.tPaths+1] = self.tCurrentPath --self:CurvePath(self.tCurrentPath)
			self.tCurrentPath = {}
			Apollo.SetConsoleVariable("player.clickToMove",false)
			self:Update()
		end
		self.lmMode = nil
	end
end

function LandMarks:OnDelayClickToMove()
	Apollo.SetConsoleVariable("player.clickToMove",true)
end

function LandMarks:OnFrame()
	self.wndOverlay:DestroyAllPixies()
	--self:DrawPath(self:CurvePath(self.tCurrentPath))
	self:DrawPath(self.tCurrentPath)
	for _,path in pairs(self.tPaths) do	self:DrawPath(path)	end
	local vHeight = Vector3.New(0,self.nLandMarkHeight+self.fCircleHoverHeight*math.sin(os.clock()),0)
	for _,lm in pairs(self.tUnitLandMarks) do
		lm.unit:SetWorldLocation(lm.pos + vHeight)
		local vP = GameLib.WorldLocToScreenPoint(lm.pos)
		self.wndDebug:SetText(vP.x .. " - " .. vP.y)
		--if lm.unit:IsOnScreen() then
			self:DrawCircle(Vector3.New(lm.pos), self.fCircleRadius) 
		--end
	end
end

Apollo.RegisterAddon(LandMarks)
