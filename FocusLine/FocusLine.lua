-----------------------------------------------------------------------------------------------
-- FocusLine
--- Vim <Codex>
 
FocusLine = {
	version = "0.1",
	tStyle = {
		nLineWidth = 3,
		crLineColor = ApolloColor.new(0/255, 160/255,  200/255):ToTable(),
		bOutline = true,
	},
	tTrackedUnits = {}
} 

function FocusLine:OnLoad()
	Apollo.RegisterEventHandler("UnitCreated", "OnUnitCreated", self)
	Apollo.RegisterSlashCommand("fline", "OnSlashCommand", self)
	Apollo.RegisterSlashCommand("focusline", "OnSlashCommand", self)
end

function FocusLine:OnSlashCommand(strCmd, strArg)
	local unit = GameLib.GetTargetUnit()
	if unit and unit:IsValid() then
		local tUnit = self.tTrackedUnits[unit:GetName()]
		if tUnit then
			DrawLib:Destroy(tUnit)
			self.tTrackedUnits[unit:GetName()] = nil
		else
			self.tTrackedUnits[unit:GetName()] = DrawLib:UnitLine(GameLib.GetPlayerUnit(), unit, self.tStyle)
		end
	end
end

function FocusLine:OnUnitCreated(unit)
	local tUnit = self.tTrackedUnits[unit:GetName()]
	if tUnit then
		DrawLib:Destroy(tUnit)
		self.tTrackedUnits[unit:GetName()] = DrawLib:UnitLine(GameLib.GetPlayerUnit(), unit, self.tStyle)
	end
end

Apollo.RegisterAddon(FocusLine)