local layout = {
	[0] = {{
		{1955.5284423828, 4691.412109375},
		{3044.5961914063, 4640.3276367188},
		{2946.1135253906, 4585.0356445313},
		{2840.8408203125, 4588.5498046875},
		{2812.3791503906, 4543.7133789063},
		{2801.9182128906, 4500.4814453125},
		{2797.1865234375, 4446.4350585938},
		{2735.2243652344, 4394.8837890625},
		{2666.4240722656, 4366.6059570313},
		{2611.7172851563, 4356.3515625},
		{2529.4626464844, 4352.4443359375},
		{2439.9946289063, 4331.9228515625},
		{2342.4704589844, 4305.0546875},
		{2298.5510253906, 4237.6274414063},
		{2298.7407226563, 4153.5864257813},
		{2379.9565429688, 3931.8671875},
		{2309.6223144531, 3918.6174316406},
		{1569.6352539063, 3950.3752441406},
		{1532.2873535156, 3973.7426757813},
		{1529.5615234375, 4028.1005859375},
		{1525.1921386719, 4072.4072265625},
		{1541.1948242188, 4116.716796875},
		{1530.7279052734, 4146.0854492188},
		{1483.3564453125, 4172.3618164063},
		{1438.1248779297, 4177.4057617188},
		{1348.3469238281, 4134.6284179688},
		{1318.0148925781, 4121.2109375},
		{1284.6397705078, 4121.896484375},
		{1256.2026367188, 4164.138671875},
		{1209.0017089844, 4203.1948242188},
		{1141.4897460938, 4215.7241210938},
		{1131.5266113281, 4260.3940429688},
		{1082.556640625, 4315.3525390625},
		{1025.0540771484, 4324.4365234375},
		{967.20336914063, 4316.9448242188},
		{937.29748535156, 4305.818359375},
		{918.94885253906, 4334.4013671875},
		{854.31744384766, 4347.3369140625},
		{848.80444335938, 4359.6494140625},
		{867.09167480469, 4382.7387695313},
		{851.43957519531, 4406.87109375},
		{1113.1082763672, 4523.3403320313},
		{1113.1706542969, 4550.7172851563},
		{1074.7719726563, 4589.900390625},
		{1093.3522949219, 4619.8618164063},
		{1177.3566894531, 4649.330078125},
		{1200.9672851563, 4672.685546875},
		{1205.66796875, 4709.6499023438},
		{1163.2071533203, 4767.3549804688},
		{1090.1602783203, 4797.2299804688},
		{1082.6235351563, 4816.4184570313},
		{1103.5782470703, 4855.6064453125},
		{1089.6146240234, 4894.5014648438},
		{1050.2973632813, 4922.326171875},
		{909.71655273438, 4959.0454101563},
		{892.16613769531, 4971.7080078125},
		{865.423828125, 5040.9633789063},
		{944.50872802734, 5085.3491210938},
		{1031.9908447266, 5053.6005859375},
		{1100.6618652344, 5078.638671875},
		{1148.3942871094, 5108.5244140625},
		{1158.8773193359, 5176.7319335938},
		{1211.8728027344, 5178.5249023438},
		{1263.2395019531, 5180.0883789063},
		{1282.2427978516, 5229.8359375},
		{1313.6607666016, 5269.5122070313},
		{1372.8758544922, 5255.400390625},
		{1457.3913574219, 5197.1728515625},
		{1505.1119384766, 5191.2016601563},
		{1538.6318359375, 5208.7373046875},
		{1567.4445800781, 5248.8012695313},
		{1560.3471679688, 5349.0634765625},
		{1580.6374511719, 5366.306640625},
		{1575.294921875, 5406.1201171875},
		{2350.4091796875, 5399.6850585938},
		{2402.3764648438, 5383.4482421875},
		{2380.1052246094, 5343.380859375},
		{2303.7263183594, 5173.45703125},
		{2290.6884765625, 5130.8510742188},
		{2305.6271972656, 5056.9750976563},
		{2342.3779296875, 5004.9677734375},
		{2389.5070800781, 4985.1352539063},
		{2470.8483886719, 4985.3916015625},
		{2540.513671875, 4993.5810546875},
		{2585.5817871094, 4960.90625},
		{2641.458984375, 4946.2661132813},
		{2719.4501953125, 4970.0161132813},
		{2778.8569335938, 4921.4018554688},
		{2818.27734375, 4870.6484375},
		{2805.75, 4838.8959960938},
		{2788.3813476563, 4790.3823242188},
		{2802.5546875, 4752.6889648438},
		{2859.3857421875, 4707.3071289063},
		{2940.5224609375, 4706.986328125},
		{2970.2915039063, 4668.1000976563},
		{3044.5961914063, 4640.3276367188},
	}},
	[1] = {{}},
	[2] = {{}},
	[3] = {{}},
	[4] = {{}},
}

local startpos = {
	[0] = {{1755, 4672}},
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {},
}

local center = {Game.mapSizeX / 2, Game.mapSizeZ / 2}

for tri = 1, #layout[0][1] do
	local dx = (layout[0][1][tri][1] - center[1])
	local dy = (layout[0][1][tri][2] - center[2])
	for area = 1, 4 do
		local phi = math.pi * area * 0.4
		layout[area][1][tri] = {
			center[1] + dx*math.cos(phi) + dy*math.sin(-phi),
			center[2] + dx*math.sin(phi) + dy*math.cos(phi)
		}
	end
end

for area = 0, 4 do
	local dx = (startpos[0][1][1] - center[1])
	local dy = (startpos[0][1][2] - center[2])
	local phi = math.pi * area * 0.4
	startpos[area][1] = {
		center[1] + dx*math.cos(phi) + dy*math.sin(-phi),
		center[2] + dx*math.sin(phi) + dy*math.cos(phi)
	}
end

return layout, startpos, {2, 5}