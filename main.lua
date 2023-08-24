local mod = RegisterMod('Saul',1)
local IsaacPlayer = Isaac.GetPlayer()

local Timer = 15
local time = 0
local room = nil

local SaulStats = {
    DAMAGE = 100 - 3.5,
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


local function RNGEffect()

end

function mod:EvalCache(player,Cache)
    -- print(player:GetName())
    
    if player:GetName() == 'Saul' then
        if Cache == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + SaulStats.DAMAGE
            print('OH')
        end
        if Cache == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck - SaulStats.LUCK
        end
    end
end

-- old
local function initalize(_,init)
    math.randomseed(os.time())
    if not init then
        print('New Run')
        -- Player = Isaac.GetPlayer()

        -- Isaac.GetPlayer().Damage = SaulStats.DAMAGE
    else
        print('Old Run')
    end
end

local function tearFire (_,tear)
    tear.TearFlags = tear.TearFlags | TearFlags.TEAR_SLOW
    tear.ChangeVariant(tear,TearVariant.DARK_MATTER)
end

local function PrintHi (_,text)
    -- Check Current Room
    room = Game():GetRoom()
    time = time + 1

    -- Timer    

    if time == Timer then
        time  = 0
        -- Spawn Coin
        if Input.IsButtonPressed(Keyboard.KEY_ENTER, 0) then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_LUCKYPENNY, 
            room:GetRandomPosition(1.0), 
            Vector(0,0), nil)
        end
    end

end

mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, tearFire)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, PrintHi)

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, initalize)       -- on game start
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.EvalCache)         -- on stat change