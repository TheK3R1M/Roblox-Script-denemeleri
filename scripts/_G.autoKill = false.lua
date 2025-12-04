_G.autoKill = false

whiteList = {"ck1234566", "asdqweasdqweasdqwd", "WhiteNinjaLOL1", "HD_Phantom1", "batuu222", "SE_LST", "akaan435312"}
gg = game:GetService('Players'):GetPlayers()
wait(0.2)


function uzaklik (a, b)
	local p1 = a.Character.HumanoidRootPart.CFrame
	local p2 = b.Character.HumanoidRootPart.CFrame
	return math.sqrt((p1.x - p2.x) * 
                     (p1.x - p2.x) +
                     (p1.y - p2.y) * 
                     (p1.y - p2.y)) 
end

function yakinlik (player, liste)
	local id = Null
	local enYakinUzaklik = 999999
	for i,v in next, liste do 
		if enYakinUzaklik > uzaklik(player, v) then
			enYakinUzaklik = uzaklik(player, v)
			id = i
		end
	end
	return liste[i]
end

function listedenCikarma(CikanOyuncu, liste)
	for i,v in next, liste do 
		if v.Name == CikanOyuncu then
			table.remove(liste, i)
			break
		end
	end
	return liste
end

function BeyazListe(W)
	for i,v in next, W do 
		gg = listedenCikarma(v, gg) 
	end
end

while _G.autoKill == true do
	gg = game:GetService('Players'):GetPlayers()
	BeyazListe(whiteList)
	saldirilcakOyuncu = yakinlik(game:GetService("Players").LocalPlayer, gg)
	
	
	pcall(function()
		local args = {
		    [1] = 33,
		    [2] = saldirilcakOyuncu.Character.HumanoidRootPart.CFrame * CFrame.Angles(-0.0050061726942658424, 0.4866005778312683, 0.002341020619496703),
		    [3] = 2,
		    [4] = saldirilcakOyuncu.Character.Humanoid,
		    [5] = 26,
		    [6] = game:GetService("Players").LocalPlayer.Character.Famas,
		    [8] = 1}
		game:GetService("ReplicatedStorage").Events.MenuActionEvent:FireServer(unpack(args))
	end)
	wait(0.5)
	local args = {
	    [1] = "Rifle Ammo",
	    [2] = 26,
	    [3] = game:GetService("Players").LocalPlayer.Character.Famas}
	game:GetService("ReplicatedStorage").Events.WeaponReloadEvent:FireServer(unpack(args))
	wait(0.5)
	local args = {
	    [1] = 2,
	    [2] = "Rifle Ammo (30x)",
	    [4] = 8}
	game:GetService("ReplicatedStorage").Events.MenuEvent:FireServer(unpack(args))
end