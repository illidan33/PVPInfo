-- app global vars
PVPInfo = LibStub("AceAddon-3.0"):NewAddon("PVPInfo", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("PVPInfo")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AppName = "PVPInfo"
local CalculateWorking
local ScoreTable = {}
local PVPInfoType
local MessageChannel = ""
local TatgetPVPInfo

-- The header for PVPInfo key bindings
BINDING_HEADER_PVPInfo = "PVPInfo";
BINDING_NAME_PVPINFO_PRINT = L["textBindingPrint"]
BINDING_NAME_PVPINFO_SAY = L["textBindingSay"]
BINDING_NAME_PVPINFO_EMOTE = L["textBindingEmote"]
BINDING_NAME_PVPINFO_YELL = L["textBindingYell"]
BINDING_NAME_PVPINFO_PARTY = L["textBindingParty"]
BINDING_NAME_PVPINFO_RAID = L["textBindingRaid"]
BINDING_NAME_PVPINFO_GUILD = L["textBindingGuild"]
BINDING_NAME_PVPINFO_INSTANCE_CHAT = L["textBindingInstanceChat"]

-- default config
local options = {
    name = "|cffDDA0DDPVPInfo|r",
    handler = PVPInfo,
    type = "group",
    args = {
        clearCache = {
            type = "execute",
            name = L["clearCache"],
            order = 1,
            func = function()
                PVPInfo.db.profile.cache = {}
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
                PVPInfo.db.profile.cache = {}
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
                PVPInfo.db.profile.cache = {}
                PVPInfo.db.profile.showArena = value or nil
            end,
        },
        showBattleground = {
            type = "toggle",
            name = L["showBattleground"],
            desc = L["toggleBattleground"],
            get = function(info)
                return PVPInfo.db.profile.showBattleground
            end,
            set = function(info, value)
                PVPInfo.db.profile.cache = {}
                PVPInfo.db.profile.showBattleground = value or nil
            end,
        },
        showRatingBattleground = {
            type = "toggle",
            name = L["showRatingBattleground"],
            desc = L["toggleRatingBattleground"],
            get = function(info)
                return PVPInfo.db.profile.showRatingBattleground
            end,
            set = function(info, value)
                PVPInfo.db.profile.cache = {}
                PVPInfo.db.profile.showRatingBattleground = value or nil
            end,
        },
        showKill = {
            type = "toggle",
            name = L["showKill"],
            desc = L["toggleKill"],
            get = function(info)
                return PVPInfo.db.profile.showKill
            end,
            set = function(info, value)
                PVPInfo.db.profile.cache = {}
                PVPInfo.db.profile.showKill = value or nil
            end,
        },
        showHighArenaLevel = {
            type = "toggle",
            name = L["showHighArenaLevel"],
            desc = L["toggleHighArenaLevel"],
            get = function(info)
                return PVPInfo.db.profile.showHighArenaLevel
            end,
            set = function(info, value)
                PVPInfo.db.profile.cache = {}
                PVPInfo.db.profile.showHighArenaLevel = value or nil
            end,
        },
    },
}

local defaults = {
    profile = {
        showDuel = true,
        showArena = false,
        showBattleground = false,
        showRatingBattleground = false,
        showKills = false,
        showHighArenaLevel = false,
        cache = {},
    },
}

function PVPInfo:OnInitialize()
    -- Called when the addon is loaded
    self.db = LibStub("AceDB-3.0"):New("PVPInfoDB", defaults, true)
    LibStub("AceConfig-3.0"):RegisterOptionsTable(AppName, options, {"pi", "pvpinfo"})
    self.optionsFrame = AceConfigDialog:AddToBlizOptions(AppName, AppName)

    self:RegisterChatCommand("pi", "ChatCommand")
    self:RegisterChatCommand("pvpinfo", "ShowConfig")
end

function PVPInfo:OnEnable()
    -- Called when the addon is enabled
    self:RegisterEvent("ZONE_CHANGED")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("INSPECT_ACHIEVEMENT_READY")
end

function PVPInfo:ZONE_CHANGED()
    self:Print(GetSubZoneText())
end

function PVPInfo:PLAYER_TARGET_CHANGED()
    --self:Print("PLAYER_TARGET_CHANGED")

    if TatgetPVPInfo then
        TatgetPVPInfo:Hide()
    end
    ScoreTable = {} -- clear

    if not UnitIsPlayer("target") then
        return
    end
    if not UnitIsVisible("target") then
        return
    end

    ScoreTable["unitName"], ScoreTable["unitRealName"] = UnitName("target")
    if not ScoreTable["unitRealName"] then
        ScoreTable["unitRealName"] = GetRealmName()
    end

    PVPInfoType = "nameBar"
    local unitInfo = GetUnitFromCache(ScoreTable["unitName"] .. "-" .. ScoreTable["unitRealName"])
    if unitInfo then
        ScoreTable = unitInfo
        DisplayPVPInfo()
    else
        SetAchievementComparisonUnit("target")
    end
end

function PVPInfo:ShowConfig()
    AceConfigDialog:SetDefaultSize(AppName, 800, 600)
    AceConfigDialog:Open(AppName)
end

function PVPInfo:ChatCommand(input)
    --self:Print("ChatCommand:" .. input)

    if input and input:trim() ~= "" then
        if input == "config" then
            AceConfigDialog:SetDefaultSize(AppName, 800, 600)
            AceConfigDialog:Open(AppName)
            return
        end
        if input == "cc" then
            self.db.profile.cache = {}
            return
        end

        if not UnitIsPlayer("target") then
            return
        end
        if not UnitIsVisible("target") then
            return
        end

        if input == "s" then
            MessageChannel = "SAY"
        end
        if input == "e" then
            MessageChannel = "EMOTE"
        end
        if input == "y" then
            MessageChannel = "YELL"
        end
        if input == "p" then
            MessageChannel = "PARTY"
        end
        if input == "r" then
            MessageChannel = "RAID"
        end
        if input == "i" then
            MessageChannel = "INSTANCE_CHAT"
        end
        if input == "g" then
            MessageChannel = "GUILD"
        end

        if MessageChannel ~= "" then
            PVPInfoType = "message"
        else
            PVPInfoType = "print"
        end

        local unitInfo = GetUnitFromCache(ScoreTable["unitName"] .. "-" .. ScoreTable["unitRealName"])
        if unitInfo then
            ScoreTable = unitInfo
            DisplayPVPInfo()
        else
            SetAchievementComparisonUnit("target")
        end
    else
        Print("|cff00ff00PVPInfo Help:|r")
        Print("|cffffff00/pi|r - " .. L["default"])
        Print("|cffffff00/pi s|r - " .. L["say"])
        Print("|cffffff00/pi r|r - " .. L["emote"])
        Print("|cffffff00/pi y|r - " .. L["yell"])
        Print("|cffffff00/pi p|r - " .. L["party"])
        Print("|cffffff00/pi r|r - " .. L["raid"])
        Print("|cffffff00/pi i|r - " .. L["guild"])
        Print("|cffffff00/pi g|r - " .. L["intanceChat"])
        Print("|cffffff00/pi config|r - " .. L["config"])
        Print("|cffffff00/pi cc|r - " .. L["clearCache"])
    end
end

function PVPInfo:INSPECT_ACHIEVEMENT_READY()
    --self:Print("INSPECT_ACHIEVEMENT_READY")

    CalculateScore()

    DisplayPVPInfo()

    -- clear
    PVPInfoType = ""
    MessageChannel = ""
    ClearAchievementComparisonUnit()
end

-- functions
function DisplayPVPInfo()
    if not UnitIsPlayer("target") then
        return
    end
    if not UnitIsVisible("target") then
        return
    end

    if PVPInfoType == "nameBar" then
        CreateTargetFrame()
    elseif PVPInfoType == "message" then
        DisplayScoreInMessage(MessageChannel)
    else
        DisplayScoreInMessage("")
    end
end

function CalculateScore()
    if CalculateWorking then
        return
    end
    CalculateWorking = 1

    ScoreTable["unitLevel"] = UnitLevel("target")
    ScoreTable["unitFactionGroup"], ScoreTable["unitFaction"] = UnitFactionGroup("target")
    ScoreTable["unitRace"] = UnitRace("target")
    ScoreTable["unitClass"], ScoreTable["unitClassFileName"] = UnitClass("target")

    local sumRatio = 0.6
    local rateRatio = 0.4
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
        duelWinRate = math.ceil((duelWin / duelSum) * 100)
    end

    local duelScore = math.ceil(duelWinRate * sumRatio + (duelSum / 5000 * 100) * rateRatio)
    if duelScore > 100 then
        duelScore = 100
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
        arenaWinRate = math.ceil((arenaWin / arenaSum) * 100)
    end

    local arenaScore = math.ceil(arenaWinRate * sumRatio + (arenaSum / 5000 * 100) * rateRatio)
    if arenaScore > 100 then
        arenaScore = 100
    end

    -- Rating Battleground -- 评级战场
    local ratingBattlegroundSum = GetComparisonStatistic(5692)
    if ratingBattlegroundSum == "--" then
        ratingBattlegroundSum = 0
    else
        ratingBattlegroundSum = tonumber(ratingBattlegroundSum)
    end

    local ratingBattlegroundWin = GetComparisonStatistic(5694)
    if ratingBattlegroundWin == "--" then
        ratingBattlegroundWin = 0
    end

    local ratingBattlegroundLose = ratingBattlegroundSum - ratingBattlegroundWin

    local ratingBattlegroundWinRate = 0
    if ratingBattlegroundSum == 0 then
        ratingBattlegroundWinRate = 0
    else
        ratingBattlegroundWinRate = math.ceil((ratingBattlegroundWin / ratingBattlegroundSum) * 100)
    end

    local ratingBattlegroundScore = math.ceil(ratingBattlegroundWinRate * sumRatio + (ratingBattlegroundSum / 1000 * 100) * rateRatio)
    if ratingBattlegroundScore > 100 then
        ratingBattlegroundScore = 100
    end

    -- Total Score -- 总评分
    local totalScore = duelScore + arenaScore + ratingBattlegroundScore

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

    ScoreTable["duelSum"] = duelSum
    ScoreTable["duelWin"] = duelWin
    ScoreTable["duelLose"] = duelLose
    ScoreTable["duelWinRate"] = duelWinRate
    ScoreTable["duelScore"] = duelScore

    ScoreTable["arenaSum"] = arenaSum
    ScoreTable["arenaWin"] = arenaWin
    ScoreTable["arenaLose"] = arenaLose
    ScoreTable["arenaWinRate"] = arenaWinRate
    ScoreTable["arenaScore"] = arenaScore

    ScoreTable["ratingBattlegroundSum"] = ratingBattlegroundSum
    ScoreTable["ratingBattlegroundWin"] = ratingBattlegroundWin
    ScoreTable["ratingBattlegroundLose"] = ratingBattlegroundLose
    ScoreTable["ratingBattlegroundWinRate"] = ratingBattlegroundWinRate
    ScoreTable["ratingBattlegroundScore"] = ratingBattlegroundScore

    ScoreTable["totalScore"] = totalScore
    ScoreTable["pvpStar"] = pvpStar

    local arenaRating_3v3 = 0
    local arenaRating_2v2 = 0
    if PVPInfo.db.profile.showHighArenaLevel then
        -- highArenaLeve -- 最高竞技场等级
        arenaRating_3v3 = GetComparisonStatistic(595)
        if arenaRating_3v3 == "--" then
            arenaRating_3v3 = 0
        end

        arenaRating_2v2 = GetComparisonStatistic(370)
        if arenaRating_2v2 == "--" then
            arenaRating_2v2 = 0
        end

        ScoreTable["arenaRating_2v2"] = arenaRating_2v2
        ScoreTable["arenaRating_3v3"] = arenaRating_3v3
        --ScoreTable["battlegroundRating"] = ""

        --local name, isFinish, time, earnBy = GetHighestBattlegroundLevel()
        --if isFinish == true then
        --    ScoreTable["battlegroundRating"] = name .. ": " .. time .. "-" .. earnBy
        --end
        --print(ScoreTable["battlegroundRating"])
    end
    local honorableKills = 0
    local arenaKills = 0
    local battlegroundKills = 0
    if PVPInfo.db.profile.showKill then
        -- Kills -- 击杀总数
        honorableKills = GetComparisonStatistic(588)
        if honorableKills == "--" then
            honorableKills = 0
        end

        arenaKills = GetComparisonStatistic(1490)
        if arenaKills == "--" then
            arenaKills = 0
        end

        battlegroundKills = GetComparisonStatistic(1491)
        if battlegroundKills == "--" then
            battlegroundKills = 0
        end

        ScoreTable["honorableKills"] = honorableKills
        ScoreTable["allKills"] = arenaKills + battlegroundKills
        ScoreTable["arenaKills"] = arenaKills
        ScoreTable["battlegroundKills"] = battlegroundKills
    end

    local battlegroundSum = 0
    local battlegroundWin = 0
    local battlegroundLose = 0
    local battlgroundWinRate = 0
    if PVPInfo.db.profile.showBattleground then
        -- Battleground -- 战场
        battlegroundSum = GetComparisonStatistic(839)
        if battlegroundSum == "--" then
            battlegroundSum = 0
        end

        battlegroundWin = GetComparisonStatistic(840)
        if battlegroundWin == "--" then
            battlegroundWin = 0
        end

        battlegroundLose = battlegroundSum - battlegroundWin
        battlgroundWinRate = 0
        if battlegroundSum == 0 then
            battlgroundWinRate = 0
        else
            battlgroundWinRate = math.ceil((battlegroundWin / battlegroundSum) * 100)
        end

        ScoreTable["battlegroundSum"] = battlegroundSum
        ScoreTable["battlegroundWin"] = battlegroundWin
        ScoreTable["battlegroundLose"] = battlegroundLose
        ScoreTable["battlegroundWinRate"] = battlgroundWinRate
    end

    table.insert(PVPInfo.db.profile.cache, {
        unitFlag = ScoreTable["unitName"] .. "-" .. ScoreTable["unitRealName"],
        unitName = ScoreTable["unitName"],
        unitRealName = ScoreTable["unitRealName"],
        unitLevel = ScoreTable["unitLevel"],
        unitFactionGroup = ScoreTable["unitFactionGroup"],
        unitFaction = ScoreTable["unitFaction"],
        unitRace = ScoreTable["unitRace"],
        unitClass = ScoreTable["unitClass"],
        unitClassFileName = ScoreTable["unitClassFileName"],

        duelSum = duelSum,
        duelWin = duelWin,
        duelLose = duelLose,
        duelWinRate = duelWinRate,
        duelScore = duelScore,

        arenaSum = arenaSum,
        arenaWin = arenaWin,
        arenaLose = arenaLose,
        arenaWinRate = arenaWinRate,
        arenaScore = arenaScore,

        ratingBattlegroundSum = ratingBattlegroundSum,
        ratingBattlegroundWin = ratingBattlegroundWin,
        ratingBattlegroundLose = ratingBattlegroundLose,
        ratingBattlegroundWinRate = ratingBattlegroundWinRate,
        ratingBattlegroundScore = ratingBattlegroundScore,

        totalScore = totalScore,
        pvpStar = pvpStar,

        arenaRating_2v2 = arenaRating_2v2,
        arenaRating_3v3 = arenaRating_3v3,
        honorableKills = honorableKills,
        allKills = arenaKills + battlegroundKills,
        arenaKills = arenaKills,
        battlegroundKills = battlegroundKills,
        battlegroundSum = battlegroundSum,
        battlegroundWin = battlegroundWin,
        battlegroundLose = battlegroundLose,
        battlegroundWinRate = battlgroundWinRate,
    })

    CalculateWorking = nil
end

function DisplayScoreInMessage(channel)
    --print("channel: " .. channel)
    local separator = "  "
    local lineStart = "       "

    local sendMsgWay
    if PVPInfoType == "print" then
        sendMsgWay = print
    elseif PVPInfoType == "message" then
        sendMsgWay = SendChatMessage
    else
        sendMsgWay = print
    end
    if channel == "" then
        sendMsgWay = print
    end

    sendMsgWay(AppName .. ": " .. ScoreTable["unitName"] .. "-" .. ScoreTable["unitRealName"] .. separator .. L["textLevel"] .. "(" .. ScoreTable["unitLevel"] .. ")" .. separator .. ScoreTable["unitRace"] .. separator .. ScoreTable["unitClass"], channel)
    if PVPInfo.db.profile.showDuel then
        sendMsgWay(lineStart .. L["textDule"] .. " = " .. L["textDuelWinLose"] .. ": " .. ScoreTable["duelWin"] .. "/" .. ScoreTable["duelLose"] .. separator .. L["textDuelWinRate"] .. ": " .. ScoreTable["duelWinRate"] .. "%", channel)
    end
    if PVPInfo.db.profile.showHighArenaLevel then
        sendMsgWay(lineStart .. L["textHighestArenaRating"] .. " = " .. "2v2: " .. ScoreTable["arenaRating_2v2"] .. separator .. "3v3: " .. ScoreTable["arenaRating_3v3"], channel)
    end
    if PVPInfo.db.profile.showArena then
        sendMsgWay(lineStart .. L["textArena"] .. " = " .. L["textArenaWinLose"] .. ": " .. ScoreTable["arenaWin"] .. "/" .. ScoreTable["arenaLose"] .. separator .. L["textArenaWinRate"] .. ": " .. ScoreTable["arenaWinRate"] .. "%", channel)
    end
    if PVPInfo.db.profile.showRatingBattleground then
        sendMsgWay(lineStart .. L["textRatingBattleground"] .. " = " .. L["textRatingBattlegroundWinLose"] .. ": " .. ScoreTable["ratingBattlegroundWin"] .. "/" .. ScoreTable["ratingBattlegroundLose"] .. separator .. L["textRatingBattlegroundWinRate"] .. ": " .. ScoreTable["ratingBattlegroundWinRate"] .. "%", channel)
    end
    if PVPInfo.db.profile.showBattleground then
        sendMsgWay(lineStart .. L["textBattleground"] .. " = " .. L["textBattlegroundWinLose"] .. ": " .. ScoreTable["battlegroundWin"] .. "/" .. ScoreTable["battlegroundLose"] .. separator .. L["textBattlegroundWinRate"] .. ": " .. ScoreTable["battlegroundWinRate"] .. "%", channel)
    end
    if PVPInfo.db.profile.showKill then
        sendMsgWay(lineStart .. L["textHonorableKills"] .. ": " .. ScoreTable["honorableKills"] .. separator .. L["textAllKills"] .. ": " .. ScoreTable["allKills"] .. separator .. L["textArenaKills"] .. ": " .. ScoreTable["arenaKills"] .. separator .. L["textBattlegroundKills"] .. ": " .. ScoreTable["battlegroundKills"], channel)
    end
    sendMsgWay(lineStart .. L["pvpScore"] .. " <" .. ScoreTable["totalScore"] .. "> " .. ScoreTable["pvpStar"], channel)
end

function GetUnitFromCache(unitFlag)
    local len = getn(PVPInfo.db.profile.cache)
    if len >= 1 then
        for i = 1, len do
            local tmp = PVPInfo.db.profile.cache[i].unitFlag
            if unitFlag == tmp then
                return PVPInfo.db.profile.cache[i]
            end
        end
    end

    return nil
end

function CreateTargetFrame()
    if TatgetPVPInfo then
        TatgetPVPInfo:Hide()
    end
    TatgetPVPInfo = TargetFrame:CreateFontString("TatgetPVPInfo")
    TatgetPVPInfo:SetFont("Fonts\\ARKai_T.TTF", 13, 'OUTLINE')
    TatgetPVPInfo:SetText(ScoreTable["pvpStar"])
    TatgetPVPInfo:SetPoint("TOPLEFT", TargetFrame, "LEFT", 7, 45)
end

function GetHighestBattlegroundLevel()
    local levelSort = { 5356, 5342, 5355, 5354, 5353, 5338, 5352, 5351, 5350, 5349, 5348, 5347 };
    local len = table.getn(levelSort)
    for j = 1, len do
        print(levelSort[j])
        local id, name, score, isFinish, month, day, year, desc, flag, img, rewardText, isGuild, wasEarnedByMe, earnBy = GetAchievementInfo(levelSort[j])
        if isFinish == true then
            return name, isFinish, year.. "Y" .. month .. "M" .. day .. "D", earnBy
        end
    end
    return "", false, "", ""
end

function Print(text)
    PVPInfo:Print(text)
end
-- Bindings
function PVPInfo_Print()
    PVPInfoType = "message"
    MessageChannel = ""
    DisplayPVPInfo()
end
function PVPInfo_Say()
    PVPInfoType = "message"
    MessageChannel = "SAY"
    DisplayPVPInfo()
end
function PVPInfo_Emote()
    PVPInfoType = "message"
    MessageChannel = "EMOTE"
    DisplayPVPInfo()
end
function PVPInfo_Yell()
    PVPInfoType = "message"
    MessageChannel = "YELL"
    DisplayPVPInfo()
end
function PVPInfo_Party()
    PVPInfoType = "message"
    MessageChannel = "PARTY"
    DisplayPVPInfo()
end
function PVPInfo_Raid()
    PVPInfoType = "message"
    MessageChannel = "RAID"
    DisplayPVPInfo()
end
function PVPInfo_Instance_Chat()
    PVPInfoType = "message"
    MessageChannel = "INSTANCE_CHAT"
    DisplayPVPInfo()
end
function PVPInfo_Guild()
    PVPInfoType = "message"
    MessageChannel = "GUILD"
    DisplayPVPInfo()
end
