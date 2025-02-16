--##########################################
--# Daymare 1994 Sandcastle Vr Fix - CJ117 #
--##########################################

local api = uevr.api
local params = uevr.params
local callbacks = params.sdk.callbacks
local JustCentered = false
local Mactive = false
local Lactive = false
local Playing = false
local is_interacting = false
local in_cutscene = false
local is_playing = false
local is_anim_cam = false
local Fpmesh = nil
local SG_Shake = nil
local Handsmesh = nil
local Intro_doc = false
local is_traversing = nil
local recap_inst = nil
local is_glas_cut = false
local Cur_Weap = nil
local MP5 = nil
local Shotgun = nil
local Active_Weap = "None"
local state = nil
local is_inventory = false
local is_examine = nil
local is_S_inventory = false
local is_climbing = false
local weap_sel = false
local weap_aim = false
local is_aiming = false
local is_talking = false
local is_doing_up_action = false
local is_doing_action = false
local is_doing_finish = false
local InitLocY = nil
local near_int = nil
local cur_near_int = nil
local cur_near_int_add = nil
local cur_near_lad = nil
local is_running = false
local is_right_click = false
local reading_doc = false
local load_inst = nil
local loading_scr = false
local loading_scr_t = false
local in_puzzle = false
local first_weap_init = false
local ex_pog = false
local alt_pawn = false
local in_grab = false
local in_grabbed = false
local rolling_credits = false
local doing_lock = false
local ladder_up = false
local ladder_height = nil
local get_ladder_height = false
local ladder_loc = nil
local got_number = false
local pause_visible = nil
local cur_aim = nil
local intro_running = false
local pinned = false
local is_reading = false
local TutSOnce = false
local TutCOnce = false

local function reset_height()
	local base = UEVR_Vector3f.new()
	params.vr.get_standing_origin(base)
	local hmd_index = params.vr.get_hmd_index()
	local hmd_pos = UEVR_Vector3f.new()
	local hmd_rot = UEVR_Quaternionf.new()
	params.vr.get_pose(hmd_index, hmd_pos, hmd_rot)
	base.x = hmd_pos.x
	base.y = hmd_pos.y
	base.z = hmd_pos.z
	params.vr.set_standing_origin(base)
	if hmd_pos.y >= 0.4 then
		InitLocY = 0.30
	else
		InitLocY = -0.10
	end
end

local function GetMesh()
	--FPMesh
	local skeletal_mesh_c = api:find_uobject("Class /Script/Engine.SkeletalMeshComponent")
	if skeletal_mesh_c ~= nil then
		local skeletal_meshes = skeletal_mesh_c:get_objects_matching(false)


		for i, mesh in ipairs(skeletal_meshes) do
			if mesh:get_fname():to_string() == "CharacterMesh0" and string.find(mesh:get_full_name(), "PersistentLevel.BP_HabitatCharacterDefault_C") or mesh:get_fname():to_string() == "CharacterMesh0" and string.find(mesh:get_full_name(), "PersistentLevel.BP_MainPlayer_") then
				Fpmesh = mesh
				--print(tostring(Fpmesh:get_full_name()))

				break
			end
		end
	end
end

local function AltMesh()
	--FPMesh
	local skeletal_mesh_c = api:find_uobject("Class /Script/Engine.SkeletalMeshComponent")
	if skeletal_mesh_c ~= nil then
		local skeletal_meshes = skeletal_mesh_c:get_objects_matching(false)


		for i, mesh in ipairs(skeletal_meshes) do
			if mesh:get_fname():to_string() == "BPC_MP5" and string.find(mesh:get_full_name(), "PersistentLevel.BP_MainPlayer_") then
				mesh:call("SetRenderInMainPass", false)
				mesh:call("SetVisibility", false)
				--print(tostring(mesh:get_full_name()))

				break
			end
		end
	end
end

local function CamShake_Remove()
	--CamShake
	local shake_c = api:find_uobject("Class /Script/Engine.CameraModifier_CameraShake")
	if shake_c == nil then print("Fucked") end
	local shake = shake_c:get_objects_matching(false)
	local anim_rate = nil

	for i, mesh in ipairs(shake) do
		if string.find(mesh:get_fname():to_string(), "CameraModifier_CameraShake") then
			SG_Shake = mesh
			SG_Shake:DisableModifier(true)
			--print(tostring(SG_Shake:get_full_name()))

			break
		end
	end
end

local function FinalRecap()
	--Anims
	local anim_c = api:find_uobject("Class /Script/UMG.UserWidget")
	if anim_c ~= nil then
		local anim = anim_c:get_objects_matching(false)


		for i, mesh in ipairs(anim) do
			if string.find(mesh:get_full_name(), "Transient.GameEngine") and string.find(mesh:get_full_name(), ".WBP_FinalRecap_C") then
				recap_inst = mesh
				final_recap = recap_inst.bIsEnabled
				--print(tostring(recap_inst:get_full_name()))

				break
			end
		end
	end
end

local function ArrowRem()
	--Anims
	local anim_c = api:find_uobject("Class /Script/UMG.Image")
	if anim_c ~= nil then
		local anim = anim_c:get_objects_matching(false)


		for i, mesh in ipairs(anim) do
			if string.find(mesh:get_full_name(), "Transient.GameEngine") and string.find(mesh:get_full_name(), ".WBP_Cursor_C") then
				cursor_inst = mesh.Brush.DrawAs
				if cursor_inst ~= 2 then
					mesh.Brush.DrawAs = 2
					--print(tostring(cursor_inst:get_full_name()))
				end
				break
			end
		end
	end
end

local function PogDisplay()
	--POGs
	local anim_c = api:find_uobject("Class /Script/Engine.LevelScriptActor")
	if anim_c ~= nil then
		local anim = anim_c:get_objects_matching(false)


		for i, mesh in ipairs(anim) do
			if string.find(mesh:get_full_name(), "PogDisplay.PersistentLevel") and string.find(mesh:get_full_name(), ".MAP_PogDisplay_C") then
				pog_inst = mesh
				ex_pog = mesh.Pogs.ExaminingPOG
				--print(tostring(pog_inst:get_full_name()))

				break
			end
		end
	end
end

local function LoadingScr()
	--Loading Screen
	local load_c = api:find_uobject("Class /Script/UMG.UserWidget")
	if load_c ~= nil then
		local loadsc = load_c:get_objects_matching(false)


		for i, mesh in ipairs(loadsc) do
			if mesh ~= nil and string.find(mesh:get_full_name(), "Transient.GameEngine") and string.find(mesh:get_full_name(), ".WBP_LoadingScreen_C") then
				load_inst = mesh
				loading_scr = mesh.LoadCompleted
				--print(tostring(load_inst:get_full_name()))

				break
			end
		end
		for i, mesh in ipairs(loadsc) do
			if mesh ~= nil and string.find(mesh:get_full_name(), "Transient.GameEngine") and string.find(mesh:get_full_name(), "WBP_LoadingScreenTips_C ") then
				load_t_inst = mesh
				loading_scr_t = mesh.LoadCompleted
				--print(tostring(load_t_inst:get_full_name()))

				break
			end
		end
	end
end

local function HideBody()
	local ladder_pawn = api:get_local_pawn(0)
	params.vr.set_mod_value("VR_CameraForwardOffset", "0.00")
	if ladder_pawn ~= nil then
		ladder_pawn.Mesh:call("SetRenderInMainPass", false)
	end
end

local function ShowBody()
	local ladder_pawn = api:get_local_pawn(0)
	if ladder_pawn ~= nil then
		ladder_pawn.Mesh:call("SetRenderInMainPass", true)
	end
end

local function AutoAim()
	--AimGesture
	if Playing == true and intro_running == false then
		local apawn = api:get_local_pawn(0)
		local near_int = apawn.CurrentInteractableObj
		local near_fin = apawn.FinisherActorInRange
		if InitLocY == nil then InitLocY = -0.10 end
		--local InitLocY = 0.30
		local right_controller_index = params.vr.get_right_controller_index()
		local right_controller_position = UEVR_Vector3f.new()
		local right_controller_rotation = UEVR_Quaternionf.new()
		params.vr.get_pose(right_controller_index, right_controller_position, right_controller_rotation)

		--print("Position: " .. tostring(right_controller_position.x) .. ", " .. tostring(right_controller_position.y) .. ", " .. tostring(right_controller_position.z))
		--print("Rotation: " .. tostring(right_controller_rotation.x) .. ", " .. tostring(right_controller_rotation.y) .. ", " .. tostring(right_controller_rotation.z) .. ", " .. tostring(right_controller_rotation.w))

		--local pose_x_current = right_controller_position.x
		local pose_y_current = right_controller_position.y
		--local pose_z_current = right_controller_position.z
		if pose_y_current >= InitLocY and near_int == nil and near_fin == nil then
			if weap_aim == false then
				--print("Weapon Aim Active")
				apawn.AimPressed = true
				weap_aim = true
			end
		elseif pose_y_current <= InitLocY or near_int ~= nil or near_fin ~= nil then
			if weap_aim == true then
				--print("Weapon Aim Closed")
				apawn.AimPressed = false
				weap_aim = false
			end
		end
	end
end

local function WeaponSelect()
	--Weapon Select Gesture
	if Playing == true and intro_running == false then
		local InitRot = 0.70
		local InitLocY = 0.60
		local InitLocZ = 0.07
		local InitLocW = -0.60
		local right_controller_index = params.vr.get_right_controller_index()
		local right_controller_position = UEVR_Vector3f.new()
		local right_controller_rotation = UEVR_Quaternionf.new()
		params.vr.get_pose(right_controller_index, right_controller_position, right_controller_rotation)

		--print("Position: " .. tostring(right_controller_position.x) .. ", " .. tostring(right_controller_position.y) .. ", " .. tostring(right_controller_position.z))
		--print("Rotation: " .. tostring(right_controller_rotation.x) .. ", " .. tostring(right_controller_rotation.w))

		local pose_x_current = right_controller_rotation.x
		local pose_y_current = right_controller_position.y
		local pose_z_current = right_controller_position.z
		local pose_w_current = right_controller_rotation.w
		if pose_x_current >= InitRot and pose_w_current <= InitLocW and weap_sel == false then
			--print("Weapon Select Active")
			params.vr.set_aim_method(1)
			params.vr.set_mod_value("VR_DPadShiftingMethod", "2")
			weap_sel = true
		elseif pose_x_current <= InitRot and pose_w_current >= InitLocW and weap_sel == true then
			--print("Weapon Select Closed")
			params.vr.set_aim_method(2)
			params.vr.set_mod_value("VR_DecoupledPitchUIAdjust", "true")
			params.vr.set_mod_value("VR_DPadShiftingMethod", "0")
			weap_sel = false
		end
	end
end

local function End_Credits()
	local skeletal_mesh_c = api:find_uobject("Class /Script/UMG.UserWidget")
	if skeletal_mesh_c ~= nil then
		local skeletal_meshes = skeletal_mesh_c:get_objects_matching(false)

		local mesh = nil
		for i, mesh in ipairs(skeletal_meshes) do
			if string.find(mesh:get_full_name(), "WBP_GameCredits_C") and string.find(mesh:get_full_name(), "Transient.GameEngine") then
				in_credits = mesh
				--print(tostring(in_credits:get_full_name()))

				break
			end
		end
	end
end

local function CraneWeap()
	MP5:call("SetRenderInMainPass", false)
	MP5:call("SetVisibility", false)
	Shotgun:call("SetRenderInMainPass", false)
	Shotgun:call("SetVisibility", false)
end

print("Daymare 1994 VR - CJ117")
params.vr.set_aim_method(0)
params.vr.set_mod_value("FrameworkConfig_AlwaysShowCursor", "false")
params.vr.set_mod_value("VR_CameraUpOffset", "0.00")
params.vr.set_mod_value("UI_FollowView", "false")
params.vr.set_mod_value("VR_DecoupledPitchUIAdjust", "true")
params.vr.set_mod_value("UI_Distance", "3.000")
params.vr.set_mod_value("UI_Size", "2.700")
params.vr.set_mod_value("UI_X_Offset", "0.00")
params.vr.set_mod_value("UI_Y_Offset", "0.00")
params.vr.set_mod_value("VR_CameraForwardOffset", "0.00")
params.vr.set_mod_value("VR_CameraRightOffset", "0.00")
params.vr.set_mod_value("VR_DPadShiftingMethod", "0")
reset_height()

uevr.sdk.callbacks.on_pre_engine_tick(function(engine, delta)
	local game_engine_class = api:find_uobject("Class /Script/Engine.GameEngine")
	local game_engine = UEVR_UObjectHook.get_first_object_by_class(game_engine_class)

	local viewport = game_engine.GameViewport
	if viewport == nil then
		print("Viewport is nil")
		return
	end
	local world = viewport.World

	local pawn = api:get_local_pawn(0)
	local pcont = api:get_player_controller(0)
	--print(tostring(pawn.Mesh:get_full_name()))
	if pawn ~= nil then
		WeaponSelect()
		CamShake_Remove()
		AutoAim()
		LoadingScr()

		if string.find(pawn:get_full_name(), "SL_Portal_Player.PersistentLevel.BP_MainPlayer") then
			FinalRecap()
		end
		if pawn == nil or string.find(pawn:get_full_name(), "SL_CastleLab_Exterior_Player") then
			End_Credits()
		end
		if in_credits == nil or string.find(pawn:get_full_name(), "SL_Portal_Player") then
			rolling_credits = false
		else
			rolling_credits = true
		end

		if not string.find(pawn:get_full_name(), "BP_AlternativeReyes") then
			in_cutscene = pawn.IsInCutscene
			is_playing = pawn.PlayerHUD.IsOnScreen
			Intro_doc = pawn.ReadDocPressed
			Cur_Weap = pawn.CurrentWeapon
			MP5 = pawn.BPC_MP5
			Shotgun = pawn.BPC_Shotgun
			is_inventory = pawn.Inventory.IsOpen
			is_examine = pawn.Inventory.InventoryWidgetRef.ExamineOverlay.Visibility
			is_S_inventory = pawn.IsInSpecialInteract
			is_doing_action = pawn.DoingAction
			is_doing_finish = pawn.IsDoingMeleeFinisher
			is_doing_up_action = pawn.DoingUpperBodyAction
			is_aiming = pawn.AimPressed
			is_moving = pawn.Moving
			is_talking = pawn.IsTalking
			in_narrative = pawn.HasNarrativeFocus
			cur_near_int = pawn.CurrentInteractableObj

			cur_near_lad = pawn.CurrentLadder
			reading_doc = pawn.ReadDocPressed
			play_forbid = pawn.PauseHUD.GameInstance.ActivityForbidden
			in_grab = pawn.EscapingGrab
			in_grabbed = pawn.Grabbed
			pause_visible = pawn.PauseHUD.Visibility
			p_hud = pawn.PlayerHUD:get_outer()

			if p_hud ~= nil then
				p_hud.HUDAlwaysOn = true
				p_hud.ToggleRun = true
			end

			if cur_near_int == nil then
				cur_near_int = "None"
			end
			if cur_near_lad == nil then
				cur_near_lad = "None"
			else
				ladder_up = pawn.CurrentLadder.IsClimbingUp
				ladder_rungs = pawn.CurrentLadder.Rungs
				ladder_rungs_climbed = pawn.CurrentLadder.RungsClimbed
				ladder_loc = pcont.PlayerCameraManager.ViewTarget.POV.Location.Z
			end
		end

		if Cur_Weap == nil
		then
			if Active_Weap ~= "None" then
				MP5:call("SetRenderInMainPass", false)
				MP5:call("SetVisibility", false)
				Shotgun:call("SetRenderInMainPass", false)
				Shotgun:call("SetVisibility", false)
				Active_Weap = "None"
			end
		else
			if string.find(Cur_Weap:get_full_name(), "BPC_Shotgun") then
				if Active_Weap ~= "Shotgun" then
					MP5:call("SetRenderInMainPass", false)
					MP5:call("SetVisibility", false)
					Shotgun:call("SetRenderInMainPass", true)
					Shotgun:call("SetVisibility", true)
					Active_Weap = "Shotgun"
					--print("Shotgun Equipped")
				end
				state = UEVR_UObjectHook.get_or_add_motion_controller_state(Shotgun)
				state:set_rotation_offset(Vector3f.new(-0.03, 0.0, 0.0))
			elseif string.find(Cur_Weap:get_full_name(), "BPC_MP5") then
				if Active_Weap ~= "MP5" then
					Shotgun:call("SetRenderInMainPass", false)
					Shotgun:call("SetVisibility", false)
					MP5:call("SetRenderInMainPass", true)
					MP5:call("SetVisibility", true)
					Active_Weap = "MP5"
					--print("MP5 Equipped")
				end
				state = UEVR_UObjectHook.get_or_add_motion_controller_state(MP5)
				state:set_rotation_offset(Vector3f.new(-0.03, 1.575, 0.0))
				state:set_permanent(true)
			elseif CurWeap == nil then
				MP5:call("SetRenderInMainPass", false)
				MP5:call("SetVisibility", false)
				Shotgun:call("SetRenderInMainPass", false)
				Shotgun:call("SetVisibility", false)
				Active_Weap = "None"
			else
			end
		end
	end

	if pawn ~= nil and cur_near_int == "None" and string.find(pawn:get_full_name(), "LairDam") and in_cutscene == false and pause_visible ~= 4 and reading_doc == false then
		intro_running = true
		CraneWeap()
		ArrowRem()
	else
		intro_running = false
	end

	if first_weap_init == false then
		first_weap_init = true
		Active_Weap = "None"
	end
	PogDisplay()

	if is_playing and is_moving == false then

	end

	if pawn == nil or is_reading == true or intro_running == true or in_cutscene == true or is_inventory == true or final_recap == true or is_doing_action == true or in_narrative == true or loading_scr == true or loading_scr_t == true or play_forbid == true or rolling_credits == true or pause_visible == 4 or is_playing == false then
		if Mactive == false then
			Mactive = true
			Playing = false

			if string.find(world:get_full_name(), "MAP_PogDisplay") then
				PogDisplay()
				params.vr.set_mod_value("VR_DecoupledPitchUIAdjust", "true")
			else
				PogDisplay()
				params.vr.set_mod_value("VR_DecoupledPitchUIAdjust", "false")
			end

			params.vr.set_aim_method(0)
			if is_playing == false or final_recap == true then
				params.vr.set_mod_value("VR_DPadShiftingMethod", "2")
			end

			--print(tostring(cur_near_int))
			if pawn ~= nil and cur_near_int ~= "None" and not string.find(pawn:get_full_name(), "BP_AlternativeReyes") then
				if Playing == false and is_playing == false and is_inventory == false and string.find(cur_near_int:get_full_name(), "BP_Lock_C") then
					doing_lock = true
					params.vr.set_mod_value("VR_DecoupledPitchUIAdjust", "true")
					params.vr.set_mod_value("UI_Distance", "0.250")
					params.vr.set_mod_value("UI_Size", "0.500")
					params.vr.set_mod_value("VR_CameraForwardOffset", "-10.00")
					params.vr.set_mod_value("VR_CameraUpOffset", "6.00")
				end
			end
			print("In Cut / Paused")
		end

		if intro_running == true then
			params.vr.set_mod_value("VR_DPadShiftingMethod", "0")
		end

		if string.find(world:get_full_name(), "MAP_PogDisplay") and ex_pog == false and doing_lock == false then
			params.vr.set_mod_value("VR_CameraForwardOffset", "400.00")
			params.vr.set_mod_value("VR_CameraUpOffset", "-323.00")
			params.vr.set_mod_value("VR_DecoupledPitchUIAdjust", "true")
		else
			if doing_lock == false then
				params.vr.set_mod_value("VR_CameraUpOffset", "0.00")
				params.vr.set_mod_value("VR_CameraForwardOffset", "0.00")

				params.vr.set_mod_value("VR_DecoupledPitchUIAdjust", "false")
			end
		end

		if is_inventory == true and is_examine ~= 0 then
			params.vr.set_mod_value("VR_DPadShiftingMethod", "0")

			if cur_near_int ~= nil and is_S_inventory == true then
				if cur_near_int ~= "None" and string.find(cur_near_int:get_full_name(), "BP_BadgeUpgradeTerminal_C") then
					params.vr.set_mod_value("VR_CameraForwardOffset", "-30.00")
					params.vr.set_mod_value("VR_CameraUpOffset", "30.00")
				elseif cur_near_int ~= "None" and string.find(cur_near_int:get_full_name(), "BP_ClimateLab_Badge") then
					params.vr.set_mod_value("VR_CameraForwardOffset", "-30.00")
					params.vr.set_mod_value("VR_CameraUpOffset", "30.00")
				elseif cur_near_int ~= "None" and string.find(cur_near_int:get_full_name(), "SecurityTerminal_C") then
					params.vr.set_mod_value("VR_CameraForwardOffset", "-30.00")
					params.vr.set_mod_value("VR_CameraUpOffset", "30.00")
				elseif cur_near_int ~= "None" and string.find(cur_near_int:get_full_name(), "BP_HackTerminal_C") then
					--params.vr.set_mod_value("VR_CameraForwardOffset", "-30.00")
					params.vr.set_mod_value("VR_CameraUpOffset", "30.00")
				elseif cur_near_int ~= "None" and string.find(cur_near_int:get_full_name(), "BasementDoor_C") then
					params.vr.set_mod_value("VR_CameraForwardOffset", "-30.00")
					params.vr.set_mod_value("VR_CameraUpOffset", "30.00")
				elseif cur_near_int ~= "None" and string.find(cur_near_int:get_full_name(), "BP_A51Entrance_KeyPanel_C") then
					params.vr.set_mod_value("VR_CameraForwardOffset", "-30.00")
					params.vr.set_mod_value("VR_CameraUpOffset", "30.00")
				elseif cur_near_int ~= "None" and string.find(cur_near_int:get_full_name(), "BP_ResidentialArea_HabitativeModule_C") then
					params.vr.set_mod_value("VR_CameraForwardOffset", "20.00")
					params.vr.set_mod_value("VR_CameraUpOffset", "30.00")
				elseif cur_near_int ~= "None" and string.find(cur_near_int:get_full_name(), "BP_ResidentialArea_SuiteLock_C") then
					params.vr.set_mod_value("VR_CameraUpOffset", "30.00")
				end
			end
		end

		if is_examine == 0 then
			params.vr.set_mod_value("UI_Distance", "0.500")
			params.vr.set_mod_value("UI_Size", "0.630")
		elseif doing_lock == false then
			params.vr.set_mod_value("UI_Distance", "3.000")
			params.vr.set_mod_value("UI_Size", "2.700")
		end

		if is_doing_action == true then
			if cur_near_int == nil then else
				if cur_near_lad ~= nil and cur_near_lad ~= "None" then
					ShowBody()
					doing_ladder = true
					UEVR_UObjectHook.set_disabled(true)
					if string.find(cur_near_lad:get_full_name(), "SL_MacroZone_BP.PersistentLevel.BP_Ladder_2") or string.find(cur_near_lad:get_full_name(), "SL_MacroZone_BP.PersistentLevel.BP_Ladder2") then
						params.vr.set_mod_value("VR_CameraForwardOffset", "14.00")
					end
					--params.vr.set_mod_value("VR_CameraUpOffset", "114.286")
				elseif cur_near_int ~= "None" and string.find(cur_near_int:get_full_name(), "BP_ElevatorControlPanel_C") then
					params.vr.set_mod_value("VR_DecoupledPitchUIAdjust", "true")
				elseif cur_near_int ~= "None" and string.find(cur_near_int:get_full_name(), "BP_UpgradeStation_C") then
					params.vr.set_mod_value("VR_DecoupledPitchUIAdjust", "true")
					params.vr.set_mod_value("UI_Distance", "13.000")
					params.vr.set_mod_value("UI_Size", "8.677")
					params.vr.set_mod_value("UI_X_Offset", "-0.500")
					params.vr.set_mod_value("UI_Y_Offset", "1.978")
				elseif cur_near_int ~= "None" and string.find(cur_near_int:get_full_name(), "BP_Outside_ElectricControlPanel_C") then
					in_puzzle = true
					ArrowRem()
					params.vr.set_mod_value("VR_DPadShiftingMethod", "3")
					params.vr.set_mod_value("FrameworkConfig_AlwaysShowCursor", "true")
					params.vr.set_mod_value("VR_DecoupledPitchUIAdjust", "true")
					params.vr.set_mod_value("UI_Distance", "15.000")
					params.vr.set_mod_value("UI_Size", "7.177")
					params.vr.set_mod_value("UI_Y_Offset", "-2.627")
					params.vr.set_mod_value("VR_CameraForwardOffset", "-30.00")
					params.vr.set_mod_value("VR_CameraUpOffset", "20.00")
				elseif cur_near_int ~= "None" and string.find(cur_near_int:get_full_name(), "BP_DetentionArea_MainTerminal_C") then
					params.vr.set_mod_value("VR_DecoupledPitchUIAdjust", "true")
					params.vr.set_mod_value("UI_Distance", "15.000")
					params.vr.set_mod_value("UI_Size", "7.177")
					params.vr.set_mod_value("UI_Y_Offset", "-2.627")
					params.vr.set_mod_value("VR_CameraForwardOffset", "-30.00")
					params.vr.set_mod_value("VR_CameraUpOffset", "20.00")
				elseif cur_near_int ~= "None" and string.find(cur_near_int:get_full_name(), "BP_ClimateLab_BadgeTerminal_C") then
					params.vr.set_mod_value("VR_CameraForwardOffset", "-30.00")
					params.vr.set_mod_value("VR_CameraUpOffset", "30.00")
				elseif cur_near_int ~= "None" and string.find(cur_near_int:get_full_name(), "BP_CameraFocusInteraction_C") then
					params.vr.set_mod_value("VR_DecoupledPitchUIAdjust", "true")
				elseif cur_near_int ~= "None" and string.find(cur_near_int:get_full_name(), "BP_HackTerminal_C") then
					params.vr.set_mod_value("VR_CameraUpOffset", "0.00")
					params.vr.set_mod_value("VR_CameraForwardOffset", "-5.00")
				elseif cur_near_int ~= "None" and string.find(cur_near_int:get_full_name(), "BP_MagneticCraneButton_C") then
					CraneWeap()
				else

				end
			end
		else

		end

		if pawn ~= nil and cur_near_int ~= "None" and cur_near_int ~= nil and string.find(cur_near_int:get_full_name(), "BP_PoolLever_C") then
			cur_near_int_add = pawn.CurrentInteractableObj.InteractArrow.bVisible
			params.vr.set_mod_value("VR_DecoupledPitchUIAdjust", "true")
			params.vr.set_mod_value("VR_CameraForwardOffset", "-30.00")
			params.vr.set_mod_value("VR_CameraUpOffset", "30.00")
		end

		if is_talking == true and is_doing_action == false and is_inventory == false and is_moving == false then
			if cur_near_int ~= "None" and not string.find(cur_near_int:get_full_name(), "BP_PoolLever_C") then
				pawn.AimPressed = true
				weap_aim = true
			end
		end
		--print(cur_near_int_add)
		if is_talking == false and is_doing_action == false and is_inventory == false and is_moving == false and cur_near_int_add == true then
			pawn.AimPressed = true
			weap_aim = true
		end

		if in_grab == true or in_grabbed == true or is_doing_finish == true then
			UEVR_UObjectHook.set_disabled(true)
			params.vr.set_mod_value("VR_CameraForwardOffset", "-30.00")
			ShowBody()
		end
	else
		if Playing == false then
			Mactive = false
			Playing = true
			doing_lock = false
			in_puzzle = false
			first_weap_init = false
			doing_ladder = false
			get_ladder_height = false
			got_number = false
			pinned = false
			intro_running = false
			pawn.bFindCameraComponentWhenViewTarget = false
			params.vr.set_mod_value("FrameworkConfig_AlwaysShowCursor", "false")
			params.vr.set_mod_value("VR_CameraUpOffset", "0.00")
			params.vr.set_mod_value("VR_CameraForwardOffset", "0.00")
			params.vr.set_mod_value("UI_Distance", "3.000")
			params.vr.set_mod_value("UI_Size", "2.700")
			params.vr.set_mod_value("UI_X_Offset", "0.00")
			params.vr.set_mod_value("UI_Y_Offset", "0.00")
			params.vr.set_mod_value("UI_FollowView", "false")
			params.vr.set_mod_value("VR_DecoupledPitchUIAdjust", "true")
			UEVR_UObjectHook.set_disabled(false)
			params.vr.set_aim_method(2)
			params.vr.set_mod_value("VR_DPadShiftingMethod", "0")
			HideBody()
			ArrowRem()
			--pawn.PlayerHUD.AlwaysActive = true
			print("Playing")
		end
	end

	if pawn ~= nil and string.find(pawn:get_full_name(), "BP_AlternativeReyes") then
		alt_pawn = true
		pawn.bFindCameraComponentWhenViewTarget = true
	else
		alt_pawn = false
	end
end)

callbacks.on_pre_calculate_stereo_view_offset(function(device, view_index, world_to_meters, position, rotation, is_double)
	if doing_ladder == true then
		--print("Z: " .. tostring(rotation.z))
		if ladder_up == true then
			if ladder_rungs_climbed < 1 then
				position.z = position.z + 75
			elseif ladder_rungs_climbed < ladder_rungs then
				position.z = position.z + 95
			else
				if ladder_loc ~= nil and got_number == false then
					got_number = true
					ladder_height = (ladder_loc + 290)
				end
				position.z = ladder_height
			end
		else
			if ladder_rungs_climbed < 1 then
				if ladder_loc ~= nil and got_number == false then
					got_number = true
					ladder_height = (ladder_loc)
				end
				position.z = ladder_height
			elseif ladder_rungs_climbed < ladder_rungs then
				got_number = false
				position.z = position.z + 95
			else
				if ladder_loc ~= nil and got_number == false then
					got_number = true
					ladder_height = (ladder_loc + 40)
				end
				position.z = ladder_height
			end
		end
	else

	end

	local vpawn = api:get_local_pawn(0)
	if vpawn ~= nil and string.find(vpawn:get_full_name(), "SL_Castle_Lab_BP_P3.PersistentLevel.BP_AlternativeReyes_2") then
		AltMesh()
	end

	if doing_ladder == true then
		vpawn.Mesh.RelativeRotation.Yaw = -90.0
	end
end)


uevr.sdk.callbacks.on_xinput_get_state(function(retval, user_index, state)
	if (state ~= nil) then
		if Mactive == true then
			if state.Gamepad.bLeftTrigger ~= 0 and state.Gamepad.bRightTrigger ~= 0 then
				if JustCentered == false then
					JustCentered = true
					reset_height()
					params.vr.recenter_view()
					JustCentered = false
				end
			end
		end

		if Playing == true then
			if state.Gamepad.sThumbRY >= 30000 then
				if is_running == false then
					is_running = true
					state.Gamepad.wButtons = state.Gamepad.wButtons | XINPUT_GAMEPAD_LEFT_THUMB
				end
			else
				is_running = false
			end
		end

		if Playing == true then
			if state.Gamepad.sThumbRY <= -30000 then
				if is_right_click == false then
					is_right_click = true
					state.Gamepad.wButtons = state.Gamepad.wButtons | XINPUT_GAMEPAD_RIGHT_THUMB
				end
			else
				is_right_click = false
			end
		end
	end
end)

uevr.sdk.callbacks.on_script_reset(function()
	JustCentered = false
	Mactive = false
	Lactive = false
	Playing = false
	is_interacting = false
	in_cutscene = false
	is_playing = false
	is_anim_cam = false
	Fpmesh = nil
	SG_Shake = nil
	Handsmesh = nil
	Intro_doc = false
	is_traversing = nil
	recap_inst = nil
	is_glas_cut = false
	Cur_Weap = nil
	MP5 = nil
	Shotgun = nil
	Active_Weap = "None"
	state = nil
	is_inventory = false
	is_climbing = false
	weap_sel = false
	weap_aim = false
	is_aiming = false
	is_doing_up_action = false
	is_doing_action = false
	InitLocY = nil
	near_int = nil
	cur_near_int = nil
	cur_near_lad = nil
	is_running = false
	is_right_click = false
	reading_doc = false
	load_inst = nil
	loading_scr = false
	loading_scr_t = false
	in_puzzle = false
	first_weap_init = false
	ex_pog = false
	alt_pawn = false
	in_grab = false
	in_grabbed = false
end)
