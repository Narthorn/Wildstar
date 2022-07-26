--- TODO
--
--- 

function LandMarks:InitGroup()
	for i = 1, GroupLib.GetMemberCount() do
		groupmember = GroupLib.GetGroupMember(i)
		self.tMembers[groupmember.strCharacterName] = true
	end
	self:Ping()
end

function LandMarks:IsLeader(name)
	for i = 1, GroupLib.GetMemberCount() do
		groupmember = GroupLib.GetGroupMember(i)
		if groupmember.strCharacterName == name and groupmember.bIsLeader then
			return true
		end
	end
	return false
end

function LandMarks:OnICCommMessageReceived(channel, message, sender)
	if message.ping then
		if self.tMembers[sender] and GroupLib.AmILeader() then
			self:Send()
		end
	elseif message.landmarks and self:IsLeader(sender) then
		self:Update(message.landmarks, message.paths)
	end
end

function LandMarks:Send() self.channel:SendMessage({landmarks = self.tLandMarks}) end
function LandMarks:Ping() self.channel:SendMessage({ping = true}) end

function LandMarks:OnGroup_Add(name)    self.tMembers[name] = true end
function LandMarks:OnGroup_Remove(name) self.tMembers[name] = nil end
function LandMarks:OnGroup_Left()       self.tMembers = {} end
function LandMarks:OnGroup_Join()       self:Ping() end