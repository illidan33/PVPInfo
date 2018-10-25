PVPInfo = LibStub("AceAddon-3.0"):NewAddon("PVPInfo", "AceConsole-3.0", "AceEvent-3.0")
-- local Module = PVPInfo:NewModule("Config", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("PVPInfo")
-- local MessageWay = nil
local CalculateWorking = nil
local appName = "PVPInfo"
local scoreTable = {}
local PVPInfoFrame = CreateFrame("Frame")
local targetWorking = nil

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
        showBattleground = {
            type = "toggle",
            name = L["showBattleground"],
            desc = L["toggleBattleground"],
            get = function(info)
                return PVPInfo.db.profile.showBattleground
            end,
            set = function(info, value)
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
    },
}

function PVPInfo:OnInitialize()
    -- Called when the addon is loaded
    self.db = LibStub("AceDB-3.0"):New("PVPInfoDB", defaults, true)
    LibStub("AceConfig-3.0"):RegisterOptionsTable(appName, options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(appName, appName)

    self:RegisterChatCommand("pi", "ChatCommand")
    self:RegisterChatCommand("pvpinfo", "ShowConfig")
    self:RegisterChatCommand("pis", "MessageToSay")
    self:RegisterChatCommand("pip", "MessageToPrint")
    self:RegisterChatCommand("pir", "MessageToRaid")
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
    self:Print("PLAYER_TARGET_CHANGED")
    DisplayStarOnNameBar()
end

function PVPInfo:ShowConfig()
    LibStub("AceConfigDialog-3.0"):SetDefaultSize(appName, 800, 600)
    LibStub("AceConfigDialog-3.0"):Open(appName)
end

function PVPInfo:ChatCommand(input)
    print("ChatCommand:" .. input)
    if not input or input:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory(appName)
    else
        LibStub("AceConfigCmd-3.0"):HandleCommand("pi", appName, input)
    end
end

function PVPInfo:INSPECT_ACHIEVEMENT_READY()
    self:Print("INSPECT_ACHIEVEMENT_READY")
    CalculateScore()

    TatgetPVPInfo = TargetFrame:CreateFontString("TatgetPVPInfo")
    TatgetPVPInfo:SetFont("Fonts\\ARKai_T.TTF", 13, 'OUTLINE')
    TatgetPVPInfo:SetText(scoreTable["pvpStar"])
    TatgetPVPInfo:SetPoint("TOPLEFT", TargetFrame, "LEFT", 7, 45)

    DisplayScoreInMessage(print, "")

    ClearAchievementComparisonUnit()
end

function CalculateScore()
    if targetWorking then return end
    targetWorking = 1

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

    local duelScore = math.ceil(duelWinRate / 2 + (duelSum / 5000 * 100) / 2)
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

    local arenaScore = math.ceil(arenaWinRate / 2 + (arenaSum / 5000 * 100) / 2)
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

    local ratingBattlegroundScore = math.ceil(ratingBattlegroundWinRate / 2 + (ratingBattlegroundSum / 1000 * 100) / 2)
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

    scoreTable["duelSum"] = duelSum
    scoreTable["duelWin"] = duelWin
    scoreTable["duelLose"] = duelLose
    scoreTable["duelWinRate"] = duelWinRate
    scoreTable["duelScore"] = duelScore

    scoreTable["arenaSum"] = arenaSum
    scoreTable["arenaWin"] = arenaWin
    scoreTable["arenaLose"] = arenaLose
    scoreTable["arenaWinRate"] = arenaWinRate
    scoreTable["arenaScore"] = arenaScore

    scoreTable["ratingBattlegroundSum"] = ratingBattlegroundSum
    scoreTable["ratingBattlegroundWin"] = ratingBattlegroundWin
    scoreTable["ratingBattlegroundLose"] = ratingBattlegroundLose
    scoreTable["ratingBattlegroundWinRate"] = ratingBattlegroundWinRate
    scoreTable["ratingBattlegroundScore"] = ratingBattlegroundScore

    scoreTable["totalScore"] = totalScore
    scoreTable["pvpStar"] = pvpStar

    if PVPInfo.db.profile.showHighArenaLevel then
        local arenaRating_3v3 = GetComparisonStatistic(595)
        if arenaRating_3v3 == "--" then
            arenaRating_3v3 = 0
        end

        local arenaRating_2v2 = GetComparisonStatistic(370)
        if arenaRating_2v2 == "--" then
            arenaRating_2v2 = 0
        end

        scoreTable["arenaRating_2v2"] = arenaRating_2v2
        scoreTable["arenaRating_3v3"] = arenaRating_3v3
    end

    if PVPInfo.db.profile.showKill then
        -- Kills -- 击杀总数
        local honorableKills = GetComparisonStatistic(588)
        if honorableKills == "--" then
            honorableKills = 0
        end

        local arenaKills = GetComparisonStatistic(1490)
        if arenaKills == "--" then
            arenaKills = 0
        end

        local battlegroundKills = GetComparisonStatistic(1491)
        if battlegroundKills == "--" then
            battlegroundKills = 0
        end

        scoreTable["honorableKills"] = honorableKills
        scoreTable["allKills"] = arenaKills + battlegroundKills
        scoreTable["arenaKills"] = arenaKills
        scoreTable["battlegroundKills"] = battlegroundKills
    end

    if PVPInfo.db.profile.showBattleground then
        -- Battleground -- 战场
        local battlegroundSum = GetComparisonStatistic(839)
        if battlegroundSum == "--" then
            battlegroundSum = 0
        end

        local battlegroundWin = GetComparisonStatistic(840)
        if battlegroundWin == "--" then
            battlegroundWin = 0
        end

        local battlegroundLose = battlegroundSum - battlegroundWin
        local battlgroundWinRate = 0
        if battlegroundSum == 0 then
            battlgroundWinRate = 0
        else
            battlgroundWinRate = math.ceil((battlegroundWin / battlegroundSum) * 100)
        end

        scoreTable["battlegroundSum"] = battlegroundSum
        scoreTable["battlegroundWin"] = battlegroundWin
        scoreTable["battlegroundLose"] = battlegroundLose
        scoreTable["battlegroundWinRate"] = battlgroundWinRate
    end
    targetWorking = nil
end

function DisplayStarOnNameBar()
    if TatgetPVPScore then
        TatgetPVPScore:Hide()
    end
	if not UnitIsPlayer("target") then
        print("not player")
        return
    end
    --if not UnitIsVisible("target") then return end
    --NotifyInspect("target") --设置观察目标
    --RequestInspectHonorData() --请求该目标PVP数据

    --SetAchievementComparisonUnit("target") --设置要比较的单位

    local target = "target"
    --print("CalculateScore: " .. UnitName(target))
    scoreTable["unitName"], scoreTable["unitRealName"] = UnitName(target)
    --print("get CalculateScore: " .. scoreTable["unitName"])
    scoreTable["unitLevel"] = UnitLevel(target)
    scoreTable["unitFactionGroup"], scoreTable["unitFaction"] = UnitFactionGroup(target)
    scoreTable["unitRace"] = UnitRace(target)
    scoreTable["unitClass"], scoreTable["unitClassFileName"] = UnitClass(target)
    if not scoreTable["unitRealName"] then
        scoreTable["unitRealName"] = GetRealmName()
    end

    SetAchievementComparisonUnit("target")

end

function DisplayScoreInMessage(sendMsgWay, channel)
    print("DisplayScoreInMessage: " .. UnitName("target"))

    local separator = "  "

    sendMsgWay(appName .. ": " .. scoreTable["unitName"] .. "-" .. scoreTable["unitRealName"] .. separator .. L["textLevel"] .. "(" .. scoreTable["unitLevel"] .. ")" .. separator .. scoreTable["unitRace"] .. separator .. scoreTable["unitClass"], channel)
    if PVPInfo.db.profile.showDuel then
        sendMsgWay(L["textDule"] .. " = " .. L["textDuelWinLose"] .. ": " .. scoreTable["duelWin"] .. "/" .. scoreTable["duelLose"] .. separator .. L["textDuelWinRate"] .. ": " .. scoreTable["duelWinRate"] .. "%", channel)
    end
    if PVPInfo.db.profile.showHighArenaLevel then
        sendMsgWay(L["highestArenaRating"] .. " 2v2:" .. scoreTable["arenaRating_2v2"] .. "  3v3:" .. scoreTable["arenaRating_3v3"], channel)
    end
    if PVPInfo.db.profile.showArena then
        sendMsgWay(L["textArena"] .. " = " .. L["textArenaWinLose"] .. ": " .. scoreTable["arenaWin"] .. "/" .. scoreTable["arenaLose"] .. separator .. L["textArenaWinRate"] .. ": " .. scoreTable["arenaWinRate"] .. "%", channel)
    end
    if PVPInfo.db.profile.showRatingBattleground then
        sendMsgWay(L["textRatingBattleground"] .. " = " .. L["textRatingBattlegroundWinLose"] .. ": " .. scoreTable["ratingBattlegroundWin"] .. "/" .. scoreTable["ratingBattlegroundLose"] .. separator .. L["textRatingBattlegroundWinRate"] .. ": " .. scoreTable["ratingBattlegroundWinRate"] .. "%", channel)
    end
    if PVPInfo.db.profile.showBattleground then
        sendMsgWay(L["textBattleground"] .. " = " .. L["textBattlegroundWinLose"] .. ": " .. scoreTable["battlegroundWin"] .. "/" .. scoreTable["battlegroundLose"] .. separator .. L["textBattlegroundWinRate"] .. ": " .. scoreTable["battlegroundWinRate"], channel)
    end
    if PVPInfo.db.profile.showKill then
        sendMsgWay(L["textHonorableKills"] .. ": " .. scoreTable["honorableKills"] .. separator .. L["textAllKills"] .. ": " .. scoreTable["allKills"] .. separator .. L["textArenaKills"] .. ": " .. scoreTable["arenaKills"] .. separator .. L["textBattlegroundKills"] .. ": " .. scoreTable["battlegroundKills"], channel)
    end
    sendMsgWay(L["pvpScore"] .. " <" .. scoreTable["totalScore"] .. "> " .. scoreTable["pvpStar"], channel)
end

function PVPInfo:MessageToPrint()
    SetAchievementComparisonUnit("target") --设置要比较的单位
    --PVPInfoFrame:RegisterEvent("INSPECT_ACHIEVEMENT_READY")
    --PVPInfoFrame:SetScript("OnEvent",function()
        CalculateScore()
        DisplayScoreInMessage(print, "")

        ClearAchievementComparisonUnit()
    --end)
end

function PVPInfo:MessageToSay()
    CalculateScore()
    DisplayScoreInMessage(SendChatMessage, "SAY")
end

function PVPInfo:MessageToRaid()
    CalculateScore()
    DisplayScoreInMessage(SendChatMessage, "RAID")
end



