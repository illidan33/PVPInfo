PVPInfo = LibStub("AceAddon-3.0"):NewAddon("PVPInfo", "AceConsole-3.0", "AceEvent-3.0")
-- local Module = PVPInfo:NewModule("Config", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("PVPInfo")
-- local MessageWay = nil
local CalculateWorking = false

local options = {
    name = "|cffDDA0DDPVPInfo|r",
    handler = PVPInfo,
    type = "group",
    args = {
        ResetToDefault = {
            type = "execute",
            name = L["execute"],
            order = 1,
            func = function()
                ReloadUI()
            end,
        },

        showDuel = {
            type = "toggle",
            name = L["showDuel"],
            desc = L["toggleDuel"],
            get = function(info)
                return PVPInfo.db.profile.showDuel
            end,
            set = function(info, value)
                PVPInfo.db.profile.showDuel = value or nil
            end,
        },
        showArena = {
            type = "toggle",
            name = L["showArena"],
            desc = L["toggleArena"],
            get = function(info)
                return PVPInfo.db.profile.showArena
            end,
            set = function(info, value)
                PVPInfo.db.profile.showArena = value or nil
            end,
        },
        showRating = {
            type = "toggle",
            name = L["showRatingBattleground"],
            desc = L["toggleRatingBattleground"],
            get = function(info)
                return PVPInfo.db.profile.showRatingBattleground
            end,
            set = function(info, value)
                PVPInfo.db.profile.showRatingBattleground = value or nil
            end,
        },
    },
}

local defaults = {
    profile = {
        showDuel = true,
        showArena = false,
        showRatingBattleground = false,
    },
}

function PVPInfo:OnInitialize()
    -- Called when the addon is loaded
    self.db = LibStub("AceDB-3.0"):New("PVPInfoDB", defaults, true)

    LibStub("AceConfig-3.0"):RegisterOptionsTable("PVPInfo", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("PVPInfo", "PVPInfo")
    self:RegisterChatCommand("pi", "ChatCommand")
    self:RegisterChatCommand("pvpinfo", "ShowConfig")
    self:RegisterChatCommand("pis", "MessageToSay")
    self:RegisterChatCommand("pip", "MessageToPrint")
end

function PVPInfo:OnEnable()
    -- Called when the addon is enabled
    self:RegisterEvent("ZONE_CHANGED")
end

function PVPInfo:ZONE_CHANGED()
    self:Print(GetSubZoneText())
    DisplayStarOfTargetOnNameBar()
end

function PVPInfo:ShowConfig()
    LibStub("AceConfigDialog-3.0"):SetDefaultSize("PVPInfo", 800, 600)
    LibStub("AceConfigDialog-3.0"):Open("PVPInfo")
end

function PVPInfo:ChatCommand(input)
    if not input or input:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    else
        LibStub("AceConfigCmd-3.0"):HandleCommand("pi", "PVPInfo", input)
    end
end

function CalculateScore()
    if CalculateWorking == true then
        return
    end

    -- start calculate
    CalculateWorking = true
    local table = {}

    local target = ""
    if UnitIsPlayer("target") then
        target = "target"
    else
        target = "player"
    end

    NotifyInspect(target) --设置观察目标
    RequestInspectHonorData() --请求该目标PVP数据
    SetAchievementComparisonUnit(target) --设置要比较的单位

    table["unitName"], table["unitRealName"] = UnitName(target)
    table["unitLevel"] = UnitLevel(target)
    table["unitFactionGroup"], table["unitFaction"] = UnitFactionGroup(target)
    table["unitRace"] = UnitRace(target)
    table["unitClass"], table["unitClassFileName"] = UnitClass(target)

    if table["unitRealName"] == nil then
        table["unitRealName"] = GetRealmName()
    end


    -- Duel -- 决斗
    local duelWin = GetComparisonStatistic(319)
    if duelWin == "--" then
        duelWin = 0
    end

    local duelLose = GetComparisonStatistic(320)
    if duelLose == "--" then
        duelLose = 0
    end

    local duelSum = duelWin + duelLose

    local duelWinRate = 0
    if duelSum == 0 then
        duelWinRate = 0
    else
        duelWinRate = duelWin / duelSum
    end

    local duelScore = 0
    if duelSum < 100 then
        duelScore = duelWinRate * 100 / 10
    else
        duelScore = duelWinRate * 100
    end

    -- Arena -- 竞技场
    local arenaWin = GetComparisonStatistic(837)
    if arenaWin == "--" then
        arenaWin = 0
    end

    local arenaSum = GetComparisonStatistic(838)
    if arenaSum == "--" then
        arenaSum = 0
    else
        arenaSum = tonumber(arenaSum)
    end

    local arenaLose = arenaSum - arenaWin

    local arenaWinRate = 0
    if arenaSum == 0 then
        arenaWinRate = 0
    else
        arenaWinRate = arenaWin / arenaSum
    end

    local arenaRating_3v3 = GetComparisonStatistic(595)
    if arenaRating_3v3 == "--" then
        arenaRating_3v3 = 0
    end

    local arenaRating_2v2 = GetComparisonStatistic(370)
    if arenaRating_2v2 == "--" then
        arenaRating_2v2 = 0
    end

    local arenaScore = 0
    if arenaSum < 100 then
        arenaScore = arenaWinRate * 100 / 10
    else
        arenaScore = arenaWinRate * 100
    end

    -- Rating Battleground -- 评级战场
    local RatingBattlegroundSum = GetComparisonStatistic(5692)
    if RatingBattlegroundSum == "--" then
        RatingBattlegroundSum = 0
    else
        RatingBattlegroundSum = tonumber(RatingBattlegroundSum)
    end

    local RatingBattlegroundWin = GetComparisonStatistic(5694)
    if RatingBattlegroundWin == "--" then
        RatingBattlegroundWin = 0
    end

    local RatingBattlegroundLose = RatingBattlegroundSum - RatingBattlegroundWin

    local ratingBattlegroundWinRate = 0
    if RatingBattlegroundSum == 0 then
        ratingBattlegroundWinRate = 0
    else
        ratingBattlegroundWinRate = RatingBattlegroundWin / RatingBattlegroundSum
    end

    local RatingBattlegroundScore = 0
    if RatingBattlegroundSum < 100 then
        RatingBattlegroundScore = ratingBattlegroundWinRate * 100 / 10
    else
        RatingBattlegroundScore = ratingBattlegroundWinRate * 100
    end

    -- Kills -- 击杀总数
    local Honorable_Kills = GetComparisonStatistic(588)
    if Honorable_Kills == "--" then
        Honorable_Kills = 0
    end

    local Arena_Kills = GetComparisonStatistic(1490)
    if Arena_Kills == "--" then
        Arena_Kills = 0
    end

    local Battleground_Kills = GetComparisonStatistic(1491)
    if Battleground_Kills == "--" then
        Battleground_Kills = 0
    end

    local allKills = Honorable_Kills + Arena_Kills + Battleground_Kills

    -- Total Score -- 总评分
    local totalScore = duelScore + arenaScore + RatingBattlegroundScore

    local pvpStar = ""
    if totalScore >= 250 then
        pvpStar = "★★★★★"
    elseif totalScore >= 225 then
        pvpStar = "★★★★☆"
    elseif totalScore >= 200 then
        pvpStar = "★★★★"
    elseif totalScore >= 175 then
        pvpStar = "★★★☆"
    elseif totalScore > 150 then
        pvpStar = "★★★"
    elseif totalScore > 125 then
        pvpStar = "★★☆"
    elseif totalScore > 100 then
        pvpStar = "★★"
    elseif totalScore > 75 then
        pvpStar = "★☆"
    elseif totalScore > 50 then
        pvpStar = "★"
    elseif totalScore > 25 then
        pvpStar = "☆"
    else
        pvpStar = "?"
    end

    table["duelSum"] = duelSum
    table["duelWin"] = duelWin
    table["duelLose"] = duelLose
    table["duelWinRate"] = duelWinRate
    table["duelScore"] = duelScore

    table["arenaSum"] = arenaSum
    table["arenaWin"] = arenaWin
    table["arenaLose"] = arenaLose
    table["arenaRating_2v2"] = arenaRating_2v2
    table["arenaRating_3v3"] = arenaRating_3v3
    table["arenaWinRate"] = arenaWinRate
    table["arenaScore"] = arenaScore

    table["ratingBattlegroundSum"] = RatingBattlegroundSum
    table["ratingBattlegroundWin"] = RatingBattlegroundWin
    table["ratingBattlegroundLose"] = RatingBattlegroundLose
    table["ratingBattlegroundWinRate"] = ratingBattlegroundWinRate
    table["ratingBattlegroundScore"] = RatingBattlegroundScore

    table["totalScore"] = totalScore
    table["pvpStar"] = pvpStar
    table["allKills"] = allKills

    ClearAchievementComparisonUnit()
    ClearInspectPlayer()
    CalculateWorking = false

    return table
end

function DisplayStarOfTargetOnNameBar()
    local pvpinfo = CalculateScore()
    if pvpinfo ~= nil then
        TatgetPVPScore = TargetFrame:CreateFontString("TatgetPVPScore")
        TatgetPVPScore:SetFont("Fonts\\ARKai_T.TTF", 13, 'OUTLINE')
        TatgetPVPScore:SetText(pvpinfo.pvpStar)
        TatgetPVPScore:SetPoint("TOPLEFT", TargetFrame, "LEFT", 7, 45)
    end
end

function DisplayInformationOfTargetInMessage(channel)
    local pvpinfo = CalculateScore()
    local separator = "  "

    SendChatMessage("PVPInfo: " .. pvpinfo["unitName"] .. "-" .. pvpinfo["unitRealName"] .. separator .. L["textLevel"] .. "(" .. pvpinfo["unitLevel"] .. ")" .. separator .. pvpinfo["unitRace"] .. separator .. pvpinfo["unitClass"], channel)
    if PVPInfo.db.profile.showDuel then
        SendChatMessage(L["textDule"] .. " = " .. L["textDuelWinLose"] .. ": " .. pvpinfo["duelWin"] .. "/" .. pvpinfo["duelLose"] .. separator .. L["textDuelWinRate"] .. ": " .. string.format("%.1f", pvpinfo["duelWinRate"] * 100), channel)
        SendChatMessage(L["textAllKills"] .. ": " .. pvpinfo["allKills"], channel)
    end
    if PVPInfo.db.profile.showArena then
        SendChatMessage(L["textArena"] .. " = " .. L["textArenaWinLose"] .. ": " .. pvpinfo["arenaWin"] .. "/" .. pvpinfo["arenaLose"] .. separator .. L["textArenaWinRate"] .. ": " .. string.format("%.1f", pvpinfo["arenaWinRate"] * 100), channel)
        SendChatMessage(L["highestArenaRating"] .. " 2v2:" .. pvpinfo["arenaRating_2v2"] .. "  3v3:" .. pvpinfo["arenaRating_3v3"], channel)
    end
    if PVPInfo.db.profile.showRatingBattleground then
        SendChatMessage(L["textRatingBattleground"] .. " = " .. L["textRatingBattlegroundWinLose"] .. ": " .. pvpinfo["ratingBattlegroundWin"] .. "/" .. pvpinfo["ratingBattlegroundLose"] .. separator .. L["textRatingBattlegroundWinRate"] .. ": " .. string.format("%.1f", pvpinfo["ratingBattlegroundWinRate"] * 100), channel)
    end
    SendChatMessage(L["pvpScore"] .. " <" .. string.format("%.1f", pvpinfo["totalScore"]) .. "> " .. pvpinfo["pvpStar"], channel)
end

function PVPInfo:MessageToPrint()
    local pvpinfo = CalculateScore()
    local separator = "  "

    print("PVPInfo: " .. pvpinfo["unitName"] .. "-" .. pvpinfo["unitRealName"] .. separator .. L["textLevel"] .. "(" .. pvpinfo["unitLevel"] .. ")" .. separator .. pvpinfo["unitRace"] .. separator .. pvpinfo["unitClass"])
    if PVPInfo.db.profile.showDuel then
        print(L["textDule"] .. " = " .. L["textDuelWinLose"] .. ": " .. pvpinfo["duelWin"] .. "/" .. pvpinfo["duelLose"] .. separator .. L["textDuelWinRate"] .. ": " .. string.format("%.1f", pvpinfo["duelWinRate"] * 100))
        print(L["textAllKills"] .. ": " .. pvpinfo["allKills"])
    end
    if PVPInfo.db.profile.showArena then
        print(L["textArena"] .. " = " .. L["textArenaWinLose"] .. ": " .. pvpinfo["arenaWin"] .. "/" .. pvpinfo["arenaLose"] .. separator .. L["textArenaWinRate"] .. ": " .. string.format("%.1f", pvpinfo["arenaWinRate"] * 100))
        print(L["highestArenaRating"] .. " 2v2:" .. pvpinfo["arenaRating_2v2"] .. "  3v3:" .. pvpinfo["arenaRating_3v3"])
    end
    if PVPInfo.db.profile.showRatingBattleground then
        print(L["textRatingBattleground"] .. " = " .. L["textRatingBattlegroundWinLose"] .. ": " .. pvpinfo["ratingBattlegroundWin"] .. "/" .. pvpinfo["ratingBattlegroundLose"] .. separator .. L["textRatingBattlegroundWinRate"] .. ": " .. string.format("%.1f", pvpinfo["ratingBattlegroundWinRate"] * 100))
    end
    print(L["pvpScore"] .. " <" .. string.format("%.1f", pvpinfo["totalScore"]) .. "> " .. pvpinfo["pvpStar"])
end

function PVPInfo:MessageToSay()
    local channel = ""
    local input = ""
    if input == "s" then
        channel = "SAY"
    end
    if input == "e" then
        channel = "EMOTE"
    end
    if input == "y" then
        channel = "YELL"
    end
    if input == "p" then
        channel = "PARTY"
    end
    if input == "r" then
        channel = "RAID"
    end
    if input == "i" then
        channel = "INSTANCE_CHAT"
    end
    if input == "g" then
        channel = "GUILD"
    end

    DisplayInformationOfTargetInMessage("SAY")
end



