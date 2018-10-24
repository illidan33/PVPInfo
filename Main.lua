PVPInfo = LibStub("AceAddon-3.0"):NewAddon("PVPInfo", "AceConsole-3.0", "AceEvent-3.0")
-- local Module = PVPInfo:NewModule("Config", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("PVPInfo")
local Input
local Channel
local PVPScore_Frame = CreateFrame("Frame")

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
                return self.db.profile.showDuel
            end,
            set = function(info, value)
                self.db.profile.showDuel = value or nil
            end,
        },
        showArena = {
            type = "toggle",
            name = L["showArena"],
            desc = L["toggleArena"],
            get = function(info)
                return self.db.profile.showArena
            end,
            set = function(info, value)
                self.db.profile.showArena = value or nil
            end,
        },
        showRating = {
            type = "toggle",
            name = L["showRatingBattleground"],
            desc = L["toggleRatingBattleground"],
            get = function(info)
                return self.db.profile.showRatingBattleground
            end,
            set = function(info, value)
                self.db.profile.showRatingBattleground = value or nil
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
    cache = {},
}

function PVPInfo:OnInitialize()
    -- Called when the addon is loaded
    self.db = LibStub("AceDB-3.0"):New("PVPInfoDB", defaults, true)

    LibStub("AceConfig-3.0"):RegisterOptionsTable("PVPInfo", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("PVPInfo", "PVPInfo")
    self:RegisterChatCommand("pi", "ChatCommand")
    self:RegisterChatCommand("pvpinfo", "ShowConfig")
    self:RegisterChatCommand("pitest", "ShowConfig")
end

function PVPInfo:OnEnable()
    -- Called when the addon is enabled
    self:RegisterEvent("ZONE_CHANGED")
end

function PVPInfo:ZONE_CHANGED()
    self:Print(GetSubZoneText())
    displayStarOfTargetOnNameBar()
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
    local table = {}

    local target = ""
    if UnitIsPlayer("target") ~= true then
        target = "player"
    else
        target = "target"
    end

    --NotifyInspect(target) --设置观察目标
    --RequestInspectHonorData() --请求该目标PVP数据

    table["unitName"], table["unitRealName"] = UnitName(target)
    table["unitLevel"] = UnitLevel(target)
    table["unitFactionGroup"], table["unitFaction"] = UnitFactionGroup(target)
    table["unitRace"] = UnitRace(target)
    table["unitClass"], table["unitClassFileName"] = UnitClass(target)

    if table["unitRealName"] == nil then
        table["unitRealName"] = GetRealmName()
    end

    --ClearInspectPlayer()

    SetAchievementComparisonUnit(target) --设置要比较的单位

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
    end

    local arenaLose = arenaSum - arenaWin

    local arenaRatio = 0
    if arenaSum == 0 then
        arenaRatio = 0
    else
        arenaRatio = arenaWin / arenaSum
    end

    local ArenaRating_3v3 = GetComparisonStatistic(595)
    if ArenaRating_3v3 == "--" then
        ArenaRating_3v3 = 0
    end

    local ArenaRating_2v2 = GetComparisonStatistic(370)
    if ArenaRating_2v2 == "--" then
        ArenaRating_2v2 = 0
    end

    local arenaScore = 0
    if arenaSum < 100 then
        arenaScore = arenaRatio * 100 / 10
    else
        arenaScore = arenaRatio * 100
    end

    -- Rating Battleground -- 评级战场
    local RatingBattlegroundSum = GetComparisonStatistic(5692)
    if RatingBattlegroundSum == "--" then
        RatingBattlegroundSum = 0
    end

    local RatingBattlegroundWin = GetComparisonStatistic(5694)
    if RatingBattlegroundWin == "--" then
        RatingBattlegroundWin = 0
    end

    local RatingBattlegroundLose = RatingBattlegroundSum - RatingBattlegroundWin

    local RatingBattlegroundRatio = 0
    if RatingBattlegroundSum == 0 then
        RatingBattlegroundRatio = 0
    else
        RatingBattlegroundRatio = RatingBattlegroundWin / RatingBattlegroundSum
    end

    local RatingBattlegroundScore = 0
    if RatingBattlegroundSum < 100 then
        RatingBattlegroundScore = RatingBattlegroundRatio * 100 / 10
    else
        RatingBattlegroundScore = RatingBattlegroundRatio * 100
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
    table["ArenaRating_2v2"] = ArenaRating_2v2
    table["ArenaRating_3v3"] = ArenaRating_3v3
    table["arenaRatio"] = arenaRatio
    table["arenaScore"] = arenaScore

    table["ratingBattlegroundSum"] = RatingBattlegroundSum
    table["ratingBattlegroundWin"] = RatingBattlegroundWin
    table["ratingBattlegroundLose"] = RatingBattlegroundLose
    table["ratingBattlegroundRatio"] = RatingBattlegroundRatio
    table["ratingBattlegroundScore"] = RatingBattlegroundScore

    table["totalScore"] = totalScore
    table["pvpStar"] = pvpStar
    table["allKills"] = allKills

    ClearAchievementComparisonUnit()

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

function DisplayInformationOfTargetInMessage(displayFunc, channel)
    local pvpinfo = calculateScore()
    local separator = " "

    displayFunc("PVPScore: " .. pvpinfo["unitName"] .. "-" .. pvpinfo["realName"] .. separator .. L["textLevel"] .. separator .. pvpinfo["unitLevel"] .. separator .. pvpinfo["unitRace"] .. separator .. pvpinfo["unitClass"], channel)
    if self.db.profile.showDuel then
        local textDuel = string.format("%s%s%s%d/%d%s%s%.2f%", L["textDule"], separator, L["textDuelWinLose"], pvpinfo["duelWin"], pvpinfo["duelLose"], separator, L["textDuelWinRate"], pvpinfo["duelWinRate"] * 100)
        displayFunc(textDuel, channel)
        displayFunc(L["textAllKills"] .. separator .. pvpinfo["allKills"], channel)
    end
    if self.db.profile.showArena then
        local textDuel = string.format("%s%s%s%d/%d%s%s%.2f%", L["textArena"], separator, L["textArenaWinLose"], pvpinfo["arenaWin"], pvpinfo["arenaLose"], separator, L["textArenaWinRate"], pvpinfo["arenaWinRate"] * 100)
        displayFunc(textDuel, channel)
        displayFunc(Text_HighestArenaRating .. "2v2:" .. PVPScore_ArenaRating_2v2 .. "  3v3:" .. PVPScore_ArenaRating_3v3, channel)
    end
    if self.db.profile.showRatingBattleground then
        local textDuel = string.format("%s%s%s%d/%d%s%s%.2f%", L["textRatingBattleground"], separator, L["textRatingBattlegroundWinLose"], pvpinfo["ratingBattlegroundWin"], pvpinfo["ratingBattlegroundLose"], separator, L["textRatingBattlegroundWinRate"], pvpinfo["ratingBattlegroundWinRate"] * 100)
        displayFunc(textDuel, channel)
    end
    displayFunc(L["pvpScore"] .. " <" .. string.format("%.1f", pvpinfo["totalScore"]) .. "> " .. pvpinfo["pvpStar"], channel)
end

function SlashCommands(input)
    input = string.lower(input)

    local channel = ""
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
    if input == "" then
        channel = ""
    end
    if input == "s" or input == "e" or input == "y" or input == "p" or input == "r" or input == "i" or input == "g" or input == "" then
        if channel == "" then
            DisplayScoreofTargetInMessage(SendChatMessage, channel)
        else
            DisplayScoreofTargetInMessage(print, channel)
        end
    elseif input == "cc" then
        self.db.cache = {}
    else
        print("|cff00ff00PVPScore Help:|r")
        print("|cffffff00/ps|r - " .. L["default"])
        print("|cffffff00/ps s|r - " .. L["say"])
        print("|cffffff00/ps e|r - " .. L["emote"])
        print("|cffffff00/ps y|r - " .. L["yell"])
        print("|cffffff00/ps p|r - " .. L["party"])
        print("|cffffff00/ps r|r - " .. L["raid"])
        print("|cffffff00/ps g|r - " .. L["guild"])
        print("|cffffff00/ps i|r - " .. L["intance"])
        print("|cffffff00/ps cc|r - " .. L["clearCache"])
    end
end