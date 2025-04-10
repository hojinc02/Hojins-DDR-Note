local COLOR_W1 = color("#b2ebfe")
local COLOR_W2 = color("#ffde50")
local COLOR_W3 = color("#57ff6b")
local COLOR_W4 = color("#4fa1ff")
local COLOR_W5 = color("#cc4fff")
local COLOR_HOLD = color("#ececec")
local COLOR_SHOCK = color("#64c8ff")
local COLOR_HOLD_R = 0.925
local COLOR_HOLD_G = 0.925
local COLOR_HOLD_B = 0.925



local function invisible()
	return 
		function(self) 
			self:
			blend(Blend.Add):
			diffuse(0,0,0,0) 
		end
end

local function finish()
	return 
		function(self) 
			self:
			finishtweening() 
		end
end

local function shockbright()
	return 
		function(self)
			self:
			blend(Blend.Add):
			diffuse(COLOR_SHOCK):
			diffusealpha(0.9):
			zoom(2.5):
			sleep(0.2):
			linear(0.01):
			diffusealpha(0.0)
		end
end

local function shockzap()
	return 
		function(self)
			self:
			blend(Blend.Add):
			diffuse(COLOR_W1):
			diffusealpha(0.9):
			rotationz(0):
			zoom(0.7):
			spring(0.05):
			zoom(1.3):
			sleep(0.15):
			linear(0.01):
			diffusealpha(0.0)
		end
end

local function ghostdim(c)
	return 
		function(self)
			self:
			blend(Blend.Add):
			diffuse(c):
			diffusealpha(1.0):
			zoom(0.9):
			linear(0.12):
			zoom(1):
			diffusealpha(1.0):
			sleep(0.04):
			linear(0.04):
			diffusealpha(0)
		end
end

local function ghostbright(c)
	return 
		function(self)
			self:
			blend(Blend.Add):
			diffuse(c):
			diffusealpha(1.0):
			zoom(0.64):
			linear(0.06):
			zoom(0.8):
			diffusealpha(1.0):
			sleep(0.02):
			linear(0.04):
			diffusealpha(0)
		end
end

local function holddiffuse()
	return 
		function(self)
			self:
			sleep(0.16):
			blend(Blend.Add):
			diffuse(COLOR_W1):
			diffuseshift():
			effectcolor1(COLOR_HOLD_R,COLOR_HOLD_G,COLOR_HOLD_B,0.6):
			effectcolor2(COLOR_HOLD_R,COLOR_HOLD_G,COLOR_HOLD_B,0.9):
			effectperiod(0.08)
		end
end

local t = Def.ActorFrame {
	NOTESKIN:LoadActor( Var "Button", "Hold Explosion" ) .. {
		InitCommand=invisible(),
		HoldingOnCommand=holddiffuse(),
		HoldingOffCommand=invisible(),
	},
	NOTESKIN:LoadActor( Var "Button", "Roll Explosion" ) .. {
		InitCommand=invisible(),
		RollOnCommand=holddiffuse(),
		RollOffCommand=invisible(),
	},
	NOTESKIN:LoadActor(Var "Button", "Tap Explosion Dim")..{ 
		JudgmentCommand=finish(),
		InitCommand=invisible(),
		
		W1Command=ghostdim(COLOR_W1),
		W2Command=ghostdim(COLOR_W2),
		W3Command=ghostdim(COLOR_W3),
		W4Command=ghostdim(COLOR_W4),
		W5Command=ghostdim(COLOR_W5),
		HeldCommand=ghostdim(COLOR_W1),
	},
	NOTESKIN:LoadActor( Var "Button", "Tap Explosion Bright" ) .. {
		JudgmentCommand=finish(),
		InitCommand=invisible(),
		
		W1Command=ghostbright(COLOR_W1),
	},
	NOTESKIN:LoadActor( Var "Button", "Tap Explosion Mid" ) .. {
		JudgmentCommand=finish(),
		InitCommand=invisible(),
		
		W2Command=ghostbright(COLOR_W2),
	},
	NOTESKIN:LoadActor( Var "Button", "HitMine Explosion" ) .. {
		InitCommand=invisible();
		HitMineCommand=shockbright(),
	},
	NOTESKIN:LoadActor( Var "Button", "HitMine3 Explosion" ) .. {
		InitCommand=invisible();
		HitMineCommand=shockzap(),
	},
}
return t;