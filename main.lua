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


-- /______________/EFFECTS/______________/
-- spawn mom foot
local function RngStomp()
    print('Stomps')
    Isaac.Spawn(
        EntityType.ENTITY_EFFECT,
        EffectVariant.MOM_FOOT_STOMP,
        0,
        IsaacPlayer.Position,
        Vector(0,0),
        nil
    )
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
    Isaac.Spawn(EntityType.ENTITY_PICKUP,RNGCollectables[math.random(1,#RNGCollectables)],0,
    Game():GetRoom():FindFreePickupSpawnPosition(Game():GetRoom():GetRandomPosition(1.0)),
    Vector(0,0), nil)
end

local function RngTrollBomb()
    print('TrollBomb')
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB,BombSubType.BOMB_TROLL, 
    Game():GetRoom():GetRandomPosition(1.0),
    Vector(0,0), nil)
end

local RngDict0LUCK =  {
    [1] = RngStomp,
    [2] = RngEnemy,
    [3] = RngItemSpawn,
    [4] = RngTrollBomb
}

local function RNGEffect()
    local RNGCHACE = math.random(IsaacPlayer.Luck,200) + IsaacPlayer.Luck
    print('Roll' .. tostring(RNGCHACE))
    -- RNGChance = 0-100 - 100
    if RNGCHACE > 50 then
        local RNGCHOICE = math.random(1,#RngDict0LUCK)
        RngDict0LUCK[RNGCHOICE]()    -- do random thing  
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