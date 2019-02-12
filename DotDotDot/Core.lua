DotDotDot = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "AceDB-2.0", "CandyBar-2.0")

local DotDotDot = DotDotDot

local VERSION = tonumber(("$Revision: 74120$"):match("%d+"))
DotDotDot.revision = VERSION
DotDotDot.versionstring = "1.13 |cffff8888r%d|r"
DotDotDot.version = DotDotDot.versionstring:format(VERSION)
DotDotDot.date = ("$Date$"):match("%d%d%d%d%-%d%d%-%d%d")

local BS = AceLibrary("Babble-Spell-2.2")
local L = AceLibrary("AceLocale-2.2"):new("DotDotDot")
local media = AceLibrary:HasInstance("SharedMedia-1.0") and AceLibrary("SharedMedia-1.0") or { Fetch = function() return "Interface\\Addons\\DotDotDot\\textures\\default" end, List = function() return {"BantoBar"} end, Register = function() end, }

local mType = media.MediaType and media.MediaType.STATUSBAR or "statusbar"
local CandyBar = AceLibrary("CandyBar-2.0")

L:RegisterTranslations("enUS", function() return {
	["Show Anchor"] = true,
	["Show the Anchor for moving the Bars"] = true,
	["Grow Up"] = true,
	["Toggle Grow Up of the Bars"] = true,
	["Bar scale"] = true,
	["Set the scale of the bars"] = true,
	["Texture"] = true,
	["Set the texture for the bars."] = true,
	["Reverse"] = true,
	["Toggle Bar Reversal"] = true,
	["Window length"] = true,
	["Set the length of window time"] = true,
	['CoE'] = true,
	['CoW'] = true,
	['CoS'] = true,
	['CoR'] = true,
	['VE'] = true,
	['VT'] = true,
	['DP'] = true,
	['SW:P'] = true,
	['Fiend'] = true,
	['CoA'] = true,
	['CoT'] = true,
	['CoEx'] = true,
	['Siphon'] = true,
	['Corr'] = true,
	['CoD'] = true,
	['UA'] = true,
	['Immol'] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["Show Anchor"] = "앵커 보기",
	["Show the Anchor for moving the Bars"] = "바의 이동을 위한 앵커 보여줍니다.",
	["Grow Up"] = "위로 생성",
	["Toggle Grow Up of the Bars"] = "바의 생성방향을 전환합니다.",
	["Bar scale"] = "바 크기",
	["Set the scale of the bars"] = "바의 크기를 설정합니다.",
	["Texture"] = "텍스쳐",
	["Set the texture for the bars."] = "텍스쳐를 설정합니다.",
	["Reverse"] = "반전",
	["Toggle Bar Reversal"] = "바의 반전을 전환합니다.",
	["Window length"] = "창 길이",
	["Set the length of window time"] = "창 시간의 길이를 설정합니다.",
	['CoE'] = "원소",
	['CoW'] = "무력화",
	['CoS'] = "어둠",
	['CoR'] = "무모함",
	['VE'] = "흡선",
	['VT'] = "흡손",
	['DP'] = "파멸역병",
	['SW:P'] = "어둠:고통",
	['Fiend'] = "마귀",
	['CoA'] = "고통",
	['CoT'] = "언어",
	['CoEx'] = "피로",
	['Siphon'] = "생착",
	['Corr'] = "부패",
	['CoD'] = "파멸",
	['UA'] = "불고",
	['Immol'] = "제물",
} end)

function DotDotDot:OnInitialize()
	self:RegisterDB("DotDotDotDB")
	self:RegisterDefaults("profile", {
		growup = false,
		texture = "BantoBar",
		scale = 1.0,
		window = 60,
        basecolor = "green",
        highcolor = "red",
        basealpha = 0.75,
        highalpha = 1
	})
	media:Register(mType, "BantoBar", "Interface\\Addons\\DotDotDot\\textures\\default")
	
    self.playerguid = UnitGUID("player")
    
	self.options = {
		type = "group",
		args = {
			anchor = {
				name = L["Show Anchor"],
				desc = L["Show the Anchor for moving the Bars"],
				type = "execute",
				func = "ShowAnchors",
			},
			growup = {
				name = L["Grow Up"],
				desc = L["Toggle Grow Up of the Bars"],
				type = "toggle",
				get = function()
					return self.db.profile.growup
				end,
				set = function(v)
					self.db.profile.growup = v
				end,
			},
			scale = {
				get = function()
					return self.db.profile.scale
				end,
				set = function(v)
					self.db.profile.scale = v
				end,
				min = 0.25, -- some like it small : but not too small!
				max = 2, -- some like it big
				step = 0.05, -- every 5%
				isPercent = true,
				name = L["Bar scale"],
				desc = L["Set the scale of the bars"],
				type = "range",
				func = "SetScale",
			},
			basecolor = {
				type = "text",
				name = "Non-highlighted bar color",
				desc = "Set the color for non-target bars.",
				get = function() return self.db.profile.basecolor end,
				set = function(tex) self.db.profile.basecolor = tex end,
                usage = "<valid color string>"
			},
			highcolor = {
				type = "text",
				name = "Highlighted bar color",
				desc = "Set the color for target bars.",
				get = function() return self.db.profile.highcolor end,
				set = function(tex) self.db.profile.highcolor = tex end,
                usage = "<valid color string>"
            },
			texture = {
				type = "text",
				name = L["Texture"],
				desc = L["Set the texture for the bars."],
				validate = media:List(mType),
				get = function() return self.db.profile.texture end,
				set = function(tex) self.db.profile.texture = tex end,
			},
			reverse = {
				name = L["Reverse"],
				desc = L["Toggle Bar Reversal"],
				type = "toggle",
				get = function()
					return self.db.profile.reverse
				end,
				set = function(v)
					self.db.profile.reverse = v
				end,
			},
			window = {
				get = function()
					return self.db.profile.window
				end,
				set = function(v)
					self.db.profile.window = v
				end,
				min = 5, -- 5s min
				max = 60, -- 1m max
				step = 1, -- by one second
				isPercent = false,
				name = L["Window length"],
				desc = L["Set the length of window time"],
				type = "range",
			},
			window = {
				get = function()
					return self.db.profile.window
				end,
				set = function(v)
					self.db.profile.window = v
				end,
				min = 5, -- 5s min
				max = 60, -- 1m max
				step = 1, -- by one second
				isPercent = false,
				name = L["Window length"],
				desc = L["Set the length of window time"],
				type = "range",
			},
			basealpha = {
				get = function()
					return self.db.profile.basealpha
				end,
				set = function(v)
					self.db.profile.basealpha = v
				end,
				min = 0, -- 5s min
				max = 1, -- 1m max
				step = 0.05, -- by one second
				isPercent = false,
				name = "Non-highlighted bar alpha",
				desc = "Set the alpha for untargeted bars",
				type = "range",
			},
			highalpha = {
				get = function()
					return self.db.profile.highalpha
				end,
				set = function(v)
					self.db.profile.highalpha = v
				end,
				min = 0, -- 5s min
				max = 1, -- 1m max
				step = 0.05, -- by one second
				isPercent = false,
				name = "Highlighted bar alpha",
				desc = "Set the alpha for targeted bars",
				type = "range",
			},
		}
	}
	
	self:RegisterChatCommand({ "/ddd", "/dotdotdot" }, self.options )
	
	-- Poisoning the candy
	local oldCandyBarUpdate = CandyBar.Update 
	CandyBar.Update = function(self, name) 
		oldCandyBarUpdate(self, name) 

        local handler = CandyBar.handlers[name]
        if not handler then
            return
        end

        local t = handler.time - handler.elapsed

        local perc = t / handler.time
		if perc > 1 then -- added
			perc = 1 -- added
		end -- added

        local reversed = handler.reversed
        handler.frame.statusbar:SetValue(reversed and 1-perc or perc)

        local width = handler.width or 200

        local sp = width * perc
        sp = reversed and -sp or sp

        handler.frame.spark:SetPoint("CENTER", handler.frame.statusbar, reversed and "RIGHT" or "LEFT", sp, 0)
    end 

	
	self.shortcode = {
		[BS['Curse of the Elements']] = L['CoE'],
		[BS['Curse of Weakness']] = L['CoW'],
		[BS['Curse of Shadow']] = L['CoS'],
		[BS['Curse of Recklessness']] = L['CoR'],
		[BS['Vampiric Embrace']] = L['VE'],
		[BS['Vampiric Touch']] = L['VT'],
		[BS['Devouring Plague']] = L['DP'],
		[BS['Shadow Word: Pain']] = L['SW:P'],
		[BS['Shadowfiend']] = L['Fiend'],
		[BS['Curse of Agony']] = L['CoA'],
		[BS['Curse of Tongues']] = L['CoT'],
		[BS['Curse of Exhaustion']] = L['CoEx'],
		[BS['Siphon Life']] = L['Siphon'],
		[BS['Corruption']] = L['Corr'],
		[BS['Curse of Doom']] = L['CoD'],
		[BS['Unstable Affliction']] = L['UA'],
		[BS['Immolate']] = L['Immol'],
	}

end

-- local copy of Candy Bar SetTimeLeft function to remove remaining > time check

function DotDotDot:SetTimeLeft(name, time)
	CandyBar:argCheck(name, 2, "string")
	CandyBar:argCheck(time, 3, "number")
	
	local handler = CandyBar.handlers[name]
	if not handler then
		return
	end
		
	local e = handler.time - time
	if handler.starttime and handler.endtime then
		local d = handler.elapsed - e
		handler.starttime = handler.starttime + d
		handler.endtime = handler.endtime + d
	end

	handler.elapsed = e

	if handler.group then
		CandyBar:UpdateGroup(handler.group)
	end		

end


function DotDotDot:OnEnable()
	self:SetupFrames()
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "TargetEvent")
--	self:RegisterBucketEvent("UNIT_AURA", 0.1, "AuraEvent")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "LogEvent")
	local u = self.db.profile.growup
	self:RegisterCandyBarGroup("DotDotDotGroup1")
	self:SetCandyBarGroupPoint("DotDotDotGroup1", u and "BOTTOM" or "TOP", self.frames.anchor, u and "TOP" or "BOTTOM", 0, 0)
	self:SetCandyBarGroupGrowth("DotDotDotGroup1", u)
end

function DotDotDot:RemoveOnDeath(dstGUID)
	local self = DotDotDot;
	for k,v in pairs(self.shortcode) do
		local id = dstGUID .. "-" .. v
		self:UnregisterCandyBar(id)
	end
end

function DotDotDot:RemoveOnDispel(dstGUID,name)
	local self = DotDotDot
    if self.shortcode[name] then
        local id = dstGUID .. "-" .. self.shortcode[name]
        if (self:IsCandyBarRegistered(id)) then
            self:UnregisterCandyBar(id)
        end
    end
end

function DotDotDot:LogEvent(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
	if eventtype == ("UNIT_DIED") then
		self:RemoveOnDeath(dstGUID)
    elseif eventtype == ("SPELL_AURA_APPLIED") then
--        if srcGUID == self.playerguid then  
-- S_A_A doesn't have a fucking srcguid meaning we have to handle ALL aura events
-- leaving this check in just in case someday we get srcguid for SAA
            local tguid = UnitGUID("target")
            local fguid = UnitGUID("focus")
            local mguid = UnitGUID("mouseover")
            if tguid == dstGUID then
                self:UpdateDebuffs("target")
            elseif fguid == dstGUID then
                self:UpdateDebuffs("focus")
            elseif mguid == dstGUID then
                self:UpdateDebuffs("mouseover")
            end
--        end
    elseif eventtype == ("SPELL_AURA_DISPELLED") then
        local a, d, b, c, exname, e, f, g= select(1, ...)
        self:RemoveOnDispel(dstGUID,exname)
            local tguid = UnitGUID("target")
            local fguid = UnitGUID("focus")
            local mguid = UnitGUID("mouseover")
            if tguid == dstGUID then
                self:UpdateDebuffs("target")
            elseif fguid == dstGUID then
                self:UpdateDebuffs("focus")
            elseif mguid == dstGUID then
                self:UpdateDebuffs("mouseover")
            end
    elseif eventtype == ("SPELL_AURA_REMOVED") then
        local a, exname, b, c = select(1, ...)
        self:RemoveOnDispel(dstGUID,exname)
            local tguid = UnitGUID("target")
            local fguid = UnitGUID("focus")
            local mguid = UnitGUID("mouseover")
            if tguid == dstGUID then
                self:UpdateDebuffs("target")
            elseif fguid == dstGUID then
                self:UpdateDebuffs("focus")
            elseif mguid == dstGUID then
                self:UpdateDebuffs("mouseover")
            end
    end
end
		
function DotDotDot:UpdateDebuffs(unit)
	self = DotDotDot
	if (UnitExists(unit)) then
		for num = 1, 40 do
			local name, _, texture, applications, _, duration, timeLeft
			name, _, texture, applications, _, duration, timeLeft = UnitDebuff(unit, num)
			if (duration) then
				if (self.shortcode[name]) then
					guid = (UnitGUID(unit) .. "-" .. self.shortcode[name])
                    if unit == "target" then
                        self:ShowCandyBar(self.shortcode[name].." - "..(UnitName(unit) or ""), guid, timeLeft, BS:GetSpellIcon(name), true, self.db.profile.highcolor)
                    else
                        self:ShowCandyBar(self.shortcode[name].." - "..(UnitName(unit) or ""), guid, timeLeft, BS:GetSpellIcon(name), false, self.db.profile.basecolor)
                    end
				end
			end
		end			
	end
end

function DotDotDot:TargetEvent()
    local group = CandyBar.groups["DotDotDotGroup1"] -- retrieve DDD bars
    local tguid = UnitGUID("target")
	if tguid then
		self:UpdateDebuffs("target") -- update bars for target appropriately
      	for k,v in pairs(group.bars) do -- for each bar in DDD group
            local handler = CandyBar.handlers[v] -- acquire handler
            if handler then -- if acquired
                if handler.frame:IsShown() then -- if shown
                    self:SetCandyBarColor(v,self.db.profile.basecolor,self.db.profile.basealpha) -- set basecolor, reduced alpha
                    if string.sub(v,1,18) == tguid then -- if it's a bar applicable to our current target
                        self:SetCandyBarColor(v,self.db.profile.highcolor,self.db.profile.highalpha) -- set highcolor, full alpha
                    end
                end
            end
        end
    else
      	for k,v in pairs(group.bars) do -- for each bar in DDD group
            local handler = CandyBar.handlers[v] -- acquire handler
            if handler then -- if acquired
                if handler.frame:IsShown() then -- if shown
                    self:SetCandyBarColor(v,self.db.profile.basecolor,self.db.profile.basealpha) -- set basecolor, reduced alpha
                end
            end
        end
    end
end

function DotDotDot:ShowCandyBar(text, id, time, icon, isTarget, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10)
	self = DotDotDot
	local s = self.db.profile.scale
		
	if (not(self:IsCandyBarRegistered(id))) then
		self:RegisterCandyBar(id, self.db.profile.window, text, icon, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10)
		self:SetCandyBarReversed(id, self.db.profile.reverse)
		self:RegisterCandyBarWithGroup(id, "DotDotDotGroup1")
		self:SetCandyBarTexture(id, media:Fetch(mType, self.db.profile.texture))
        if isTarget then
            self:SetCandyBarColor(id,self.db.profile.highcolor,self.db.profile.highalpha) -- set basecolor, basealpha
        else
            self:SetCandyBarColor(id,self.db.profile.basecolor,self.db.profile.basealpha) -- set basecolor, basealpha
        end
		self:SetCandyBarFade(id, 5)
		self:SetCandyBarScale(id, s)
		self:StartCandyBar(id, true)
		self:SetTimeLeft(id, time)
	else
		self:StartCandyBar(id, true)
		self:SetTimeLeft(id, time)
	end
end
