local Spheres = {}
local Spheres2 = {}
local Spheres_Names = {}
local Spheres3 = {}
local Spheres4 = {}
local Spheres5 = {}
local SpheresInitialized = false
local playerPed = PlayerPedId()

Citizen.CreateThread(function()
    for i=1, #Config.Places, 1 do
        if Config.Places[i].drawBlip then
            local blip = AddBlipForCoord(Config.Places[i].vector)

            SetBlipSprite(blip, Config.Places[i].blipSprite)
            SetBlipColour(blip, Config.Places[i].blipColour)
            SetBlipScale(blip, Config.Places[i].blipScale)
            SetBlipAsShortRange(blip, true)
    
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(Config.Places[i].blipName)
            EndTextCommandSetBlipName(blip)
        end
        Spheres[i] = vector3(Config.Places[i].vector)
        Spheres2[i] = (10*(Config.Places[i].sphere/10))
        Spheres_Names[i] = Config.Places[i].Weapons
        Spheres3[i] = Config.Places[i].rgba
        Spheres4[i] = Config.Places[i].revive
        Spheres5[i] = Config.Places[i].reviveEvent
    end
    SpheresInitialized = true
end)

local coords

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300)
        coords = GetEntityCoords(playerPed)
    end
end)

local Sph = {}
local Entered = {}

Citizen.CreateThread(function()
    while not SpheresInitialized or coords == nil do
        Citizen.Wait(100)
    end
    while true do
        Citizen.Wait(500)
        Sph = {}
        for i=1, #Spheres do
            if Vdist2(coords, Spheres[i]) < (Spheres2[i]*Spheres2[i]) then
                Sph[#Sph+1] = i
            end
            if Vdist2(coords, Spheres[i]) <= (Spheres2[i]*Spheres2[i]) then
                if Entered[i] ~= true then
                    Entered[i] = 'maybe'
                end
            else
                if Entered[i] ~= nil and Entered[i] == true then
                    for k,v in ipairs(Spheres_Names[i]) do
                        RemoveWeaponFromPed(playerPed, GetHashKey(v))
                    end
                end
                Entered[i] = false
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if #Sph > 0 then
            for i=1, #Sph, 1 do
                DrawSphere(Spheres[Sph[i]].x, Spheres[Sph[i]].y, Spheres[Sph[i]].z, Spheres2[Sph[i]], Spheres3[i][1], Spheres3[i][2], Spheres3[i][3], Spheres3[i][4])
            end
            for i=1, #Entered, 1 do
                if Entered[i] == 'maybe' then
                    for k,v in ipairs(Spheres_Names[i]) do
                        GiveWeaponToPed(playerPed, GetHashKey(v), 200)
                    end
                    Entered[i] = true
                end
                if GetEntityHealth(playerPed) <= 0 then
                    if Spheres4[i] and Spheres5[i] then
                        TriggerEvent(Spheres5[i])
                    end
                end
            end
        else
            Citizen.Wait(500)
        end
    end
end)
