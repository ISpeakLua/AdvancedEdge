--[[ VERSION 1.1

	Credits to https://www.roblox.com/users/475095290/profile/
	Modded by dauser#1103

]]

local compressor = loadstring(game:HttpGet('https://raw.githubusercontent.com/ISpeakLua/AdvancedEdge/main/Utils/Compression'))()

local Module = {
	__Instance = {
		datas = {
			classNameId = {}
		},
		compression = {},
		insert = game:GetService("InsertService"),
		HttpService = game:GetService("HttpService"),
		configuration = {
			isPlugin = false,
			ignoreMissingObject = true,
			useBase93Encoding = false,
		},
		allASCII = "1234567890ABCDEFGHIJKLMNOPQRSTUVWYZabcdefghijklmnopqstuvwxyz_+"
	},
}
function Module.__Instance.randomString(len)
	local allASCII = Module.__Instance.allASCII
	local ran = Random.new()
	local r = ""
	len = len or 0
	local asL = #allASCII
	for i=1,len do
		local p = ran:NextInteger(0,asL)
		r=r..allASCII:sub(p,p)
	end
	return r
end
function Module.__Instance.createUniqueId(n)
	local allASCII = Module.__Instance.allASCII
	n = math.floor(n)
	local b,t,s = #allASCII,{},""
	if n < 0 then
		s = "-"
		n = -n
	end
	repeat
		local d = (n % b) + 1 n = math.floor(n / b) table.insert(t, 1, allASCII:sub(d,d))
	until n == 0
	return s..table.concat(t,"")
end
function Module.__Instance.baseDecode(s)
	local encodedBase = #Module.__Instance.allASCII
	local base = Module.__Instance.allASCII:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
	local positive = true
	if s:sub(1,1) == "-" then
		positive = false
		s = s:sub(2,-1)
	end
	local returnNumber = 0
	local len = #s
	for i=1,len do
		local currentCharacter = s:sub(i,i)
		local characterValue = (base:find(currentCharacter:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")) - 1) * encodedBase ^ (len - i)
		returnNumber = returnNumber + characterValue
	end
	return if positive then returnNumber else -returnNumber
end
do
	-- credits: https://devforum.roblox.com/t/text-compression/163637
	local dictionary, length = {}, 0
	for i = 32, 127 do
		if i ~= 34 and i ~= 92 then
			local c = string.char(i)
			dictionary[c], dictionary[length] = length, c
			length = length + 1
		end
	end
	local escapemap = {}
	for i = 1, 34 do
		i = ({34, 92, 127})[i-31] or i
		local c, e = string.char(i), string.char(i + 31)
		escapemap[c], escapemap[e] = e, c
	end
	local function escape(s)
		return (s:gsub("[%c\"\\]", function(c)
			return "\127"..escapemap[c]
		end))
	end
	local function unescape(s)
		return (s:gsub("\127(.)", function(c)
			return escapemap[c]
		end))
	end
	local function copy(t)
		local new = {}
		for k, v in pairs(t) do
			new[k] = v
		end
		return new
	end
	local function tobase93(n)
		local value = ""
		repeat
			local remainder = n%93
			value = dictionary[remainder]..value
			n = (n - remainder)/93
		until n == 0
		return value
	end
	local function tobase10(value)
		local n = 0
		for i = 1, #value do
			n = n + 93^(i-1)*dictionary[value:sub(-i, -i)]
		end
		return n
	end
	local function compress(text)
		local dictionary = copy(dictionary)
		local key, sequence, size = "", {}, #dictionary
		local width, spans, span = 1, {}, 0
		local function listkey(key)
			local value = tobase93(dictionary[key])
			if #value > width then
				width, span, spans[width] = #value, 0, span
			end
			sequence[#sequence+1] = (" "):rep(width - #value)..value
			span = span + 1
		end
		text = escape(text)
		for i = 1, #text do
			local c = text:sub(i, i)
			local new = key..c
			if dictionary[new] then
				key = new
			else
				listkey(key)
				key, size = c, size+1
				dictionary[new], dictionary[size] = size, new
			end
		end
		listkey(key)
		spans[width] = span
		return table.concat(spans, ",").."|"..table.concat(sequence)
	end
	local function decompress(text)
		local dictionary = copy(dictionary)
		local sequence, spans, content = {}, text:match("(.-)|(.*)")
		local groups, start = {}, 1
		for span in spans:gmatch("%d+") do
			local width = #groups+1
			groups[width] = content:sub(start, start + span*width - 1)
			start = start + span*width
		end
		local previous;
		for width = 1, #groups do
			for value in groups[width]:gmatch(('.'):rep(width)) do
				local entry = dictionary[tobase10(value)]
				if previous then
					if entry then
						sequence[#sequence+1] = entry
						dictionary[#dictionary+1] = previous..entry:sub(1, 1)
					else
						entry = previous..previous:sub(1, 1)
						sequence[#sequence+1] = entry
						dictionary[#dictionary+1] = entry
					end
				else
					sequence[1] = entry
				end
				previous = entry
			end
		end
		return unescape(table.concat(sequence))
	end
	Module.__Instance.compression = {Compress = compress,Decompress = decompress}
end
do
	Module.__Instance.datas.properties = {
		["Unknown"] = {},
		["Accessory"] = {
			"AttachmentForward",
			"AttachmentPoint",
			"AttachmentPos",
			"AttachmentRight",
			"AttachmentUp"
		},
		["Accoutrement"] = {
			"AttachmentForward",
			"AttachmentPoint",
			"AttachmentPos",
			"AttachmentRight",
			"AttachmentUp"
		},
		["AdService"] = {},
		["AdvancedDragger"] = {},
		["AlignOrientation"] = {
			"Attachment0",
			"Attachment1",
			"Color",
			"Enabled",
			"MaxAngularVelocity",
			"MaxTorque",
			"PrimaryAxisOnly",
			"ReactionTorqueEnabled",
			"Responsiveness",
			"RigidityEnabled",
			"Visible"
		},
		["AlignPosition"] = {
			"ApplyAtCenterOfMass",
			"Attachment0",
			"Attachment1",
			"Color",
			"Enabled",
			"MaxForce",
			"MaxVelocity",
			"ReactionForceEnabled",
			"Responsiveness",
			"RigidityEnabled",
			"Visible"
		},
		["AnalysticsSettings"] = {},
		["AnalyticsService"] = {},
		["Animation"] = {
			"AnimationId"
		},
		["AnimationController"] = {},
		["AnimationTrack"] = {
			"Looped",
			"Priority",
			"TimePosition"
		},
		["Animator"] = {},
		["ArcHandles"] = {
			"Adornee",
			"Axes",
			"Color3",
			"Transparency",
			"Visible"
		},
		["AssetService"] = {},
		["Attachment"] = {
			"Axis",
			"CFrame",
			"Orientation",
			"Position",
			"Rotation",
			"SecondaryAxis",
			"Visible"
		},
		["Backpack"] = {},
		["BackpackItem"] = {
			"TextureId"
		},
		["BadgeService"] = {},
		["BallSocketConstraint"] = {
			"Attachment0",
			"Attachment1",
			"Color",
			"Enabled",
			"LimitsEnabled",
			"Radius",
			"Restitution",
			"TwistLimitsEnabled",
			"TwistLowerAngle",
			"TwistUpperAngle",
			"UpperAngle",
			"Visible"
		},
		["BasePart"] = {
			"Anchored",
			"BackParamA",
			"BackParamB",
			"BackSurface",
			"BackSurfaceInput",
			"BottomParamA",
			"BottomParamB",
			"BottomSurface",
			"BottomSurfaceInput",
			"CanCollide",
			"CollisionGroupId",
			"Color",
			"CustomPhysicalProperties",
			"FrontParamA",
			"FrontParamB",
			"FrontSurface",
			"FrontSurfaceInput",
			"LeftParamA",
			"LeftParamB",
			"LeftSurface",
			"LeftSurfaceInput",
			"Locked",
			"Material",
			"Orientation",
			"Position",
			"Reflectance",
			"RightParamA",
			"RightParamB",
			"RightSurface",
			"RightSurfaceInput",
			"RotVelocity",
			"Rotation",
			"Size",
			"TopParamA",
			"TopParamB",
			"TopSurface",
			"TopSurfaceInput",
			"Transparency",
			"Velocity"
		},
		["BasePlayerGui"] = {},
		["BaseScript"] = {
			"Disabled",
			"Enabled",
			"LinkedSource"
		},
		["Beam"] = {
			"Attachment0",
			"Attachment1",
			"Color",
			"CurveSize0",
			"CurveSize1",
			"Enabled",
			"FaceCamera",
			"LightEmission",
			"LightInfluence",
			"Segments",
			"Texture",
			"TextureLength",
			"TextureMode",
			"TextureSpeed",
			"Transparency",
			"Width0",
			"Width1",
			"ZOffset"
		},
		["BevelMesh"] = {
			"Offset",
			"Scale",
			"VertexColor"
		},
		["BillboardGui"] = {
			"Active",
			"Adornee",
			"AlwaysOnTop",
			"AutoLocalize",
			"ClipsDescendants",
			"Enabled",
			"ExtentsOffset",
			"ExtentsOffsetWorldSpace",
			"LightInfluence",
			"MaxDistance",
			"PlayerToHideFrom",
			"ResetOnSpawn",
			"RootLocalizationTable",
			"Size",
			"SizeOffset",
			"StudsOffset",
			"StudsOffsetWorldSpace",
			"ZIndexBehavior"
		},
		["BinaryStringValue"] = {},
		["BindableEvent"] = {},
		["BindableFunction"] = {},
		["BlockMesh"] = {
			"Offset",
			"Scale",
			"VertexColor"
		},
		["BloomEffect"] = {
			"Enabled",
			"Intensity",
			"Size",
			"Threshold"
		},
		["BlurEffect"] = {
			"Enabled",
			"Size"
		},
		["BodyAngularVelocity"] = {
			"AngularVelocity",
			"MaxTorque",
			"P"
		},
		["BodyColors"] = {
			"HeadColor",
			"HeadColor3",
			"LeftArmColor",
			"LeftArmColor3",
			"LeftLegColor",
			"LeftLegColor3",
			"RightArmColor",
			"RightArmColor3",
			"RightLegColor",
			"RightLegColor3",
			"TorsoColor",
			"TorsoColor3"
		},
		["BodyForce"] = {
			"Force"
		},
		["BodyGyro"] = {
			"CFrame",
			"D",
			"MaxTorque",
			"P"
		},
		["BodyMover"] = {},
		["BodyPosition"] = {
			"D",
			"MaxForce",
			"P",
			"Position"
		},
		["BodyThrust"] = {
			"Force",
			"Location"
		},
		["BodyVelocity"] = {
			"MaxForce",
			"P",
			"Velocity"
		},
		["BoolValue"] = {
			"Value"
		},
		["BoxHandleAdornment"] = {
			"Adornee",
			"AlwaysOnTop",
			"CFrame",
			"Color3",
			"Size",
			"SizeRelativeOffset",
			"Transparency",
			"Visible",
			"ZIndex"
		},
		["BrickColorValue"] = {
			"Value"
		},
		["Button"] = {
			"ClickableWhenViewportHidden",
			"Enabled",
			"Icon"
		},
		["ButtonBindingWidget"] = {},
		["CFrameValue"] = {
			"Value"
		},
		["CSGDictionaryService"] = {},
		["CacheableContentProvider"] = {},
		["Camera"] = {
			"CFrame",
			"CameraSubject",
			"CameraType",
			"FieldOfView",
			"Focus",
			"HeadLocked",
			"HeadScale"
		},
		["ChangeHistoryService"] = {},
		["CharacterAppearance"] = {},
		["CharacterMesh"] = {
			"BaseTextureId",
			"BodyPart",
			"OverlayTextureId"
		},
		["Chat"] = {},
		["ChorusSoundEffect"] = {
			"Depth",
			"Enabled",
			"Mix",
			"Priority",
			"Rate"
		},
		["ClickDetector"] = {
			"CursorIcon",
			"MaxActivationDistance"
		},
		["ClientReplicator"] = {},
		["Clothing"] = {},
		["ClusterPacketCache"] = {},
		["CollectionService"] = {},
		["Color3Value"] = {
			"Value"
		},
		["ColorCorrectionEffect"] = {
			"Brightness",
			"Contrast",
			"Enabled",
			"Saturation",
			"TintColor"
		},
		["CompressorSoundEffect"] = {
			"Attack",
			"Enabled",
			"GainMakeup",
			"Priority",
			"Ratio",
			"Release",
			"SideChain",
			"Threshold"
		},
		["ConeHandleAdornment"] = {
			"Adornee",
			"AlwaysOnTop",
			"CFrame",
			"Color3",
			"Height",
			"Radius",
			"SizeRelativeOffset",
			"Transparency",
			"Visible",
			"ZIndex"
		},
		["Configuration"] = {},
		["Constraint"] = {
			"Attachment0",
			"Attachment1",
			"Color",
			"Enabled",
			"Visible"
		},
		["ContentProvider"] = {},
		["ContextActionService"] = {},
		["Controller"] = {},
		["ControllerService"] = {},
		["CookiesService"] = {},
		["CoreGui"] = {},
		["CorePackages"] = {},
		["CoreScript"] = {
			"Disabled",
			"Enabled",
			"LinkedSource",
		},
		["CornerWedgePart"] = {
			"Anchored",
			"BackParamA",
			"BackParamB",
			"BackSurface",
			"BackSurfaceInput",
			"BottomParamA",
			"BottomParamB",
			"BottomSurface",
			"BottomSurfaceInput",
			"CanCollide",
			"CollisionGroupId",
			"Color",
			"CustomPhysicalProperties",
			"FrontParamA",
			"FrontParamB",
			"FrontSurface",
			"FrontSurfaceInput",
			"LeftParamA",
			"LeftParamB",
			"LeftSurface",
			"LeftSurfaceInput",
			"Locked",
			"Material",
			"Orientation",
			"Position",
			"Reflectance",
			"RightParamA",
			"RightParamB",
			"RightSurface",
			"RightSurfaceInput",
			"RotVelocity",
			"Rotation",
			"Size",
			"TopParamA",
			"TopParamB",
			"TopSurface",
			"TopSurfaceInput",
			"Transparency",
			"Velocity"
		},
		["CustomEvent"] = {},
		["CustomEventReceiver"] = {
			"Source"
		},
		["CylinderHandleAdornment"] = {
			"Adornee",
			"AlwaysOnTop",
			"CFrame",
			"Color3",
			"Height",
			"Radius",
			"SizeRelativeOffset",
			"Transparency",
			"Visible",
			"ZIndex"
		},
		["CylinderMesh"] = {
			"Offset",
			"Scale",
			"VertexColor"
		},
		["CylindricalConstraint"] = {
			"ActuatorType",
			"AngularActuatorType",
			"AngularLimitsEnabled",
			"AngularRestitution",
			"AngularSpeed",
			"AngularVelocity",
			"Attachment0",
			"Attachment1",
			"Color",
			"Enabled",
			"InclinationAngle",
			"LimitsEnabled",
			"LowerAngle",
			"LowerLimit",
			"MotorMaxAcceleration",
			"MotorMaxAngularAcceleration",
			"MotorMaxForce",
			"MotorMaxTorque",
			"Restitution",
			"RotationAxisVisible",
			"ServoMaxForce",
			"ServoMaxTorque",
			"Size",
			"Speed",
			"TargetAngle",
			"TargetPosition",
			"UpperAngle",
			"UpperLimit",
			"Velocity",
			"Visible"
		},
		["DataModel"] = {},
		["DataModelMesh"] = {
			"Offset",
			"Scale",
			"VertexColor"
		},
		["DataStorePages"] = {},
		["DataStoreService"] = {},
		["Debris"] = {},
		["DebugSettings"] = {
			"ErrorReporting",
			"IsFmodProfilingEnabled",
			"IsScriptStackTracingEnabled",
			"LuaRamLimit",
			"ReportSoundWarnings",
			"TickCountPreciseOverride"
		},
		["DebuggerBreakpoint"] = {
			"Condition",
			"IsEnabled"
		},
		["DebuggerManager"] = {},
		["DebuggerWatch"] = {
			"Expression"
		},
		["Decal"] = {
			"Color3",
			"Face",
			"Texture",
			"Transparency"
		},
		["Dialog"] = {
			"BehaviorType",
			"ConversationDistance",
			"GoodbyeChoiceActive",
			"GoodbyeDialog",
			"InUse",
			"InitialPrompt",
			"Purpose",
			"Tone",
			"TriggerDistance",
			"TriggerOffset"
		},
		["DialogChoice"] = {
			"GoodbyeChoiceActive",
			"GoodbyeDialog",
			"ResponseDialog",
			"UserDialog"
		},
		["DistortionSoundEffect"] = {
			"Enabled",
			"Level",
			"Priority"
		},
		["DockWidgetPluginGui"] = {
			"AutoLocalize",
			"Enabled",
			"ResetOnSpawn",
			"RootLocalizationTable",
			"Title",
			"ZIndexBehavior"
		},
		["DoubleConstrainedValue"] = {
			"MaxValue",
			"MinValue",
			"Value"
		},
		["Dragger"] = {},
		["DynamicRotate"] = {
			"BaseAngle",
			"C0",
			"C1",
			"Part0",
			"Part1"
		},
		["EchoSoundEffect"] = {
			"Delay",
			"DryLevel",
			"Enabled",
			"Feedback",
			"Priority",
			"WetLevel"
		},
		["EqualizerSoundEffect"] = {
			"Enabled",
			"HighGain",
			"LowGain",
			"MidGain",
			"Priority"
		},
		["Explosion"] = {
			"BlastPressure",
			"BlastRadius",
			"DestroyJointRadiusPercent",
			"ExplosionType",
			"Position",
			"Visible"
		},
		["FaceInstance"] = {
			"Face"
		},
		["Feature"] = {
			"FaceId",
			"InOut",
			"LeftRight",
			"TopBottom"
		},
		["FileMesh"] = {
			"MeshId",
			"Offset",
			"Scale",
			"TextureId",
			"VertexColor"
		},
		["Fire"] = {
			"Color",
			"Enabled",
			"Heat",
			"SecondaryColor",
			"Size"
		},
		["Flag"] = {
			"CanBeDropped",
			"Enabled",
			"Grip",
			"GripForward",
			"GripPos",
			"GripRight",
			"GripUp",
			"ManualActivationOnly",
			"RequiresHandle",
			"TeamColor",
			"TextureId",
			"ToolTip"
		},
		["FlagStand"] = {
			"Anchored",
			"BackParamA",
			"BackParamB",
			"BackSurface",
			"BackSurfaceInput",
			"BottomParamA",
			"BottomParamB",
			"BottomSurface",
			"BottomSurfaceInput",
			"CFrame",
			"CanCollide",
			"CollisionGroupId",
			"Color",
			"CustomPhysicalProperties",
			"FrontParamA",
			"FrontParamB",
			"FrontSurface",
			"FrontSurfaceInput",
			"LeftParamA",
			"LeftParamB",
			"LeftSurface",
			"LeftSurfaceInput",
			"Locked",
			"Material",
			"Orientation",
			"Position",
			"Reflectance",
			"RightParamA",
			"RightParamB",
			"RightSurface",
			"RightSurfaceInput",
			"RotVelocity",
			"Rotation",
			"Shape",
			"Size",
			"TeamColor",
			"TopParamA",
			"TopParamB",
			"TopSurface",
			"TopSurfaceInput",
			"Transparency",
			"Velocity"
		},
		["FlagStandService"] = {},
		["FlangeSoundEffect"] = {
			"Depth",
			"Enabled",
			"Mix",
			"Priority",
			"Rate"
		},
		["FloorWire"] = {
			"Color3",
			"CycleOffset",
			"From",
			"StudsBetweenTextures",
			"Texture",
			"TextureSize",
			"To",
			"Transparency",
			"Velocity",
			"Visible",
			"WireRadius"
		},
		["FlyweightService"] = {},
		["Folder"] = {},
		["ForceField"] = {
			"Visible"
		},
		["FormFactorPart"] = {
			"Anchored",
			"BackParamA",
			"BackParamB",
			"BackSurface",
			"BackSurfaceInput",
			"BottomParamA",
			"BottomParamB",
			"BottomSurface",
			"BottomSurfaceInput",
			"CFrame",
			"CanCollide",
			"CollisionGroupId",
			"Color",
			"CustomPhysicalProperties",
			"FrontParamA",
			"FrontParamB",
			"FrontSurface",
			"FrontSurfaceInput",
			"LeftParamA",
			"LeftParamB",
			"LeftSurface",
			"LeftSurfaceInput",
			"Locked",
			"Material",
			"Orientation",
			"Position",
			"Reflectance",
			"RightParamA",
			"RightParamB",
			"RightSurface",
			"RightSurfaceInput",
			"RotVelocity",
			"Rotation",
			"Size",
			"TopParamA",
			"TopParamB",
			"TopSurface",
			"TopSurfaceInput",
			"Transparency",
			"Velocity"
		},
		["Frame"] = {
			"Active",
			"AnchorPoint",
			"AutoLocalize",
			"BackgroundColor3",
			"BackgroundTransparency",
			"BorderColor3",
			"BorderSizePixel",
			"ClipsDescendants",
			"LayoutOrder",
			"NextSelectionDown",
			"NextSelectionLeft",
			"NextSelectionRight",
			"NextSelectionUp",
			"Position",
			"RootLocalizationTable",
			"Rotation",
			"Selectable",
			"SelectionImageObject",
			"Size",
			"SizeConstraint",
			"Style",
			"Visible",
			"ZIndex"
		},
		["FriendPages"] = {},
		["FriendService"] = {},
		["FunctionalTest"] = {
			"Description"
		},
		["GamePassService"] = {},
		["GameSettings"] = {
			"AdditionalCoreIncludeDirs",
			"BubbleChatLifetime",
			"BubbleChatMaxBubbles",
			"ChatHistory",
			"ChatScrollLength",
			"HardwareMouse",
			"OverrideStarterScript",
			"ReportAbuseChatHistory",
			"SoftwareSound",
			"VideoCaptureEnabled",
			"VideoQuality"
		},
		["GamepadService"] = {},
		["GenericSettings"] = {},
		["Geometry"] = {},
		["GlobalDataStore"] = {},
		["GlobalSettings"] = {},
		["Glue"] = {
			"C0",
			"C1",
			"F0",
			"F1",
			"F2",
			"F3",
			"Part0",
			"Part1"
		},
		["GoogleAnalyticsConfiguration"] = {},
		["GroupService"] = {},
		["GuiBase"] = {},
		["GuiBase2d"] = {
			"AutoLocalize",
			"RootLocalizationTable"
		},
		["GuiBase3d"] = {
			"Color3",
			"Transparency",
			"Visible"
		},
		["GuiButton"] = {
			"Active",
			"AnchorPoint",
			"AutoButtonColor",
			"AutoLocalize",
			"BackgroundColor3",
			"BackgroundTransparency",
			"BorderColor3",
			"BorderSizePixel",
			"ClipsDescendants",
			"LayoutOrder",
			"Modal",
			"NextSelectionDown",
			"NextSelectionLeft",
			"NextSelectionRight",
			"NextSelectionUp",
			"Position",
			"RootLocalizationTable",
			"Rotation",
			"Selectable",
			"Selected",
			"SelectionImageObject",
			"Size",
			"SizeConstraint",
			"Style",
			"Visible",
			"ZIndex"
		},
		["GuiItem"] = {},
		["GuiLabel"] = {
			"Active",
			"AnchorPoint",
			"AutoLocalize",
			"BackgroundColor3",
			"BackgroundTransparency",
			"BorderColor3",
			"BorderSizePixel",
			"ClipsDescendants",
			"LayoutOrder",
			"NextSelectionDown",
			"NextSelectionLeft",
			"NextSelectionRight",
			"NextSelectionUp",
			"Position",
			"RootLocalizationTable",
			"Rotation",
			"Selectable",
			"SelectionImageObject",
			"Size",
			"SizeConstraint",
			"Visible",
			"ZIndex"
		},
		["GuiMain"] = {
			"AutoLocalize",
			"DisplayOrder",
			"Enabled",
			"IgnoreGuiInset",
			"ResetOnSpawn",
			"RootLocalizationTable",
			"ZIndexBehavior"
		},
		["GuiObject"] = {
			"Active",
			"AnchorPoint",
			"AutoLocalize",
			"BackgroundColor3",
			"BackgroundTransparency",
			"BorderColor3",
			"BorderSizePixel",
			"ClipsDescendants",
			"LayoutOrder",
			"NextSelectionDown",
			"NextSelectionLeft",
			"NextSelectionRight",
			"NextSelectionUp",
			"Position",
			"RootLocalizationTable",
			"Rotation",
			"Selectable",
			"SelectionImageObject",
			"Size",
			"SizeConstraint",
			"Visible",
			"ZIndex"
		},
		["GuiRoot"] = {},
		["GuiService"] = {
			"AutoSelectGuiEnabled",
			"CoreGuiNavigationEnabled",
			"GuiNavigationEnabled",
			"SelectedObject"
		},
		["GuidRegistryService"] = {},
		["HandleAdornment"] = {
			"Adornee",
			"AlwaysOnTop",
			"CFrame",
			"Color3",
			"SizeRelativeOffset",
			"Transparency",
			"Visible",
			"ZIndex"
		},
		["Handles"] = {
			"Adornee",
			"Color3",
			"Faces",
			"Style",
			"Transparency",
			"Visible"
		},
		["HandlesBase"] = {
			"Adornee",
			"Color3",
			"Transparency",
			"Visible"
		},
		["HapticService"] = {},
		["Hat"] = {
			"AttachmentForward",
			"AttachmentPoint",
			"AttachmentPos",
			"AttachmentRight",
			"AttachmentUp"
		},
		["HingeConstraint"] = {
			"ActuatorType",
			"AngularSpeed",
			"AngularVelocity",
			"Attachment0",
			"Attachment1",
			"Color",
			"Enabled",
			"LimitsEnabled",
			"LowerAngle",
			"MotorMaxAcceleration",
			"MotorMaxTorque",
			"Radius",
			"Restitution",
			"ServoMaxTorque",
			"TargetAngle",
			"UpperAngle",
			"Visible"
		},
		["Hint"] = {
			"Text"
		},
		["Hole"] = {
			"FaceId",
			"InOut",
			"LeftRight",
			"TopBottom"
		},
		["Hopper"] = {},
		["HopperBin"] = {
			"Active",
			"BinType",
			"TextureId"
		},
		["HttpRbxApiService"] = {},
		["HttpRequest"] = {},
		["HttpService"] = {},
		["Humanoid"] = {
			"AutoJumpEnabled",
			"AutoRotate",
			"AutomaticScalingEnabled",
			"CameraOffset",
			"DisplayDistanceType",
			"Health",
			"HealthDisplayDistance",
			"HealthDisplayType",
			"HipHeight",
			"Jump",
			"JumpPower",
			"MaxHealth",
			"MaxSlopeAngle",
			"NameDisplayDistance",
			"NameOcclusion",
			"PlatformStand",
			"RigType",
			"Sit",
			"TargetPoint",
			"WalkSpeed",
			"WalkToPart",
			"WalkToPoint"
		},
		["HumanoidController"] = {},
		["ImageButton"] = {
			"Active",
			"AnchorPoint",
			"AutoButtonColor",
			"AutoLocalize",
			"BackgroundColor3",
			"BackgroundTransparency",
			"BorderColor3",
			"BorderSizePixel",
			"ClipsDescendants",
			"HoverImage",
			"Image",
			"ImageColor3",
			"ImageRectOffset",
			"ImageRectSize",
			"ImageTransparency",
			"LayoutOrder",
			"Modal",
			"NextSelectionDown",
			"NextSelectionLeft",
			"NextSelectionRight",
			"NextSelectionUp",
			"Position",
			"PressedImage",
			"RootLocalizationTable",
			"Rotation",
			"ScaleType",
			"Selectable",
			"Selected",
			"SelectionImageObject",
			"Size",
			"SizeConstraint",
			"SliceCenter",
			"SliceScale",
			"Style",
			"TileSize",
			"Visible",
			"ZIndex"
		},
		["ImageHandleAdornment"] = {
			"Adornee",
			"AlwaysOnTop",
			"CFrame",
			"Color3",
			"Image",
			"Size",
			"SizeRelativeOffset",
			"Transparency",
			"Visible",
			"ZIndex"
		},
		["ImageLabel"] = {
			"Active",
			"AnchorPoint",
			"AutoLocalize",
			"BackgroundColor3",
			"BackgroundTransparency",
			"BorderColor3",
			"BorderSizePixel",
			"ClipsDescendants",
			"Image",
			"ImageColor3",
			"ImageRectOffset",
			"ImageRectSize",
			"ImageTransparency",
			"LayoutOrder",
			"NextSelectionDown",
			"NextSelectionLeft",
			"NextSelectionRight",
			"NextSelectionUp",
			"Position",
			"RootLocalizationTable",
			"Rotation",
			"ScaleType",
			"Selectable",
			"SelectionImageObject",
			"Size",
			"SizeConstraint",
			"SliceCenter",
			"SliceScale",
			"TileSize",
			"Visible",
			"ZIndex"
		},
		["InputObject"] = {
			"Delta",
			"KeyCode",
			"Position",
			"UserInputState",
			"UserInputType"
		},
		["InsertService"] = {},
		["Instance"] = {},
		["InstancePacketCache"] = {},
		["IntConstrainedValue"] = {
			"MaxValue",
			"MinValue",
			"Value"
		},
		["IntValue"] = {
			"Value"
		},
		["InventoryPages"] = {},
		["JointInstance"] = {
			"C0",
			"C1",
			"Part0",
			"Part1"
		},
		["JointsService"] = {},
		["KeyboardService"] = {},
		["Keyframe"] = {
			"Time"
		},
		["KeyframeSequence"] = {
			"Loop",
			"Priority"
		},
		["KeyframeMarker"] = {
			"Value",
		},
		["KeyframeSequenceProvider"] = {},
		["LayerCollector"] = {
			"AutoLocalize",
			"Enabled",
			"ResetOnSpawn",
			"RootLocalizationTable",
			"ZIndexBehavior"
		},
		["Light"] = {
			"Brightness",
			"Color",
			"Enabled",
			"Shadows"
		},
		["Lighting"] = {
			"Ambient",
			"Brightness",
			"ClockTime",
			"ColorShift_Bottom",
			"ColorShift_Top",
			"ExposureCompensation",
			"FogColor",
			"FogEnd",
			"FogStart",
			"GeographicLatitude",
			"GlobalShadows",
			"OutdoorAmbient",
			"Outlines",
			"TimeOfDay"
		},
		["LineForce"] = {
			"ApplyAtCenterOfMass",
			"Attachment0",
			"Attachment1",
			"Color",
			"Enabled",
			"InverseSquareLaw",
			"Magnitude",
			"MaxForce",
			"ReactionForceEnabled",
			"Visible"
		},
		["LineHandleAdornment"] = {
			"Adornee",
			"AlwaysOnTop",
			"CFrame",
			"Color3",
			"Length",
			"SizeRelativeOffset",
			"Thickness",
			"Transparency",
			"Visible",
			"ZIndex"
		},
		["LocalScript"] = {
			"Disabled",
			"Enabled",
			"LinkedSource",
		},
		["LocalizationService"] = {},
		["LocalizationTable"] = {
			"SourceLocaleId"
		},
		["LogService"] = {},
		["LoginService"] = {},
		["LuaSettings"] = {
			"AreScriptStartsReported",
			"DefaultWaitTime",
			"GcFrequency",
			"GcLimit",
			"GcPause",
			"GcStepMul",
			"WaitingThreadsBudget"
		},
		["LuaSourceContainer"] = {},
		["LuaWebService"] = {},
		["ManualGlue"] = {
			"C0",
			"C1",
			"Part0",
			"Part1"
		},
		["ManualSurfaceJointInstance"] = {
			"C0",
			"C1",
			"Part0",
			"Part1"
		},
		["ManualWeld"] = {
			"C0",
			"C1",
			"Part0",
			"Part1"
		},
		["MarketplaceService"] = {},
		["MeshContentProvider"] = {},
		["MeshPart"] = {
			"Anchored",
			"BackParamA",
			"BackParamB",
			"BackSurface",
			"BackSurfaceInput",
			"BottomParamA",
			"BottomParamB",
			"BottomSurface",
			"BottomSurfaceInput",
			"CanCollide",
			"CollisionGroupId",
			"Color",
			"CustomPhysicalProperties",
			"FrontParamA",
			"FrontParamB",
			"FrontSurface",
			"FrontSurfaceInput",
			"LeftParamA",
			"LeftParamB",
			"LeftSurface",
			"LeftSurfaceInput",
			"Locked",
			"Material",
			"Orientation",
			"Position",
			"Reflectance",
			"RightParamA",
			"RightParamB",
			"RightSurface",
			"RightSurfaceInput",
			"RotVelocity",
			"Rotation",
			"Size",
			"TextureID",
			"TopParamA",
			"TopParamB",
			"TopSurface",
			"TopSurfaceInput",
			"Transparency",
			"Velocity",
		},
		["Message"] = {
			"Text"
		},
		["Model"] = {
			"PrimaryPart"
		},
		["ModuleScript"] = {
			"LinkedSource",
		},
		["Motor"] = {
			"C0",
			"C1",
			"CurrentAngle",
			"DesiredAngle",
			"MaxVelocity",
			"Part0",
			"Part1"
		},
		["Motor6D"] = {
			"C0",
			"C1",
			"CurrentAngle",
			"DesiredAngle",
			"MaxVelocity",
			"Part0",
			"Part1"
		},
		["MotorFeature"] = {
			"FaceId",
			"InOut",
			"LeftRight",
			"TopBottom"
		},
		["Mouse"] = {
			"Icon",
			"TargetFilter"
		},
		["MouseService"] = {},
		["NegateOperation"] = {
			"Anchored",
			"BackParamA",
			"BackParamB",
			"BackSurface",
			"BackSurfaceInput",
			"BottomParamA",
			"BottomParamB",
			"BottomSurface",
			"BottomSurfaceInput",
			"CFrame",
			"CanCollide",
			"CollisionGroupId",
			"Color",
			"CustomPhysicalProperties",
			"FrontParamA",
			"FrontParamB",
			"FrontSurface",
			"FrontSurfaceInput",
			"LeftParamA",
			"LeftParamB",
			"LeftSurface",
			"LeftSurfaceInput",
			"Locked",
			"Material",
			"Orientation",
			"Position",
			"Reflectance",
			"RightParamA",
			"RightParamB",
			"RightSurface",
			"RightSurfaceInput",
			"RotVelocity",
			"Rotation",
			"Size",
			"TopParamA",
			"TopParamB",
			"TopSurface",
			"TopSurfaceInput",
			"Transparency",
			"UsePartColor",
			"Velocity"
		},
		["NetworkClient"] = {
			"Ticket"
		},
		["NetworkMarker"] = {},
		["NetworkPeer"] = {},
		["NetworkReplicator"] = {},
		["NetworkServer"] = {},
		["NetworkSettings"] = {
			"ArePhysicsRejectionsReported",
			"ClientPhysicsSendRate",
			"DataGCRate",
			"DataMtuAdjust",
			"DataSendRate",
			"IncommingReplicationLag",
			"IsQueueErrorComputed",
			"NetworkOwnerRate",
			"PhysicsMtuAdjust",
			"PhysicsSendRate",
			"PreferredClientPort",
			"PrintBits",
			"PrintEvents",
			"PrintFilters",
			"PrintInstances",
			"PrintPhysicsErrors",
			"PrintProperties",
			"PrintSplitMessage",
			"PrintStreamInstanceQuota",
			"PrintTouches",
			"ReceiveRate",
			"RenderStreamedRegions",
			"ShowActiveAnimationAsset",
			"TouchSendRate",
			"TrackDataTypes",
			"TrackPhysicsDetails",
			"UseInstancePacketCache",
			"UsePhysicsPacketCache"
		},
		["NonReplicatedCSGDictionaryService"] = {},
		["NotificationService"] = {},
		["NumberValue"] = {
			"Value"
		},
		["ObjectValue"] = {
			"Value"
		},
		["OrderedDataStore"] = {},
		["PVAdornment"] = {
			"Adornee",
			"Color3",
			"Transparency",
			"Visible"
		},
		["PVInstance"] = {},
		["PackageLink"] = {},
		["Pages"] = {},
		["Pants"] = {
			"PantsTemplate"
		},
		["ParabolaAdornment"] = {
			"Adornee",
			"Color3",
			"Transparency",
			"Visible"
		},
		["Part"] = {
			"Anchored",
			"BackParamA",
			"BackParamB",
			"BackSurface",
			"BackSurfaceInput",
			"BottomParamA",
			"BottomParamB",
			"BottomSurface",
			"BottomSurfaceInput",
			"CanCollide",
			"CollisionGroupId",
			"Color",
			"CustomPhysicalProperties",
			"FrontParamA",
			"FrontParamB",
			"FrontSurface",
			"FrontSurfaceInput",
			"LeftParamA",
			"LeftParamB",
			"LeftSurface",
			"LeftSurfaceInput",
			"Locked",
			"Material",
			"Orientation",
			"Position",
			"Reflectance",
			"RightParamA",
			"RightParamB",
			"RightSurface",
			"RightSurfaceInput",
			"RotVelocity",
			"Rotation",
			"Shape",
			"Size",
			"TopParamA",
			"TopParamB",
			"TopSurface",
			"TopSurfaceInput",
			"Transparency",
			"Velocity"
		},
		["PartAdornment"] = {
			"Adornee",
			"Color3",
			"Transparency",
			"Visible"
		},
		["PartOperation"] = {
			"Anchored",
			"BackParamA",
			"BackParamB",
			"BackSurface",
			"BackSurfaceInput",
			"BottomParamA",
			"BottomParamB",
			"BottomSurface",
			"BottomSurfaceInput",
			"CFrame",
			"CanCollide",
			"CollisionGroupId",
			"Color",
			"CustomPhysicalProperties",
			"FrontParamA",
			"FrontParamB",
			"FrontSurface",
			"FrontSurfaceInput",
			"LeftParamA",
			"LeftParamB",
			"LeftSurface",
			"LeftSurfaceInput",
			"Locked",
			"Material",
			"Orientation",
			"Position",
			"Reflectance",
			"RightParamA",
			"RightParamB",
			"RightSurface",
			"RightSurfaceInput",
			"RotVelocity",
			"Rotation",
			"Size",
			"TopParamA",
			"TopParamB",
			"TopSurface",
			"TopSurfaceInput",
			"Transparency",
			"UsePartColor",
			"Velocity"
		},
		["PartOperationAsset"] = {},
		["ParticleEmitter"] = {
			"Acceleration",
			"Color",
			"Drag",
			"EmissionDirection",
			"Enabled",
			"Lifetime",
			"LightEmission",
			"LightInfluence",
			"LockedToPart",
			"Rate",
			"RotSpeed",
			"Rotation",
			"Size",
			"Speed",
			"SpreadAngle",
			"Texture",
			"Transparency",
			"VelocityInheritance",
			"ZOffset"
		},
		["Path"] = {},
		["PathfindingService"] = {},
		["PhysicsPacketCache"] = {},
		["PhysicsService"] = {},
		["PhysicsSettings"] = {
			"AllowSleep",
			"AreAnchorsShown",
			"AreAssembliesShown",
			"AreAwakePartsHighlighted",
			"AreBodyTypesShown",
			"AreContactIslandsShown",
			"AreContactPointsShown",
			"AreJointCoordinatesShown",
			"AreMechanismsShown",
			"AreModelCoordsShown",
			"AreOwnersShown",
			"ArePartCoordsShown",
			"AreRegionsShown",
			"AreUnalignedPartsShown",
			"AreWorldCoordsShown",
			"DisableCSGv2",
			"IsReceiveAgeShown",
			"IsTreeShown",
			"PhysicsEnvironmentalThrottle",
			"ShowDecompositionGeometry",
			"ThrottleAdjustTime",
			"UseCSGv2"
		},
		["PitchShiftSoundEffect"] = {
			"Enabled",
			"Octave",
			"Priority"
		},
		["Platform"] = {
			"Anchored",
			"BackParamA",
			"BackParamB",
			"BackSurface",
			"BackSurfaceInput",
			"BottomParamA",
			"BottomParamB",
			"BottomSurface",
			"BottomSurfaceInput",
			"CFrame",
			"CanCollide",
			"CollisionGroupId",
			"Color",
			"CustomPhysicalProperties",
			"FrontParamA",
			"FrontParamB",
			"FrontSurface",
			"FrontSurfaceInput",
			"LeftParamA",
			"LeftParamB",
			"LeftSurface",
			"LeftSurfaceInput",
			"Locked",
			"Material",
			"Orientation",
			"Position",
			"Reflectance",
			"RightParamA",
			"RightParamB",
			"RightSurface",
			"RightSurfaceInput",
			"RotVelocity",
			"Rotation",
			"Shape",
			"Size",
			"TopParamA",
			"TopParamB",
			"TopSurface",
			"TopSurfaceInput",
			"Transparency",
			"Velocity"
		},
		["Player"] = {
			"AutoJumpEnabled",
			"CameraMaxZoomDistance",
			"CameraMinZoomDistance",
			"CameraMode",
			"CanLoadCharacterAppearance",
			"Character",
			"CharacterAppearanceId",
			"DevCameraOcclusionMode",
			"DevComputerCameraMode",
			"DevComputerMovementMode",
			"DevEnableMouseLock",
			"DevTouchCameraMode",
			"DevTouchMovementMode",
			"HealthDisplayDistance",
			"NameDisplayDistance",
			"Neutral",
			"ReplicationFocus",
			"RespawnLocation",
			"Team",
			"TeamColor",
			"UserId"
		},
		["PlayerGui"] = {
			"ScreenOrientation",
			"SelectionImageObject"
		},
		["PlayerMouse"] = {
			"Icon",
			"TargetFilter"
		},
		["PlayerScripts"] = {},
		["Players"] = {
			"CharacterAutoLoads"
		},
		["Plugin"] = {},
		["PluginAction"] = {},
		["PluginGui"] = {
			"AutoLocalize",
			"Enabled",
			"ResetOnSpawn",
			"RootLocalizationTable",
			"Title",
			"ZIndexBehavior"
		},
		["PluginGuiService"] = {},
		["PluginManager"] = {},
		["PluginMouse"] = {
			"Icon",
			"TargetFilter"
		},
		["PointLight"] = {
			"Brightness",
			"Color",
			"Enabled",
			"Range",
			"Shadows"
		},
		["PointsService"] = {},
		["Pose"] = {
			"CFrame",
			"EasingDirection",
			"EasingStyle",
			"Weight"
		},
		["PostEffect"] = {
			"Enabled"
		},
		["PrismaticConstraint"] = {
			"ActuatorType",
			"Attachment0",
			"Attachment1",
			"Color",
			"Enabled",
			"LimitsEnabled",
			"LowerLimit",
			"MotorMaxAcceleration",
			"MotorMaxForce",
			"Restitution",
			"ServoMaxForce",
			"Size",
			"Speed",
			"TargetPosition",
			"UpperLimit",
			"Velocity",
			"Visible"
		},
		["QWidgetPluginGui"] = {
			"AutoLocalize",
			"Enabled",
			"ResetOnSpawn",
			"RootLocalizationTable",
			"Title",
			"ZIndexBehavior"
		},
		["RayValue"] = {
			"Value"
		},
		["ReflectionMetadata"] = {},
		["ReflectionMetadataCallbacks"] = {},
		["ReflectionMetadataClass"] = {
			"Browsable",
			"ClassCategory",
			"Constraint",
			"Deprecated",
			"EditingDisabled",
			"ExplorerImageIndex",
			"ExplorerOrder",
			"Insertable",
			"IsBackend",
			"PreferredParent",
			"PreferredParents",
			"ScriptContext",
			"UIMaximum",
			"UIMinimum",
			"UINumTicks",
			"summary"
		},
		["ReflectionMetadataClasses"] = {},
		["ReflectionMetadataEnum"] = {
			"Browsable",
			"ClassCategory",
			"Constraint",
			"Deprecated",
			"EditingDisabled",
			"IsBackend",
			"ScriptContext",
			"UIMaximum",
			"UIMinimum",
			"UINumTicks",
			"summary"
		},
		["ReflectionMetadataEnumItem"] = {
			"Browsable",
			"ClassCategory",
			"Constraint",
			"Deprecated",
			"EditingDisabled",
			"IsBackend",
			"ScriptContext",
			"UIMaximum",
			"UIMinimum",
			"UINumTicks",
			"summary"
		},
		["ReflectionMetadataEnums"] = {},
		["ReflectionMetadataEvents"] = {},
		["ReflectionMetadataFunctions"] = {},
		["ReflectionMetadataItem"] = {
			"Browsable",
			"ClassCategory",
			"Constraint",
			"Deprecated",
			"EditingDisabled",
			"IsBackend",
			"ScriptContext",
			"UIMaximum",
			"UIMinimum",
			"UINumTicks",
			"summary"
		},
		["ReflectionMetadataMember"] = {
			"Browsable",
			"ClassCategory",
			"Constraint",
			"Deprecated",
			"EditingDisabled",
			"IsBackend",
			"ScriptContext",
			"UIMaximum",
			"UIMinimum",
			"UINumTicks",
			"summary"
		},
		["ReflectionMetadataProperties"] = {},
		["ReflectionMetadataYieldFunctions"] = {},
		["RemoteEvent"] = {},
		["RemoteFunction"] = {},
		["RenderSettings"] = {
			"AutoFRMLevel",
			"EagerBulkExecution",
			"EditQualityLevel",
			"ExportMergeByMaterial",
			"FrameRateManager",
			"GraphicsMode",
			"MeshCacheSize",
			"QualityLevel",
			"ReloadAssets",
			"RenderCSGTrianglesDebug",
			"ShowBoundingBoxes"
		},
		["RenderingTest"] = {
			"CFrame",
			"ComparisonDiffThreshold",
			"ComparisonMethod",
			"ComparisonPsnrThreshold",
			"Description",
			"FieldOfView",
			"Orientation",
			"Position",
			"QualityLevel",
			"ShouldSkip",
			"Ticket"
		},
		["ReplicatedFirst"] = {},
		["ReplicatedStorage"] = {},
		["ReverbSoundEffect"] = {
			"DecayTime",
			"Density",
			"Diffusion",
			"DryLevel",
			"Enabled",
			"Priority",
			"WetLevel"
		},
		["RobloxReplicatedStorage"] = {},
		["RocketPropulsion"] = {
			"CartoonFactor",
			"MaxSpeed",
			"MaxThrust",
			"MaxTorque",
			"Target",
			"TargetOffset",
			"TargetRadius",
			"ThrustD",
			"ThrustP",
			"TurnD",
			"TurnP"
		},
		["RodConstraint"] = {
			"Attachment0",
			"Attachment1",
			"Color",
			"Enabled",
			"Length",
			"Thickness",
			"Visible"
		},
		["RopeConstraint"] = {
			"Attachment0",
			"Attachment1",
			"Color",
			"Enabled",
			"Length",
			"Restitution",
			"Thickness",
			"Visible"
		},
		["Rotate"] = {
			"C0",
			"C1",
			"Part0",
			"Part1"
		},
		["RotateP"] = {
			"BaseAngle",
			"C0",
			"C1",
			"Part0",
			"Part1"
		},
		["RotateV"] = {
			"BaseAngle",
			"C0",
			"C1",
			"Part0",
			"Part1"
		},
		["RunService"] = {},
		["RunningAverageItemDouble"] = {},
		["RunningAverageItemInt"] = {},
		["RunningAverageTimeIntervalItem"] = {},
		["RuntimeScriptService"] = {},
		["ScreenGui"] = {
			"AutoLocalize",
			"DisplayOrder",
			"Enabled",
			"IgnoreGuiInset",
			"ResetOnSpawn",
			"RootLocalizationTable",
			"ZIndexBehavior"
		},
		["Script"] = {
			"Disabled",
			"Enabled",
			"LinkedSource",
		},
		["ScriptContext"] = {},
		["ScriptDebugger"] = {},
		["ScriptService"] = {},
		["ScrollingFrame"] = {
			"Active",
			"AnchorPoint",
			"AutoLocalize",
			"BackgroundColor3",
			"BackgroundTransparency",
			"BorderColor3",
			"BorderSizePixel",
			"BottomImage",
			"CanvasPosition",
			"CanvasSize",
			"ClipsDescendants",
			"ElasticBehavior",
			"HorizontalScrollBarInset",
			"LayoutOrder",
			"MidImage",
			"NextSelectionDown",
			"NextSelectionLeft",
			"NextSelectionRight",
			"NextSelectionUp",
			"Position",
			"RootLocalizationTable",
			"Rotation",
			"ScrollBarImageColor3",
			"ScrollBarImageTransparency",
			"ScrollBarThickness",
			"ScrollingDirection",
			"ScrollingEnabled",
			"Selectable",
			"SelectionImageObject",
			"Size",
			"SizeConstraint",
			"TopImage",
			"VerticalScrollBarInset",
			"VerticalScrollBarPosition",
			"Visible",
			"ZIndex"
		},
		["Seat"] = {
			"Anchored",
			"BackParamA",
			"BackParamB",
			"BackSurface",
			"BackSurfaceInput",
			"BottomParamA",
			"BottomParamB",
			"BottomSurface",
			"BottomSurfaceInput",
			"CFrame",
			"CanCollide",
			"CollisionGroupId",
			"Color",
			"CustomPhysicalProperties",
			"Disabled",
			"FrontParamA",
			"FrontParamB",
			"FrontSurface",
			"FrontSurfaceInput",
			"LeftParamA",
			"LeftParamB",
			"LeftSurface",
			"LeftSurfaceInput",
			"Locked",
			"Material",
			"Orientation",
			"Position",
			"Reflectance",
			"RightParamA",
			"RightParamB",
			"RightSurface",
			"RightSurfaceInput",
			"RotVelocity",
			"Rotation",
			"Shape",
			"Size",
			"TopParamA",
			"TopParamB",
			"TopSurface",
			"TopSurfaceInput",
			"Transparency",
			"Velocity"
		},
		["Selection"] = {},
		["SelectionBox"] = {
			"Adornee",
			"Color3",
			"LineThickness",
			"SurfaceColor3",
			"SurfaceTransparency",
			"Transparency",
			"Visible"
		},
		["SelectionLasso"] = {
			"Color3",
			"Humanoid",
			"Transparency",
			"Visible"
		},
		["SelectionPartLasso"] = {
			"Color3",
			"Humanoid",
			"Part",
			"Transparency",
			"Visible"
		},
		["SelectionPointLasso"] = {
			"Color3",
			"Humanoid",
			"Point",
			"Transparency",
			"Visible"
		},
		["SelectionSphere"] = {
			"Adornee",
			"Color3",
			"SurfaceColor3",
			"SurfaceTransparency",
			"Transparency",
			"Visible"
		},
		["ServerReplicator"] = {},
		["ServerScriptService"] = {},
		["ServerStorage"] = {},
		["ServiceProvider"] = {},
		["Shirt"] = {
			"ShirtTemplate"
		},
		["ShirtGraphic"] = {
			"Graphic"
		},
		["SkateboardController"] = {},
		["SkateboardPlatform"] = {
			"Anchored",
			"BackParamA",
			"BackParamB",
			"BackSurface",
			"BackSurfaceInput",
			"BottomParamA",
			"BottomParamB",
			"BottomSurface",
			"BottomSurfaceInput",
			"CFrame",
			"CanCollide",
			"CollisionGroupId",
			"Color",
			"CustomPhysicalProperties",
			"FrontParamA",
			"FrontParamB",
			"FrontSurface",
			"FrontSurfaceInput",
			"LeftParamA",
			"LeftParamB",
			"LeftSurface",
			"LeftSurfaceInput",
			"Locked",
			"Material",
			"Orientation",
			"Position",
			"Reflectance",
			"RightParamA",
			"RightParamB",
			"RightSurface",
			"RightSurfaceInput",
			"RotVelocity",
			"Rotation",
			"Shape",
			"Size",
			"Steer",
			"StickyWheels",
			"Throttle",
			"TopParamA",
			"TopParamB",
			"TopSurface",
			"TopSurfaceInput",
			"Transparency",
			"Velocity"
		},
		["Skin"] = {
			"SkinColor"
		},
		["Sky"] = {
			"CelestialBodiesShown",
			"MoonAngularSize",
			"MoonTextureId",
			"SkyboxBk",
			"SkyboxDn",
			"SkyboxFt",
			"SkyboxLf",
			"SkyboxRt",
			"SkyboxUp",
			"StarCount",
			"SunAngularSize",
			"SunTextureId"
		},
		["SlidingBallConstraint"] = {
			"ActuatorType",
			"Attachment0",
			"Attachment1",
			"Color",
			"Enabled",
			"LimitsEnabled",
			"LowerLimit",
			"MotorMaxAcceleration",
			"MotorMaxForce",
			"Restitution",
			"ServoMaxForce",
			"Size",
			"Speed",
			"TargetPosition",
			"UpperLimit",
			"Velocity",
			"Visible"
		},
		["Smoke"] = {
			"Color",
			"Enabled",
			"Opacity",
			"RiseVelocity",
			"Size"
		},
		["Snap"] = {
			"C0",
			"C1",
			"Part0",
			"Part1"
		},
		["SolidModelContentProvider"] = {},
		["Sound"] = {
			"EmitterSize",
			"Looped",
			"MaxDistance",
			"PlayOnRemove",
			"PlaybackSpeed",
			"Playing",
			"RollOffMode",
			"SoundGroup",
			"SoundId",
			"TimePosition",
			"Volume"
		},
		["SoundEffect"] = {
			"Enabled",
			"Priority"
		},
		["SoundGroup"] = {
			"Volume"
		},
		["SoundService"] = {
			"AmbientReverb",
			"DistanceFactor",
			"DopplerScale",
			"RespectFilteringEnabled",
			"RolloffScale"
		},
		["Sparkles"] = {
			"Enabled",
			"SparkleColor"
		},
		["SpawnLocation"] = {
			"AllowTeamChangeOnTouch",
			"Anchored",
			"BackParamA",
			"BackParamB",
			"BackSurface",
			"BackSurfaceInput",
			"BottomParamA",
			"BottomParamB",
			"BottomSurface",
			"BottomSurfaceInput",
			"CFrame",
			"CanCollide",
			"CollisionGroupId",
			"Color",
			"CustomPhysicalProperties",
			"Duration",
			"Enabled",
			"FrontParamA",
			"FrontParamB",
			"FrontSurface",
			"FrontSurfaceInput",
			"LeftParamA",
			"LeftParamB",
			"LeftSurface",
			"LeftSurfaceInput",
			"Locked",
			"Material",
			"Neutral",
			"Orientation",
			"Position",
			"Reflectance",
			"RightParamA",
			"RightParamB",
			"RightSurface",
			"RightSurfaceInput",
			"RotVelocity",
			"Rotation",
			"Shape",
			"Size",
			"TeamColor",
			"TopParamA",
			"TopParamB",
			"TopSurface",
			"TopSurfaceInput",
			"Transparency",
			"Velocity"
		},
		["SpawnerService"] = {},
		["SpecialMesh"] = {
			"MeshId",
			"MeshType",
			"Offset",
			"Scale",
			"TextureId",
			"VertexColor"
		},
		["SphereHandleAdornment"] = {
			"Adornee",
			"AlwaysOnTop",
			"CFrame",
			"Color3",
			"Radius",
			"SizeRelativeOffset",
			"Transparency",
			"Visible",
			"ZIndex"
		},
		["SpotLight"] = {
			"Angle",
			"Brightness",
			"Color",
			"Enabled",
			"Face",
			"Range",
			"Shadows"
		},
		["SpringConstraint"] = {
			"Attachment0",
			"Attachment1",
			"Coils",
			"Color",
			"Damping",
			"Enabled",
			"FreeLength",
			"LimitsEnabled",
			"MaxForce",
			"MaxLength",
			"MinLength",
			"Radius",
			"Stiffness",
			"Thickness",
			"Visible"
		},
		["StandardPages"] = {},
		["StarterCharacterScripts"] = {},
		["StarterGear"] = {},
		["StarterGui"] = {
			"ScreenOrientation",
			"ShowDevelopmentGui"
		},
		["StarterPack"] = {},
		["StarterPlayer"] = {
			"AutoJumpEnabled",
			"CameraMaxZoomDistance",
			"CameraMinZoomDistance",
			"CameraMode",
			"DevCameraOcclusionMode",
			"DevComputerCameraMovementMode",
			"DevComputerMovementMode",
			"DevTouchCameraMovementMode",
			"DevTouchMovementMode",
			"EnableMouseLockOption",
			"HealthDisplayDistance",
			"LoadCharacterAppearance",
			"NameDisplayDistance"
		},
		["StarterPlayerScripts"] = {},
		["Stats"] = {},
		["StatsItem"] = {},
		["Status"] = {
			"PrimaryPart"
		},
		["StringValue"] = {
			"Value"
		},
		["SunRaysEffect"] = {
			"Enabled",
			"Intensity",
			"Spread"
		},
		["SurfaceGui"] = {
			"Active",
			"Adornee",
			"AlwaysOnTop",
			"AutoLocalize",
			"CanvasSize",
			"ClipsDescendants",
			"Enabled",
			"Face",
			"LightInfluence",
			"ResetOnSpawn",
			"RootLocalizationTable",
			"ToolPunchThroughDistance",
			"ZIndexBehavior",
			"ZOffset"
		},
		["SurfaceLight"] = {
			"Angle",
			"Brightness",
			"Color",
			"Enabled",
			"Face",
			"Range",
			"Shadows"
		},
		["SurfaceSelection"] = {
			"Adornee",
			"Color3",
			"TargetSurface",
			"Transparency",
			"Visible"
		},
		["TaskScheduler"] = {
			"ThreadPoolConfig"
		},
		["Team"] = {
			"AutoAssignable",
			"TeamColor"
		},
		["Teams"] = {},
		["TeleportService"] = {},
		["Terrain"] = {
			"Anchored",
			"BackParamA",
			"BackParamB",
			"BackSurface",
			"BackSurfaceInput",
			"BottomParamA",
			"BottomParamB",
			"BottomSurface",
			"BottomSurfaceInput",
			"CFrame",
			"CanCollide",
			"CollisionGroupId",
			"Color",
			"CustomPhysicalProperties",
			"FrontParamA",
			"FrontParamB",
			"FrontSurface",
			"FrontSurfaceInput",
			"LeftParamA",
			"LeftParamB",
			"LeftSurface",
			"LeftSurfaceInput",
			"Locked",
			"Material",
			"Orientation",
			"Position",
			"Reflectance",
			"RightParamA",
			"RightParamB",
			"RightSurface",
			"RightSurfaceInput",
			"RotVelocity",
			"Rotation",
			"Size",
			"TopParamA",
			"TopParamB",
			"TopSurface",
			"TopSurfaceInput",
			"Transparency",
			"Velocity",
			"WaterColor",
			"WaterReflectance",
			"WaterTransparency",
			"WaterWaveSize",
			"WaterWaveSpeed"
		},
		["TerrainRegion"] = {},
		["TestService"] = {
			"AutoRuns",
			"Description",
			"ExecuteWithStudioRun",
			"Is30FpsThrottleEnabled",
			"IsPhysicsEnvironmentalThrottled",
			"IsSleepAllowed",
			"NumberOfPlayers",
			"SimulateSecondsLag",
			"Timeout"
		},
		["TextBox"] = {
			"Active",
			"AnchorPoint",
			"AutoLocalize",
			"BackgroundColor3",
			"BackgroundTransparency",
			"BorderColor3",
			"BorderSizePixel",
			"ClearTextOnFocus",
			"ClipsDescendants",
			"Font",
			"LayoutOrder",
			"LineHeight",
			"MultiLine",
			"NextSelectionDown",
			"NextSelectionLeft",
			"NextSelectionRight",
			"NextSelectionUp",
			"PlaceholderColor3",
			"PlaceholderText",
			"Position",
			"RootLocalizationTable",
			"Rotation",
			"Selectable",
			"SelectionImageObject",
			"ShowNativeInput",
			"Size",
			"SizeConstraint",
			"Text",
			"TextColor3",
			"TextScaled",
			"TextSize",
			"TextStrokeColor3",
			"TextStrokeTransparency",
			"TextTransparency",
			"TextTruncate",
			"TextWrapped",
			"TextXAlignment",
			"TextYAlignment",
			"Visible",
			"ZIndex"
		},
		["TextButton"] = {
			"Active",
			"AnchorPoint",
			"AutoButtonColor",
			"AutoLocalize",
			"BackgroundColor3",
			"BackgroundTransparency",
			"BorderColor3",
			"BorderSizePixel",
			"ClipsDescendants",
			"Font",
			"LayoutOrder",
			"LineHeight",
			"Modal",
			"NextSelectionDown",
			"NextSelectionLeft",
			"NextSelectionRight",
			"NextSelectionUp",
			"Position",
			"RootLocalizationTable",
			"Rotation",
			"Selectable",
			"Selected",
			"SelectionImageObject",
			"Size",
			"SizeConstraint",
			"Style",
			"Text",
			"TextColor3",
			"TextScaled",
			"TextSize",
			"TextStrokeColor3",
			"TextStrokeTransparency",
			"TextTransparency",
			"TextTruncate",
			"TextWrapped",
			"TextXAlignment",
			"TextYAlignment",
			"Visible",
			"ZIndex"
		},
		["TextFilterResult"] = {},
		["TextLabel"] = {
			"Active",
			"AnchorPoint",
			"AutoLocalize",
			"BackgroundColor3",
			"BackgroundTransparency",
			"BorderColor3",
			"BorderSizePixel",
			"ClipsDescendants",
			"Font",
			"LayoutOrder",
			"LineHeight",
			"NextSelectionDown",
			"NextSelectionLeft",
			"NextSelectionRight",
			"NextSelectionUp",
			"Position",
			"RootLocalizationTable",
			"Rotation",
			"Selectable",
			"SelectionImageObject",
			"Size",
			"SizeConstraint",
			"Text",
			"TextColor3",
			"TextScaled",
			"TextSize",
			"TextStrokeColor3",
			"TextStrokeTransparency",
			"TextTransparency",
			"TextTruncate",
			"TextWrapped",
			"TextXAlignment",
			"TextYAlignment",
			"Visible",
			"ZIndex"
		},
		["TextService"] = {},
		["Texture"] = {
			"Color3",
			"Face",
			"StudsPerTileU",
			"StudsPerTileV",
			"Texture",
			"Transparency"
		},
		["ThirdPartyUserService"] = {},
		["TimerService"] = {},
		["Tool"] = {
			"CanBeDropped",
			"Enabled",
			"Grip",
			"GripForward",
			"GripPos",
			"GripRight",
			"GripUp",
			"ManualActivationOnly",
			"RequiresHandle",
			"TextureId",
			"ToolTip"
		},
		["Toolbar"] = {},
		["Torque"] = {
			"Attachment0",
			"Attachment1",
			"Color",
			"Enabled",
			"RelativeTo",
			"Torque",
			"Visible"
		},
		["TotalCountTimeIntervalItem"] = {},
		["TouchInputService"] = {},
		["TouchTransmitter"] = {},
		["Trail"] = {
			"Attachment0",
			"Attachment1",
			"Color",
			"Enabled",
			"FaceCamera",
			"Lifetime",
			"LightEmission",
			"LightInfluence",
			"MaxLength",
			"MinLength",
			"Texture",
			"TextureLength",
			"TextureMode",
			"Transparency",
			"WidthScale"
		},
		["Translator"] = {},
		["TremoloSoundEffect"] = {
			"Depth",
			"Duty",
			"Enabled",
			"Frequency",
			"Priority"
		},
		["TrussPart"] = {
			"Anchored",
			"BackParamA",
			"BackParamB",
			"BackSurface",
			"BackSurfaceInput",
			"BottomParamA",
			"BottomParamB",
			"BottomSurface",
			"BottomSurfaceInput",
			"CanCollide",
			"CollisionGroupId",
			"Color",
			"CustomPhysicalProperties",
			"FrontParamA",
			"FrontParamB",
			"FrontSurface",
			"FrontSurfaceInput",
			"LeftParamA",
			"LeftParamB",
			"LeftSurface",
			"LeftSurfaceInput",
			"Locked",
			"Material",
			"Orientation",
			"Position",
			"Reflectance",
			"RightParamA",
			"RightParamB",
			"RightSurface",
			"RightSurfaceInput",
			"RotVelocity",
			"Rotation",
			"Size",
			"Style",
			"TopParamA",
			"TopParamB",
			"TopSurface",
			"TopSurfaceInput",
			"Transparency",
			"Velocity"
		},
		["Tween"] = {},
		["TweenBase"] = {},
		["TweenService"] = {},
		["UIAspectRatioConstraint"] = {
			"AspectRatio",
			"AspectType",
			"DominantAxis"
		},
		["UIBase"] = {},
		["UIComponent"] = {},
		["UIConstraint"] = {},
		["UIGridLayout"] = {
			"CellPadding",
			"CellSize",
			"FillDirection",
			"FillDirectionMaxCells",
			"HorizontalAlignment",
			"SortOrder",
			"StartCorner",
			"VerticalAlignment"
		},
		["UIGridStyleLayout"] = {
			"FillDirection",
			"HorizontalAlignment",
			"SortOrder",
			"VerticalAlignment"
		},
		["UILayout"] = {},
		["UIListLayout"] = {
			"FillDirection",
			"HorizontalAlignment",
			"Padding",
			"SortOrder",
			"VerticalAlignment"
		},
		["UIPadding"] = {
			"PaddingBottom",
			"PaddingLeft",
			"PaddingRight",
			"PaddingTop"
		},
		["UIPageLayout"] = {
			"Animated",
			"Circular",
			"EasingDirection",
			"EasingStyle",
			"FillDirection",
			"GamepadInputEnabled",
			"HorizontalAlignment",
			"Padding",
			"ScrollWheelInputEnabled",
			"SortOrder",
			"TouchInputEnabled",
			"TweenTime",
			"VerticalAlignment"
		},
		["UIScale"] = {
			"Scale"
		},
		["UISizeConstraint"] = {
			"MaxSize",
			"MinSize"
		},
		["UITableLayout"] = {
			"FillDirection",
			"FillEmptySpaceColumns",
			"FillEmptySpaceRows",
			"HorizontalAlignment",
			"MajorAxis",
			"Padding",
			"SortOrder",
			"VerticalAlignment"
		},
		["UITextSizeConstraint"] = {
			"MaxTextSize",
			"MinTextSize"
		},
		["UnionOperation"] = {
			"Anchored",
			"BackParamA",
			"BackParamB",
			"BackSurface",
			"BackSurfaceInput",
			"BottomParamA",
			"BottomParamB",
			"BottomSurface",
			"BottomSurfaceInput",
			"CFrame",
			"CanCollide",
			"CollisionGroupId",
			"Color",
			"CustomPhysicalProperties",
			"FrontParamA",
			"FrontParamB",
			"FrontSurface",
			"FrontSurfaceInput",
			"LeftParamA",
			"LeftParamB",
			"LeftSurface",
			"LeftSurfaceInput",
			"Locked",
			"Material",
			"Orientation",
			"Position",
			"Reflectance",
			"RightParamA",
			"RightParamB",
			"RightSurface",
			"RightSurfaceInput",
			"RotVelocity",
			"Rotation",
			"Size",
			"TopParamA",
			"TopParamB",
			"TopSurface",
			"TopSurfaceInput",
			"Transparency",
			"UsePartColor",
			"Velocity"
		},
		["UserGameSettings"] = {
			"ComputerCameraMovementMode",
			"ComputerMovementMode",
			"ControlMode",
			"GamepadCameraSensitivity",
			"MasterVolume",
			"MouseSensitivity",
			"RotationType",
			"SavedQualityLevel",
			"TouchCameraMovementMode",
			"TouchMovementMode"
		},
		["UserInputService"] = {
			"ModalEnabled",
			"MouseBehavior",
			"MouseDeltaSensitivity",
			"MouseIconEnabled"
		},
		["UserSettings"] = {},
		["VRService"] = {
			"GuiInputUserCFrame"
		},
		["ValueBase"] = {},
		["Vector3Value"] = {
			"Value"
		},
		["VectorForce"] = {
			"ApplyAtCenterOfMass",
			"Attachment0",
			"Attachment1",
			"Color",
			"Enabled",
			"Force",
			"RelativeTo",
			"Visible"
		},
		["VehicleController"] = {},
		["VehicleSeat"] = {
			"Anchored",
			"BackParamA",
			"BackParamB",
			"BackSurface",
			"BackSurfaceInput",
			"BottomParamA",
			"BottomParamB",
			"BottomSurface",
			"BottomSurfaceInput",
			"CFrame",
			"CanCollide",
			"CollisionGroupId",
			"Color",
			"CustomPhysicalProperties",
			"Disabled",
			"FrontParamA",
			"FrontParamB",
			"FrontSurface",
			"FrontSurfaceInput",
			"HeadsUpDisplay",
			"LeftParamA",
			"LeftParamB",
			"LeftSurface",
			"LeftSurfaceInput",
			"Locked",
			"Material",
			"MaxSpeed",
			"Orientation",
			"Position",
			"Reflectance",
			"RightParamA",
			"RightParamB",
			"RightSurface",
			"RightSurfaceInput",
			"RotVelocity",
			"Rotation",
			"Size",
			"Steer",
			"SteerFloat",
			"Throttle",
			"ThrottleFloat",
			"TopParamA",
			"TopParamB",
			"TopSurface",
			"TopSurfaceInput",
			"Torque",
			"Transparency",
			"TurnSpeed",
			"Velocity"
		},
		["VelocityMotor"] = {
			"C0",
			"C1",
			"CurrentAngle",
			"DesiredAngle",
			"Hole",
			"MaxVelocity",
			"Part0",
			"Part1"
		},
		["VirtualInputManager"] = {},
		["VirtualUser"] = {},
		["Visit"] = {},
		["WedgePart"] = {
			"Anchored",
			"BackParamA",
			"BackParamB",
			"BackSurface",
			"BackSurfaceInput",
			"BottomParamA",
			"BottomParamB",
			"BottomSurface",
			"BottomSurfaceInput",
			"CanCollide",
			"CollisionGroupId",
			"Color",
			"CustomPhysicalProperties",
			"FrontParamA",
			"FrontParamB",
			"FrontSurface",
			"FrontSurfaceInput",
			"LeftParamA",
			"LeftParamB",
			"LeftSurface",
			"LeftSurfaceInput",
			"Locked",
			"Material",
			"Orientation",
			"Position",
			"Reflectance",
			"RightParamA",
			"RightParamB",
			"RightSurface",
			"RightSurfaceInput",
			"RotVelocity",
			"Rotation",
			"Size",
			"TopParamA",
			"TopParamB",
			"TopSurface",
			"TopSurfaceInput",
			"Transparency",
			"Velocity"
		},
		["Weld"] = {
			"C0",
			"C1",
			"Part0",
			"Part1"
		},
		["WeldConstraint"] = {
			"Enabled",
			"Part0",
			"Part1"
		},
		["Workspace"] = {
			"AllowThirdPartySales",
			"CurrentCamera",
			"DistributedGameTime",
			"Gravity",
			"PrimaryPart",
			"StreamingEnabled",
			"TemporaryLegacyPhysicsSolverOverride"
		},
		["UIGradient"] = {
			"Color",
			"Enabled",
			"Offset",
			"Rotation",
			"Transparency",
		},
		["UICorner"] = {
			"CornerRadius",
		},
		["UIStroke"] = {
			"ApplyStrokeMode",
			"Color",
			"LineJoinMode",
			"Thickness",
			"Transparency",
			"Enabled"
		}
	}
	local inf = tonumber("inf")
	local function n(x)
		if x == inf then
			x = 999_999_999
		end
		return math.floor(x*10000)/10000
	end
	Module.__Instance.datas.serializedObjects = {
		["nil"] = {
			a = function()
				return
			end,
			b = function()
				return
			end,
		},
		["UDim2"] = {
			a = function(v)
				return {n(v.X.Scale),n(v.X.Offset),n(v.Y.Scale),n(v.Y.Offset)}
			end,
			b = function(v)
				return UDim2.new(v[1],v[2],v[3],v[4])
			end,
		},
		["Rect"] = {
			a = function(v)
				return {
					n(v.Width),
					{n(v.Max.X),n(v.Max.Y)},
					{n(v.Min.X),n(v.Min.Y)},
					n(v.Height)
				}
			end,
			b = function(...)
				local d = ...
				return Rect.new(d[1],d[2],d[3],d[4])
			end,
		},
		["UDim"] = {
			a = function(v)
				return {n(v.Scale),n(v.Offset)}
			end,
			b = function(...)
				local d = ...
				return UDim.new(d[1],d[2])
			end,
		},
		["Color3"] = {
			a = function(v)
				return {n(v.R),n(v.G),n(v.B)}
			end,
			b = function(t)
				return Color3.new(
					t[1],
					t[2],
					t[3]
				)
			end,
		},
		["Vector2"] = {
			a = function(v)
				return {n(v.X),n(v.Y)}
			end,
			b = function(...)
				local d = ...
				return Vector2.new(d[1],d[2])
			end,
		},
		["EnumItem"] = {
			a = function(v)
				return v.Value
			end,
			b = function(v)
				return v
			end
		},
		["NumberRange"] = {
			a = function(vv)	
				return {n(vv.Min),n(vv.Max)}
			end,
			b = function(v)
				return NumberRange.new(v[1],v[2])
			end
		},
		["NumberSequence"] = {
			a = function(vv)
				local e = {}
				for _,i in vv.Keypoints do
					e[#e+1] = {
						n(i.Time),
						n(i.Value)
					}
				end
				return e
			end,
			b = function(v)
				local keyPoints = {}
				for _,i in v do
					keyPoints[#keyPoints+1] = NumberSequenceKeypoint.new(i[1],i[2])
				end
				return NumberSequence.new(keyPoints)
			end
		},
		["ColorSequence"] = {
			a = function(vv)
				local e = {}
				for _,i in vv.Keypoints do
					local v = i.Value
					e[#e+1] = {
						n(i.Time),
						{n(v.R),n(v.G),n(v.B)}
					}
				end
				return e
			end,
			b = function(v)
				local keyPoints = {}
				for _,i in v do
					keyPoints[#keyPoints+1] = ColorSequenceKeypoint.new(i[1],Color3.new(i[2][1],i[2][2],i[2][3]))
				end
				return ColorSequence.new(keyPoints)
			end
		},
		["BrickColor"] = {
			a = function(vv)
				return vv.Name
			end,
			b = function(v)
				return BrickColor.new(v)
			end
		},
		["Vector3"] = {
			a = function(vv)
				return {n(vv.X),n(vv.Y),n(vv.Z)}
			end,
			b = function(v)
				return Vector3.new(
					v[1],
					v[2],
					v[3]
				)
			end
		},
		["CFrame"] = {
			a = function(vv)
				local o = {}
				for _,i in {vv:GetComponents()} do
					o[#o+1] = n(i)
				end
				return o
			end,
			b = function(v)
				local t = {}
				for _,i in v do
					t[#t+1] = i
				end
				return CFrame.new(table.unpack(t))
			end
		},
		["number"] = {
			a = function(v)
				return n(v)
			end,
			b = function(v)
				return v
			end,
		},
		["string"] = {
			a = function(v)
				return v:gsub("<","`<`"):gsub(">","`>`")
			end,
			b = function(v)
				return v:gsub("`<`","<"):gsub("`>`",">")
			end,
		},
		["boolean"] = {
			a = function(v)
				return if v then 1 else 0
			end,
			b = function(v)
				return if v==1 then true else false
			end,
		},
	}
end

do
	local id = 0
	local id2 = 0
	for v1,i in Module.__Instance.datas.properties do
		for v2,i2 in i do
			Module.__Instance.datas.properties[v1][v2] = {i2,Module.__Instance.createUniqueId(id)} id+=1
		end
		Module.__Instance.datas.classNameId[v1]=Module.__Instance.createUniqueId(id2)
		id2+=1
	end
end
function Module:Serialize(ins:Model? | Instance? | Folder?,returnScriptsFolder:boolean): string | Folder?
	local lastMs = os.clock()+0.1
	local function yield()
		if os.clock() > lastMs then
			lastMs = os.clock()+0.1
			task.wait()
		end
	end
	local scriptsFolder = Instance.new("Folder")
	local base = {data={},nc=1,names={},objects={},queue={},queuec=1,queueF={},unionId = 0}
	function base.e(parent,instance,extra)
		yield()
		local className = instance.ClassName
		local classId = ""
		_,classId = pcall(function()
			return self.__Instance.datas.classNameId[className]
		end)
		if not self.__Instance.datas.properties[className] then
			if self.__Instance.configuration.ignoreMissingObject then return end
			warn("Unknown instance: "..className)
			className = "Unknown"
		end
		local w,ref = pcall(function() return Instance.new(className) end)
		if not w then
			return
		end
		local myId = #base.data+1
		base.objects[instance]=myId	
		local name = base.names[instance.Name]
		if not name then
			local unq = self.__Instance.createUniqueId(base.nc)
			base.names[instance.Name] = unq
			name = unq
			base.nc+=1
		end
		local pp = {["c-"]=classId,["p-"]=parent,["n-"]=name:gsub("<","`<`"):gsub(">","`>`")}
		if extra then
			for v,i in extra do
				pp[v]=i
			end
		end
		do
			local attri = instance:GetAttributes()
			local attricount = 0
			for i, v in attri do
				attricount = attricount + 1
			end
			for k,i in attri do
				attri[k:gsub("<","`<`"):gsub(">","`>`")]=if type(i) == "string" then i:gsub("<","`<`"):gsub(">","`>`") else i
			end
			if attricount > 0 then
				pp["a-"] = attri
			end
		end
		repeat
			local ipos
			for pp,i in base.queue do
				if i == instance then
					ipos = pp
					break
				end
			end
			if ipos then
				local p = base.queue[ipos]base.queue[ipos] = nil
				base.queueF[ipos]=base.objects[p]
			else
				break
			end
		until false
		local k = false
		for _,i in self.__Instance.datas.properties[className] do
			k = true
			if ref[i[1]] == instance[i[1]] then
				continue
			end
			local c = self.__Instance.datas.serializedObjects[typeof(instance[i[1]])]
			local target = instance[i[1]]
			if typeof(target) == "Instance" and target then
				if base.objects[target] then
					pp[i[2]] = "obj#"..base.objects[target]
				else
					pp[i[2]] = "mbj#"..base.queuec
					base.queue[base.queuec] = target
					base.queuec+=1
				end
				continue
			end
			local set
			if not c then
				if not self.__Instance.configuration.ignoreMissingObject then
					warn("Unknown object: "..typeof(target))
				end
				pp["Value"] = className
			else
				if c == 1 then
					set = target
				else
					set = c.a(target)
				end
				pp[i[2]] = set
			end
		end
		if (not k) and (not self.__Instance.configuration.ignoreMissingObject) then
			warn("Missing properties",className)
		end
		base.data[myId] = pp
		local union
		local extras = {}
		if instance:IsA("UnionOperation") and self.__Instance.configuration.isPlugin then
			union = Instance.new("Folder")
			union.Name = "unions"
			local stuffs = self.__Instance.plugin:Separate({instance:Clone()})
			for _,i in stuffs do
				i.Anchored = true
				if i:IsA("NegateOperation") then
					i = self.__Instance.plugin:Negate({i})[1]
					i:SetAttribute("invert",true)
				end
				i.Parent = union
			end
			extras = {
				["p-"] = myId,
				["u-"] = base.unionId,
				["x-"] = {
					instance.RenderFidelity.Value,
					instance.CollisionFidelity.Value,
					instance.UsePartColor
				},
			}
			base.unionId+=1
			union.Parent = instance
		end
		ref:Destroy()
		for _,i in instance:GetChildren() do
			if union == i then
				base.e(myId,i,extras)
			else
				base.e(myId,i)
			end
		end
		if union then
			union:Destroy()
		end
	end
	if type(ins) == "table" then
		local model = Instance.new("Model")
		model.Name = "Model"
		base.e(0,model)
		for _,i3 in ins do
			base.e(1,i3)
		end
		model:Destroy()
	else
		base.e(0,ins)
	end
	do local r = {} for v,i in base.names do r[i] = v end base.names = r end
	for p1,i2 in base.data do
		for p2,i in i2 do
			if type(i) == "string" and i:sub(0,4) == "mbj#" then
				local n = tonumber(i:sub(5,#i))
				if base.queueF[n] then
					base.data[p1][p2] = "obj#"..base.queueF[n]
				end
			end
		end
	end
	local json = self.__Instance.HttpService:JSONEncode({base.data,base.names}) base = nil
	local delete = true
	for _,i in scriptsFolder:GetChildren() do
		if i:IsA("BaseScript") then delete = false i.Enabled = false end
		i:ClearAllChildren()
	end
	if delete then
		scriptsFolder:Destroy()
		scriptsFolder = nil
	else
		scriptsFolder.Name = "__SCRIPTS"
	end
	json = json:gsub("\":\"",">>"):gsub("\",\"","<<"):gsub("},{","<>")
	local ins = self.__Instance
	local output
	if  self.__Instance.configuration.useBase93Encoding then
		output = require(compressor).Zlib.Compress(json)
	else
		output = ins.compression.Compress(json)
	end
	return output,if returnScriptsFolder then scriptsFolder else nil
end
local function checkIfNew(input)
	for i=1,#input do
		local bit = string.byte(input:sub(i,i))
		if not (bit >= 32 and bit <= 127) then
			return true
		end
	end
	return false
end
function Module:Unserialize(maindata:string,scriptsFolder:Folder): Instance
	local lastMs = os.clock()+0.1
	local function yield()
		if os.clock() > lastMs then
			lastMs = os.clock()+0.1
			task.wait()
		end
	end
	local ins = self.__Instance
	if checkIfNew(maindata:sub(0,1000)) then
		maindata = require(compressor).Zlib.Decompress(maindata)
	else
		maindata= ins.compression.Decompress(maindata)
	end
	maindata = maindata:gsub(">>","\":\""):gsub("<<","\",\""):gsub("<>","},{")
	maindata = ins.HttpService:JSONDecode(maindata)
	local toReturn,base=nil,{};base.hasScriptsFolder = scriptsFolder ~= nil;base.data,base.connectInstance,base.names,base.objects,base.cache=maindata[1],{},maindata[2],{[0]=Instance.new("Folder")},{}
	base.unions = {}
	local function getObjectTypeById(id)
		local blacklists = {["p-"]=1,["c-"]=1,["n-"]=1,["a-"]=1,["u-"]=1,["x-"]=1}
		if not(blacklists[id]) and id then
			local q = base.cache[id]
			if q then return q end
			for _,og in ins.datas.properties do
				for _,i in og do
					if i[2] == id then
						base.cache[i[2]]=i[1]
						return i[1]
					end
				end
			end
		end
	end
	xpcall(function()
		for iid,i in base.data do
			yield()
			local parent = base.objects[i["p-"]]
			local w,new
			local function newI()
				local className
				local toFind = i["c-"]
				for v,i in ins.datas.classNameId do
					if i == toFind then
						className = v
					end
				end
				local negateAfter = false
				if className == "UnionOperation" then
					className = "Part"
				end
				w,new = pcall(function() return Instance.new((className == "Unknown" and "StringValue") or className) end)
			end
			newI()
			if not w then continue end
			new.Name = base.names[i["n-"]]:gsub("`<`","<"):gsub("`>`",">") or new.Name
			for v,p in i do
				yield()
				local objectName = getObjectTypeById(v)
				if not pcall(function()
						return new[objectName]
					end)
				then continue end
				if not objectName then continue end
				if type(p)=="string" and p:sub(0,4)=="obj#" then
					local dat = p:sub(5,#p)
					base.connectInstance[#base.connectInstance+1] = {tonumber(dat),new,objectName}
					continue
				end
				local objR = ins.datas.serializedObjects[typeof(new[objectName])]
				if objR then
					if objR == 1 then
						new[objectName] = p
					else
						new[objectName] = objR.b(p)
					end
				else
					warn("Missing object: "..typeof(new[objectName]))
				end
			end
			if i["a-"] then
				for n,v in i["a-"] do
					new:SetAttribute(n:gsub("`<`","<"):gsub("`>`",">"),if type(v) == "string" then v:gsub("`<`","<"):gsub("`>`",">") else v)
				end
			end
			if i["u-"] then
				base.unions[i["u-"]] = {parent,new,i["p-"],i["x-"]}
			end
			new.Parent = parent
			base.objects[iid] = new
		end

		local basePartProperties = {
			"Name",
			"Anchored",
			"BackParamA",
			"BackParamB",
			"BackSurface",
			"BackSurfaceInput",
			"BottomParamA",
			"BottomParamB",
			"BottomSurface",
			"BottomSurfaceInput",
			"CanCollide",
			"CollisionGroupId",
			"Color",
			"CustomPhysicalProperties",
			"FrontParamA",
			"FrontParamB",
			"FrontSurface",
			"FrontSurfaceInput",
			"LeftParamA",
			"LeftParamB",
			"LeftSurface",
			"LeftSurfaceInput",
			"Locked",
			"Material",
			"Orientation",
			"Position",
			"Reflectance",
			"RightParamA",
			"RightParamB",
			"RightSurface",
			"RightSurfaceInput",
			"RotVelocity",
			"Rotation",
			"Size",
			"TopParamA",
			"TopParamB",
			"TopSurface",
			"TopSurfaceInput",
			"Transparency",
			"Velocity",
			"Parent"
		}
		local function array_reverse(x)
			local n, m = #x, #x/2
			for i=1, m do
				x[i], x[n-i+1] = x[n-i+1], x[i]
			end
			return x
		end
		for _,i in array_reverse(base.unions) do
			local createds = {}
			xpcall(function()
				local primaryPart:BasePart = i[1]
				local attri = primaryPart:GetAttributes()
				local priPartProperties = {}
				for _,i in basePartProperties do
					priPartProperties[i]=primaryPart[i]
				end
				primaryPart.Anchored = true
				primaryPart.Size = Vector3.new(0,0,0)
				primaryPart.Parent = workspace;createds[#createds+1]=primaryPart
				local parts = i[2]:GetChildren()
				local pparts = {}
				local negateParts = {}
				for _,i2 in parts do
					if i2:GetAttribute("invert") then
						i2.Anchored = true
						i2.Parent = workspace
						i2.Size += Vector3.new(0.01,0.01,0.01)
						createds[#createds+1]=i2
						negateParts[#negateParts+1] = i2
					elseif i2:IsA("BasePart") then
						i2.Anchored = true
						i2.Parent = workspace
						createds[#createds+1]=i2
						pparts[#pparts+1] = i2
					end
				end
				local new:UnionOperation = primaryPart:UnionAsync(pparts,i[4][2],i[4][1])primaryPart:Destroy()
				for _,i2 in pparts do i2:Destroy() end
				if #negateParts>0 then
					local new2 = new:Clone();new:Destroy()
					new2.Parent = workspace
					new = new2:SubtractAsync(negateParts,i[4][2],i[4][1])new2:Destroy()
					for _,i2 in negateParts do i2:Destroy() end
				end
				i[2]:Destroy()
				for v,i in priPartProperties do
					new[v]=i
				end
				for n,v in attri do
					new:SetAttribute(n,v)
				end
				new.UsePartColor = i[4][3]
				base.objects[i[3]] = new
			end,function(msg)
				warn(msg)
				for _,i in createds do
					i:Destroy()
				end
			end)
		end
		for _,i in base.connectInstance do local target = base.objects[i[1]]
			yield()
			if target then
				--print(i)
				i[2][i[3]] = target
			end
		end
		toReturn = base.objects[1]
		toReturn.Parent = nil
	end,function(msg)
		warn(msg)
	end)
	base.objects[0]:Destroy()
	base=nil
	if scriptsFolder then
		scriptsFolder:Destroy()
	end
	return toReturn
end

getgenv().Serialize = Module
return Module
