local mod = RegisterMod('Saul',1)
local IsaacPlayer = Isaac.GetPlayer()
local rng = RNG()

local TimerLengths = {
    180,
    30,
    15
}

local Timer = TimerLengths[1] -- tables (arrays) start at 1, not 0
local time = 0

local room = nil
local roomClear = false
local CanPenny = true

local SaulStats = {
    DAMAGE = 10,
    LUCK = 100,
}

-- TODO:
--  Lucky Coin
--      Item that scales with luck and produces lucky coins randomly depending on players luck stat

-- Luck Pill
    -- Invert luck

-- Luck machine
    -- spend 1 luck for a chance to get 2
        -- possible tier 1 item ? idk


-- TODO: Depending on luck stat, this will apply a range of effects on a timer that also scales with luck
--  Under 0 luck
--      mom Stomp
--      Random enemy spawn
--      Tier4 item spawn
--      Troll bomb spawn
--  0-50 luck
--      item spawn tiers include all tiers
--      random champion spawn
-- 50-100 luck
--      Random boss spawn
--  100+ luck
--      randomly explode
--      multiple effects can apply at once
--      timer random
--      Saul theme plays because your slippin jimmy

-- /______________/EFFECTS/______________/

-- spawn mom foot
local function RngStomp()
    print('Stomps')
end

local function RngEnemy()
    print('Enemy Spawn')
    Isaac.Spawn(EntityType.ENTITY_FLY, 0,0, 
    Game():GetRoom():GetRandomPosition(1.0)
    , Vector(0,0), nil)
    -- IsaacPlayer:UsePill()
end

local RNGCollectables = {
    [1] = PickupVariant.PICKUP_COIN,
    [2] = PickupVariant.PICKUP_BOMB,
    [3] = PickupVariant.PICKUP_KEY,
}

local function RngItemSpawn()
    print('Item Spawn')
    Isaac.Spawn(EntityType.ENTITY_PICKUP,RNGCollectables[math.random(1,#RNGCollectables)],0,Game():GetRoom():FindFreePickupSpawnPosition(Game():GetRoom():GetRandomPosition(1.0)),
    Vector(0,0), nil)
end

local function RngTrollBomb()
    print('TrollBomb')
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB,BombSubType.BOMB_TROLL, 
    Game():GetRoom():GetRandomPosition(1.0),
    Vector(0,0), nil)
end

local RngDict =  {
    [1] = RngStomp,
    [2] = RngEnemy,
    [3] = RngItemSpawn,
    [4] = RngTrollBomb
}

local function Rng_0Luck()
    local RNGCHACE = math.random(IsaacPlayer.Luck,100)
    print(RNGCHACE)
    -- print(100 + IsaacPlayer.Luck)
    -- if RNGCHACE > 70 then
    local RNGCHOICE = math.random(1,#RngDict)
    RngDict[RNGCHOICE]()    -- do random thing
    -- end
end


local function RNGEffect()
    -- Less than 0 effects
    if IsaacPlayer.Luck < 0 then
        -- print('Luck is less than 0')
        Rng_0Luck()

    elseif IsaacPlayer.Luck > 0 and IsaacPlayer.Luck < 50 then
        -- print('Luck is between 0-50')
    elseif IsaacPlayer.Luck >= 50 and IsaacPlayer.Luck < 100 then
        -- print('Luck is between 50-100')
    elseif IsaacPlayer.Luck >= 100 then
        -- print('Luck is between 100+')
    end

end



function mod:EvalCache(player,Cache)
    if player:GetName() == 'Saul' then
        if Cache == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + SaulStats.DAMAGE
        end
        if Cache == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck - SaulStats.LUCK
            if player.Luck > 0 and player.Luck > 50  then
                Timer = TimerLengths[2]
                print('Changed timer',Timer)
            end
        end
    end
end

local function initalize(_,init)
    IsaacPlayer = Isaac.GetPlayer()
    if not init then
        print('New Run')
    else
        print('Old Run')
    end
end

local function SpawnPenny()
    if CanPenny then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_LUCKYPENNY, 
        Game():GetRoom():FindFreePickupSpawnPosition(Game():GetRoom():GetRandomPosition(1.0)), 
        Vector(0,0), nil)
        CanPenny = false
    end
end

-- Check room is clear
local function CheckClear()
    if room == nil then
        room = Game():GetRoom()
        roomClear = room:IsClear()
    end
    roomClear = room:IsClear()
    if roomClear then
        SpawnPenny()
    end
end

-- if room cleared, spawn penny ONCE PER ROOM ONLY
local function SetPenny()
    if not Game():GetRoom():IsClear() then
        CanPenny = true
    end
    print(Game():GetRoom():IsClear())
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, SetPenny)

local function SaulLogic (_)
    time = time + 1
    -- Timer    
    if time == Timer then
        time  = 0
        RNGEffect()
    end
    CheckClear()
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, initalize)       -- on game start
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, SaulLogic)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.EvalCache)         -- on stat change