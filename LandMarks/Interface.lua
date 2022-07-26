local tLandMarkSprites = {
	"IconSprites:Icon_Windows_UI_CRB_Marker_Bomb",
	"IconSprites:Icon_Windows_UI_CRB_Marker_Chicken",
	"IconSprites:Icon_Windows_UI_CRB_Marker_Ghost",
	"IconSprites:Icon_Windows_UI_CRB_Marker_Mask",
	"IconSprites:Icon_Windows_UI_CRB_Marker_Octopus",
	"IconSprites:Icon_Windows_UI_CRB_Marker_Pig",
	"IconSprites:Icon_Windows_UI_CRB_Marker_Toaster",
	"IconSprites:Icon_Windows_UI_CRB_Marker_UFO",
}

function LandMarks:LoadInterface()
	self.xmlDoc = XmlDoc.CreateFromFile("LandMarks.xml")
	self.wndOverlay = Apollo.LoadForm(self.xmlDoc, "Overlay", "InWorldHudStratum", self)
	self.wndDebug = Apollo.LoadForm(self.xmlDoc, "bler", nil, self)
	self.wndLandMarks = Apollo.LoadForm(self.xmlDoc, "LandMarks", nil, self)
	self.wndLandMarks:Show(false, true)
	
	for i,sprite in pairs(tLandMarkSprites) do
		local btnLandMark = Apollo.LoadForm(self.xmlDoc, "btnLandMark", self.wndLandMarks, self)
		btnLandMark:SetSprite(sprite)
		btnLandMark:SetData({ sprite = sprite, wndControl = btnLandMark })
	end
	self.wndLandMarks:ArrangeChildrenHorz()

	Apollo.RegisterEventHandler("WindowManagementReady", "OnWindowManagementReady", self)
		
	self.Toggle = function() self.wndLandMarks:Show(not self.wndLandMarks:IsVisible()) end 
	Apollo.RegisterSlashCommand("landmarks", "Toggle", self)
	Apollo.RegisterSlashCommand("lm",        "Toggle", self)
end

function LandMarks:OnWindowManagementReady()
	Event_FireGenericEvent("WindowManagementAdd", {wnd = self.wndLandMarks, strName = "LandMarks"})
end

function LandMarks:OnLandMarkSelect(wndHandler, wndControl, eMouseButton)
	if eMouseButton == GameLib.CodeEnumInputMouse.Right then
		wndControl:SetCheck(false)
		self:DestroyLandMark(wndControl:GetData().sprite)
	else
		Apollo.SetConsoleVariable("player.clickToMove",true)
		if wndControl:IsChecked() then self.lmActive = wndControl:GetData() else self.lmActive = nil end
	end
end