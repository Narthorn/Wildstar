--- TODO
--
--- Test other Vector3 interpolation methods
--- Fix WorldLocToScreenPoint outside-of-screen bugging
--- Allow re-interpolation of path with fewer points based on distance to player
--- path simplification

function LandMarks:CalcCircleVectors()
	local tVectors = {}
	for i=0,self.nCircleSides-1 do
		local angle = 2*i*math.pi/self.nCircleSides
		tVectors[i+1] = Vector3.New(math.cos(angle), 0, math.sin(angle))
	end
	return tVectors
end

function LandMarks:DrawLine(vA, vB)
	local pA = GameLib.WorldLocToScreenPoint(vA)
	local pB = GameLib.WorldLocToScreenPoint(vB)
	self.wndOverlay:AddPixie({bLine = true, fWidth = self.nLineWidth, cr = self.crLineColor, loc = { nOffsets = { pA.x, pA.y, pB.x, pB.y } } })
end

function LandMarks:DrawPath(tPath, bClosed)
	for i=1,#tPath-1 do self:DrawLine(tPath[i],tPath[i+1]) end
	if bClosed then self:DrawLine(tPath[#tPath],tPath[1]) end
end

function LandMarks:DrawCircle(vPos, fRadius)
	local tVectors = {}
	for i=1,self.nCircleSides do tVectors[i] = vPos + self.vCircle[i]*fRadius  end
	self:DrawPath(tVectors, true)
end

function LandMarks:CurvePath(tPath)
	local tCurvedPath = {}
	for i=0,#tPath-2 do
		local vA = (i>0) and tPath[i] or tPath[i+1]
		local vB = tPath[i+1]
		local vC = tPath[i+2]
		local vD = (i<#tPath-2) and tPath[i+3] or tPath[i+2]
		for j=1,10 do tCurvedPath[10*i+j] = Vector3.InterpolateCatmullRom(vA,vB,vC,vD,j/10)	end
	end
	return tCurvedPath
end

local function GetSqDistanceToSeg(vP,vA,vB)
	local vC = vA
	if vA ~= vB then 
		local vDir = vB - vA
		local fSqLen = vDir:LengthSq()
		local t = Vector3.Dot(vDir, vP - vA) / fSqLen
		if t > 1 then vC = vB elseif t > 0 then vC = vA + vDir*t end
	end
	return (vP-vC):LengthSq()
end

function LandMarks:SimplifyPath(tPath, fTolerance) -- Ramer-Douglas-Peucker 
	local tSimplePath = {}
	local tMarkers = {[1] = true, [#tPath] = true}
	local index

	local tStack = {#tPath, 1}
	
	while #tStack > 0 do
	
		local maxDist = 0
	
		local first = tStack[#tStack]
		tStack[#tStack] = nil
		local last = tStack[#tStack]
		tStack[#tStack] = nil
	
		for i=first+1,last-1 do
			local SqDist = GetSqDistanceToSeg(tPath[i],tPath[first],tPath[last])
			if SqDist > maxDist then
				maxDist = SqDist
				index = i
			end
		end
		
		if maxDist > fTolerance then
			tMarkers[index] = true
			tStack[#tStack+1] = last
			tStack[#tStack+1] = index
			tStack[#tStack+1] = index
			tStack[#tStack+1] = first
		end
		
	end
	
	for i=1,#tPath do
		if tMarkers[i] then
			tSimplePath[#tSimplePath+1] = tPath[i]
		end
	end
	
	return tSimplePath
end