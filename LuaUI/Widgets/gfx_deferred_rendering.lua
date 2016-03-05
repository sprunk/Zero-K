--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function widget:GetInfo()
  return {
	name      = "Deferred rendering",
	version   = 3,
	desc      = "Collects projectiles and renders deferred lights for them",
	author    = "beherith",
	date      = "2015 Sept.",
	license   = "GPL V2",
	layer     = -1000000000,
	enabled   = true
  }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local GL_MODELVIEW           = GL.MODELVIEW
local GL_NEAREST             = GL.NEAREST
local GL_ONE                 = GL.ONE
local GL_ONE_MINUS_SRC_ALPHA = GL.ONE_MINUS_SRC_ALPHA
local GL_PROJECTION          = GL.PROJECTION
local GL_QUADS               = GL.QUADS
local GL_SRC_ALPHA           = GL.SRC_ALPHA
local glBeginEnd             = gl.BeginEnd
local glBlending             = gl.Blending
local glCallList             = gl.CallList
local glColor                = gl.Color
local glColorMask            = gl.ColorMask
local glCopyToTexture        = gl.CopyToTexture
local glCreateList           = gl.CreateList
local glCreateShader         = gl.CreateShader
local glCreateTexture        = gl.CreateTexture
local glDeleteShader         = gl.DeleteShader
local glDeleteTexture        = gl.DeleteTexture
local glDepthMask            = gl.DepthMask
local glDepthTest            = gl.DepthTest
local glGetMatrixData        = gl.GetMatrixData
local glGetShaderLog         = gl.GetShaderLog
local glGetUniformLocation   = gl.GetUniformLocation
local glGetViewSizes         = gl.GetViewSizes
local glLoadIdentity         = gl.LoadIdentity
local glLoadMatrix           = gl.LoadMatrix
local glMatrixMode           = gl.MatrixMode
local glMultiTexCoord        = gl.MultiTexCoord
local glPopMatrix            = gl.PopMatrix
local glPushMatrix           = gl.PushMatrix
local glResetMatrices        = gl.ResetMatrices
local glTexCoord             = gl.TexCoord
local glTexture              = gl.Texture
local glTexRect              = gl.TexRect
local glRect                 = gl.Rect
local glUniform              = gl.Uniform
local glUniformMatrix        = gl.UniformMatrix
local glUseShader            = gl.UseShader
local glVertex               = gl.Vertex
local glTranslate            = gl.Translate
local spEcho                 = Spring.Echo
local spGetCameraPosition    = Spring.GetCameraPosition
local spGetCameraVectors     = Spring.GetCameraVectors
local spGetDrawFrame         = Spring.GetDrawFrame
local spIsSphereInView       = Spring.IsSphereInView
local spWorldToScreenCoords  = Spring.WorldToScreenCoords
local spTraceScreenRay       = Spring.TraceScreenRay
local spGetSmoothMeshHeight  = Spring.GetSmoothMeshHeight

local spGetProjectilesInRectangle = Spring.GetProjectilesInRectangle
local spGetVisibleProjectiles     = Spring.GetVisibleProjectiles
local spGetProjectilePosition     = Spring.GetProjectilePosition
local spGetProjectileType         = Spring.GetProjectileType
local spGetProjectileDefID        = Spring.GetProjectileDefID
local spGetCameraPosition         = Spring.GetCameraPosition
local spGetPieceProjectileParams  = Spring.GetPieceProjectileParams 
local spGetProjectileVelocity     = Spring.GetProjectileVelocity 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Config

local gibParams = {r = 0.5, g = 0.5, b = 0.25, radius = 100}

local GLSLRenderer = true
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local colorOverride = {1, 1, 1}
local colorBrightness = 1
local radiusOverride = 200
local overrideParam = {r = 1, g = 1, b = 1, radius = 200}

local wantLoadParams = false

local function Format(value)
	return string.format("%.2f", value)
end

local function ApplySetting()
	overrideParam.r = colorOverride[1] * colorBrightness
	overrideParam.g = colorOverride[2] * colorBrightness
	overrideParam.b = colorOverride[3] * colorBrightness
	overrideParam.radius = radiusOverride
	Spring.Echo("light_color = [[" .. Format(overrideParam.r) .. " " .. Format(overrideParam.g) .. " " .. Format(overrideParam.b) .. "]]")
	Spring.Echo("light_radius = " .. Format(radiusOverride) .. ",")
end

local function LoadParams(param)
	options.light_radius.value = param.radius
	options.light_brightness.value = math.max(param.r, param.g, param.b)
	options.light_color.value = {
		param.r / options.light_brightness.value,
		param.g / options.light_brightness.value,
		param.b / options.light_brightness.value,
	}
	
	radiusOverride = options.light_radius.value
	colorBrightness = options.light_brightness.value
	colorOverride = options.light_color.value
	
	Spring.Echo("Loading Settings")
	ApplySetting()
	wantLoadParams = false
	WG.RemakeEpicMenu()
end

options_path = 'Settings/Graphics/Lighting'
options_order = {'light_radius', 'light_brightness', 'light_color', 'light_reload'}
options = {
	light_radius = {
		name = 'Light Radius',
		type = 'number',
		value = 3,
		min = 20, max = 1000, step = 10,
		OnChange = function (self)
			radiusOverride = self.value
			ApplySetting()
		end,
		advanced = true
	},
	light_brightness = {
		name = 'Light Brightness',
		type = 'number',
		value = 3,
		min = 0.05, max = 5, step = 0.05,
		OnChange = function (self) 
			colorBrightness = self.value
			ApplySetting()
		end,
		advanced = true
	},
	light_color = {
		name = 'Light Color',
		type = 'colors',
		value = { 0.8, 0.8, 0.8, 1},
		OnChange = function (self)
			colorOverride = self.value
			ApplySetting()
		end,
		advanced = true
	},
	light_reload = {
		name = 'Reload',
		type = 'button',
		desc = "Reload settings from the next projectile fired.",
		OnChange = function (self)
			wantLoadParams = true
		end,
		advanced = true
	},
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local vsx, vsy
local ivsx = 1.0 
local ivsy = 1.0 
local screenratio = 1.0

local depthPointShader
local depthBeamShader

local lightposlocPoint = nil
local lightcolorlocPoint = nil
local lightparamslocPoint = nil
local uniformEyePosPoint
local uniformViewPrjInvPoint

local lightposlocBeam  = nil
local lightpos2locBeam  = nil
local lightcolorlocBeam  = nil
local lightparamslocBeam  = nil
local uniformEyePosBeam 
local uniformViewPrjInvBeam 

local projectileLightTypes = {}
	--[1] red
	--[2] green
	--[3] blue
	--[4] radius
	--[5] BEAMTYPE, true if BEAM

-- parameters for each light:
-- RGBA: strength in each color channel, radius in elmos.
-- pos: xyz positions
-- params: ABC: where A is constant, B is quadratic, C is linear (only for point lights)

--------------------------------------------------------------------------------
--Light falloff functions: http://gamedev.stackexchange.com/questions/56897/glsl-light-attenuation-color-and-intensity-formula
--------------------------------------------------------------------------------

local verbose = false
local function VerboseEcho(...)
	if verbose then
		Spring.Echo(...) 
	end
end

local function Split(s, separator)
	local results = {}
	for part in s:gmatch("[^"..separator.."]+") do
		results[#results + 1] = part
	end
	return results
end

--------------------------------------------------------------------------------

local function GetLightsFromUnitDefs()
	--The GetProjectileName function returns 'unitname_weaponnname'. EG: armcom_armcomlaser
	--This is fine with BA, because unitnames dont use '_' characters
	--Spring.Echo('GetLightsFromUnitDefs init')
	local plighttable = {}
	for weaponDefID = 1, #WeaponDefs do
		--These projectiles should have lights:
			--Cannon (projectile size: tempsize = 2.0f + std::min(wd.damages[0] * 0.0025f, wd.damageAreaOfEffect * 0.1f);)
			--Dgun
			--MissileLauncher
			--StarburstLauncher
			--LaserCannon
			--LightningCannon
			--BeamLaser
		--Shouldnt:
			--AircraftBomb
			--Shield
			--TorpedoLauncher
		
		local weaponDef = WeaponDefs[weaponDefID]
		local customParams = weaponDef.customParams or {}
		
		local r = weaponDef.visuals.colorR + 0.2
		local g = weaponDef.visuals.colorG + 0.2
		local b = weaponDef.visuals.colorB + 0.2
		
		local weaponData = {r = r, g = g, b = b, radius = 100}
		
		if (weaponDef.type == 'Cannon') then
			if customParams.single_hit then
				VerboseEcho('Gauss', weaponDef.name, 'size', weaponDef.size, weaponDef.visuals.colorR, weaponDef.visuals.colorG, weaponDef.visuals.colorB)
				weaponData.beamOffset = 1
				weaponData.beam = true
				r = 1
				g = 2
				b = 2
			else
				VerboseEcho('Cannon', weaponDef.name, 'size', weaponDef.size, weaponDef.visuals.colorR, weaponDef.visuals.colorG, weaponDef.visuals.colorB)
				weaponData.radius = 10 + 90 * weaponDef.size
			end
		elseif (weaponDef.type == 'LaserCannon') then
			VerboseEcho('LaserCannon', weaponDef.name, 'size', weaponDef.size, weaponDef.visuals.colorR, weaponDef.visuals.colorG, weaponDef.visuals.colorB)
			weaponData.radius = 150 * weaponDef.size
		elseif (weaponDef.type == 'DGun') then
			VerboseEcho('DGun', weaponDef.name, 'size', weaponDef.size)
			weaponData.radius = 800
		elseif (weaponDef.type == 'MissileLauncher') then
			VerboseEcho('MissileLauncher', weaponDef.name, 'size', weaponDef.size)
			weaponData.radius = 150 * weaponDef.size
		elseif (weaponDef.type == 'StarburstLauncher') then
			VerboseEcho('StarburstLauncher', weaponDef.name, 'size', weaponDef.size)
			weaponData.radius = 350
		elseif (weaponDef.type == 'LightningCannon') then
			VerboseEcho('LightningCannon', weaponDef.name, 'size', weaponDef.size)
			weaponData.radius = math.min(weaponDef.range, 250)
			weaponData.beam = true
		elseif (weaponDef.type == 'BeamLaser') then
			VerboseEcho('BeamLaser', weaponDef.name, 'rgbcolor', weaponDef.visuals.colorR)
			weaponData.radius = math.min(weaponDef.range, 150)
			weaponData.beam = true
			if weaponDef.beamTTL > 2 then
				weaponData.fadeTime = weaponDef.beamTTL
			end
		end
		
		if customParams.light_radius then
			weaponData.radius = tonumber(customParams.light_radius)
		end
		
		if customParams.light_ground_height then
			weaponData.groundHeightLimit = tonumber(customParams.light_ground_height)
		end
		
		if customParams.light_camera_height then
			weaponData.cameraHeightLimit = tonumber(customParams.light_camera_height)
		end
		
		if customParams.light_beam_start then
			weaponData.beamStartOffset = tonumber(customParams.light_beam_start)
		end
		
		if customParams.light_beam_offset then
			weaponData.beamOffset = tonumber(customParams.light_beam_offset)
		end
		
		if customParams.light_color then
			local colorList = Split(customParams.light_color, " ")
			weaponData.r = colorList[1]
			weaponData.g = colorList[2]
			weaponData.b = colorList[3]
		end
		
		--weaponData.r = 3
		--weaponData.g = 0.2
		--weaponData.b = 4
		--weaponData.radius = 120
		--weaponData.beamStartOffset = 0.8
		--weaponData.beamOffset = 0.8
		
		if weaponData.radius > 0 and not customParams.fake_weapon then
			plighttable[weaponDefID] = weaponData
		end
	end
	return plighttable
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:ViewResize()
	vsx, vsy = gl.GetViewSizes()
	ivsx = 1.0 / vsx --we can do /n here!
	ivsy = 1.0 / vsy
	if (Spring.GetMiniMapDualScreen() == 'left') then
		vsx = vsx / 2
	end
	if (Spring.GetMiniMapDualScreen() == 'right') then
		vsx = vsx / 2
	end
	screenratio = vsy / vsx --so we dont overdraw and only always draw a square
end

widget:ViewResize()

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local vertSrc = [[
  void main(void)
  {
	gl_TexCoord[0] = gl_MultiTexCoord0;
	gl_Position    = gl_Vertex;
  }
]]
local fragSrc

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:Initialize()
	if (Spring.GetConfigString("AllowDeferredMapRendering") == '0' or Spring.GetConfigString("AllowDeferredModelRendering") == '0') then
		Spring.Echo('Deferred Rendering (gfx_deferred_rendering.lua) requires  AllowDeferredMapRendering and AllowDeferredModelRendering to be enabled in springsettings.cfg!') 
		widgetHandler:RemoveWidget()
		return
	end
	if ((not forceNonGLSL) and Spring.GetMiniMapDualScreen() ~= 'left') then --FIXME dualscreen
		if (not glCreateShader) then
			spEcho("gfx_deferred_rendering.lua: Shaders not found, removing self.")
			GLSLRenderer = false
			widgetHandler:RemoveWidget()
		else
			fragSrc = VFS.LoadFile("shaders\\deferred_lighting.glsl", VFS.ZIP)
			--Spring.Echo('gfx_deferred_rendering.lua: Shader code:', fragSrc)
			depthPointShader = glCreateShader({
				vertex = vertSrc,
				fragment = fragSrc,
				uniformInt = {
					modelnormals = 0,
					modeldepths = 1,
					mapnormals = 2,
					mapdepths = 3,
					modelExtra = 4,
				},
			})

			if (not depthPointShader) then
				spEcho(glGetShaderLog())
				spEcho("gfx_deferred_rendering.lua: Bad depth point shader, removing self.")
				GLSLRenderer = false
				widgetHandler:RemoveWidget()
			else
				lightposlocPoint       = glGetUniformLocation(depthPointShader, "lightpos")
				lightcolorlocPoint     = glGetUniformLocation(depthPointShader, "lightcolor")
				uniformEyePosPoint     = glGetUniformLocation(depthPointShader, 'eyePos')
				uniformViewPrjInvPoint = glGetUniformLocation(depthPointShader, 'viewProjectionInv')
			end
			fragSrc = "#define BEAM_LIGHT \n" .. fragSrc
			depthBeamShader = glCreateShader({
				vertex = vertSrc,
				fragment = fragSrc,
				uniformInt = {
					modelnormals = 0,
					modeldepths = 1,
					mapnormals = 2,
					mapdepths = 3,
					modelExtra = 4,
				},
			})

			if (not depthBeamShader) then
				spEcho(glGetShaderLog())
				spEcho("gfx_deferred_rendering.lua: Bad depth beam shader, removing self.")
				GLSLRenderer = false
				widgetHandler:RemoveWidget()
			else
				lightposlocBeam       = glGetUniformLocation(depthBeamShader, 'lightpos')
				lightpos2locBeam      = glGetUniformLocation(depthBeamShader, 'lightpos2')
				lightcolorlocBeam     = glGetUniformLocation(depthBeamShader, 'lightcolor')
				uniformEyePosBeam     = glGetUniformLocation(depthBeamShader, 'eyePos')
				uniformViewPrjInvBeam = glGetUniformLocation(depthBeamShader, 'viewProjectionInv')
			end
		end
		projectileLightTypes = GetLightsFromUnitDefs()
		screenratio = vsy / vsx --so we dont overdraw and only always draw a square
	else
		GLSLRenderer = false
	end
end

function widget:Shutdown()
	if (GLSLRenderer) then
		if (glDeleteShader) then
			glDeleteShader(depthPointShader)
			glDeleteShader(depthBeamShader)
		end
	end
end

local function DrawLightType(lights, lightsCount, lighttype) -- point = 0 beam = 1
	--Spring.Echo('Camera FOV = ', Spring.GetCameraFOV()) -- default TA cam fov = 45
	--set uniforms:
	local cpx, cpy, cpz = spGetCameraPosition()
	if lighttype == 0 then --point
		glUseShader(depthPointShader)
		glUniform(uniformEyePosPoint, cpx, cpy, cpz)
		glUniformMatrix(uniformViewPrjInvPoint,  "viewprojectioninverse")
	else --beam
		glUseShader(depthBeamShader)
		glUniform(uniformEyePosBeam, cpx, cpy, cpz)
		glUniformMatrix(uniformViewPrjInvBeam,  "viewprojectioninverse")
	end

	glTexture(0, "$model_gbuffer_normtex")
	glTexture(1, "$model_gbuffer_zvaltex")
	glTexture(2, "$map_gbuffer_normtex")
	glTexture(3, "$map_gbuffer_zvaltex")
	glTexture(4, "$model_gbuffer_spectex")
	
	local cx, cy, cz = spGetCameraPosition()
	for i = 1, lightsCount do
		local light = lights[i]
		local param = light.param
		VerboseEcho('gfx_deferred_rendering.lua: Light being drawn:', i, to_string(light))
		if lighttype == 0 then -- point
			local lightradius = param.radius
			--Spring.Echo("Drawlighttype position = ", light.px, light.py, light.pz)
			local sx, sy, sz = spWorldToScreenCoords(light.px, light.py, light.pz) -- returns x, y, z, where x and y are screen pixels, and z is z buffer depth.
			sx = sx/vsx
			sy = sy/vsy --since FOV is static in the Y direction, the Y ratio is the correct one
			local dist_sq = (light.px-cx)^2 + (light.py-cy)^2 + (light.pz-cz)^2
			local ratio = lightradius / math.sqrt(dist_sq) * 1.5
			glUniform(lightposlocPoint, light.px, light.py, light.pz, param.radius) --in world space
			glUniform(lightcolorlocPoint, param.r, param.g, param.b, 1) 
			glTexRect(
				math.max(-1 , (sx-0.5)*2-ratio*screenratio), 
				math.max(-1 , (sy-0.5)*2-ratio), 
				math.min( 1 , (sx-0.5)*2+ratio*screenratio), 
				math.min( 1 , (sy-0.5)*2+ratio), 
				math.max( 0 , sx - 0.5*ratio*screenratio), 
				math.max( 0 , sy - 0.5*ratio), 
				math.min( 1 , sx + 0.5*ratio*screenratio),
				math.min( 1 , sy + 0.5*ratio)
			) -- screen size goes from -1, -1 to 1, 1; uvs go from 0, 0 to 1, 1
		end 
		if lighttype == 1 then -- beam
			local lightradius = 0
			local px = light.px+light.dx*0.5
			local py = light.py+light.dy*0.5
			local pz = light.pz+light.dz*0.5
			local lightradius = param.radius + math.sqrt(light.dx^2 + light.dy^2 + light.dz^2)*0.5
			--Spring.Echo("Drawlighttype position = ", light.px, light.py, light.pz)
			local sx, sy, sz = spWorldToScreenCoords(px, py, pz) -- returns x, y, z, where x and y are screen pixels, and z is z buffer depth.
			sx = sx/vsx
			sy = sy/vsy --since FOV is static in the Y direction, the Y ratio is the correct one
			local dist_sq = (px-cx)^2 + (py-cy)^2 + (pz-cz)^2
			local ratio = lightradius / math.sqrt(dist_sq)
			ratio = ratio*2

			glUniform(lightposlocBeam, light.px, light.py, light.pz, param.radius) --in world space
			glUniform(lightpos2locBeam, light.px+light.dx, light.py+light.dy+24, light.pz+light.dz, param.radius) --in world space, the magic constant of +24 in the Y pos is needed because of our beam distance calculator function in GLSL
			glUniform(lightcolorlocBeam, param.r * light.colMult, param.g * light.colMult, param.b * light.colMult, 1) 
			--TODO: use gl.Shape instead, to avoid overdraw
			glTexRect(
				math.max(-1 , (sx-0.5)*2-ratio*screenratio), 
				math.max(-1 , (sy-0.5)*2-ratio), 
				math.min( 1 , (sx-0.5)*2+ratio*screenratio), 
				math.min( 1 , (sy-0.5)*2+ratio), 
				math.max( 0 , sx - 0.5*ratio*screenratio), 
				math.max( 0 , sy - 0.5*ratio), 
				math.min( 1 , sx + 0.5*ratio*screenratio),
				math.min( 1 , sy + 0.5*ratio)
			) -- screen size goes from -1, -1 to 1, 1; uvs go from 0, 0 to 1, 1
		end
	end
	glUseShader(0)
end

local function GetCameraHeight()
	local camX, camY, camZ = Spring.GetCameraPosition()
	return camY - math.max(Spring.GetGroundHeight(camX, camZ), 0)
end

local function ProjectileLevelOfDetailCheck(param, proID, fps, height)
	if param.cameraHeightLimit and param.cameraHeightLimit < height then
		if param.cameraHeightLimit*3 > height then
			local fraction = param.cameraHeightLimit/height
			if fps < 60 then
				fraction = fraction*fps/60
			end
			local ratio = 1/fraction
			return (proID%ratio < 1)
		else
			return false
		end
	end
	
	if param.beam then
		return true
	end
	
	if fps < 60 then
		local fraction = fps/60
		local ratio = 1/fraction
		return (proID%ratio < 1)
	end
	return true
end

function widget:DrawWorld()
	if not (GLSLRenderer) then
		Spring.Echo('Removing deferred rendering widget: failed to use GLSL shader')
		widgetHandler:RemoveWidget()
		return
	end
	
	local projectiles = spGetVisibleProjectiles()
	if #projectiles == 0 then
		return
	end
	
	local fps = Spring.GetFPS()
	local cameraHeight = math.floor(GetCameraHeight()*0.01)*100
	--Spring.Echo("cameraHeight", cameraHeight, "fps", fps)
	
	local beamlightprojectiles = {}
	local beamLightCount = 0
	local pointlightprojectiles = {}
	local pointLightCount = 0
	local no_duplicate_projectileIDs_hackyfix = {}
	for i, pID in ipairs(projectiles) do
		if no_duplicate_projectileIDs_hackyfix[pID] == nil then -- hacky hotfix for https://springrts.com/mantis/view.php?id=4551
			--Spring.Echo(Spring.GetDrawFrame(), i, pID)
			no_duplicate_projectileIDs_hackyfix[pID] = true
			local x, y, z = spGetProjectilePosition(pID)
			--Spring.Echo("projectilepos = ", x, y, z, 'id', pID)
			local weapon, piece = spGetProjectileType(pID)
			if piece then
				local explosionflags = spGetPieceProjectileParams(pID)
				if explosionflags and (explosionflags%32) > 15  then --only stuff with the FIRE explode tag gets a light
					--Spring.Echo('explosionflag = ', explosionflags)
					pointLightCount = pointLightCount + 1
					pointlightprojectiles[pointLightCount] = {px = x, py = y, pz = z, param = overrideParam or gibParams}
				end
			else
				lightParams = projectileLightTypes[spGetProjectileDefID(pID)]
				if wantLoadParams then
					LoadParams(lightParams)
				end
				if lightParams and ProjectileLevelOfDetailCheck(lightParams, pID, fps, cameraHeight) then
					if lightParams.beam then --BEAM type
						local deltax, deltay, deltaz = spGetProjectileVelocity(pID) -- for beam types, this returns the endpoint of the beam]
						if lightParams.beamOffset then
							local m = lightParams.beamOffset
							x, y, z = x - deltax*m, y - deltay*m, z - deltaz*m
						end
						if lightParams.beamStartOffset then
							local m = lightParams.beamStartOffset
							x, y, z = x + deltax*m, y + deltay*m, z + deltaz*m
							deltax, deltay, deltaz = deltax*(1 - m), deltay*(1 - m), deltaz*(1 - m) 
						end
						beamLightCount = beamLightCount + 1
						beamlightprojectiles[beamLightCount] = {px = x, py = y, pz = z, dx = deltax, dy = deltay, dz = deltaz, param = overrideParam or lightParams}
						if lightParams.fadeTime then
							local timeToLive = Spring.GetProjectileTimeToLive(pID)
							beamlightprojectiles[beamLightCount].colMult = timeToLive/lightParams.fadeTime
						else
							beamlightprojectiles[beamLightCount].colMult = 1
						end
					else -- point type
						if not (lightParams.groundHeightLimit and lightParams.groundHeightLimit < (y - math.max(Spring.GetGroundHeight(y, y), 0))) then
							pointLightCount = pointLightCount + 1
							pointlightprojectiles[pointLightCount] = {px = x, py = y, pz = z, param = overrideParam or lightParams}
						end
					end
				end
			end
		end
	end 
	
	glBlending(GL.DST_COLOR, GL.ONE) -- VERY IMPORTANT: ResultR = LightR*DestinationR+1*DestinationR
	--http://www.andersriggelsen.dk/glblendfunc.php
	--glBlending(GL.ONE, GL.ZERO) --default
	if beamLightCount > 0 then
		DrawLightType(beamlightprojectiles, beamLightCount, 1)
	end
	if pointLightCount > 0 then
		DrawLightType(pointlightprojectiles, pointLightCount, 0)
	end
	glBlending(false)
end

function to_string(data, indent)
	local str = ""

	if (indent == nil) then
		indent = 0
	end

	-- Check the type
	if (type(data) == "string") then
		str = str .. ("    "):rep(indent) .. data .. "\n"
	elseif (type(data) == "number") then
		str = str .. ("    "):rep(indent) .. data .. "\n"
	elseif (type(data) == "boolean") then
		if (data == true) then
			str = str .. "true"
		else
			str = str .. "false"
		end
	elseif (type(data) == "table") then
		local i, v
		for i, v in pairs(data) do
			-- Check for a table in a table
			if(type(v) == "table") then
				str = str .. ("    "):rep(indent) .. i .. ":\n"
				str = str .. to_string(v, indent + 2)
			else
				str = str .. ("    "):rep(indent) .. i .. ": " .. to_string(v, 0)
			end
		end
	elseif (data == nil) then
		str = str..'nil'
	else
		--print_debug(1, "Error: unknown data type: %s", type(data))
		str = str.. "Error: unknown data type:" .. type(data)
		Spring.Echo('X data type')
	end

	return str
end