local white = color("#c8c8c8")
local yellow = color("#d3d341")
local green = color("#41ff41")
local blue = color("#6464ff")
local purple = color("#a050ff")
local lightblue = color("#32eeff")

local function invisible()
	return function(self) self:blend(Blend.Add):diffuse(0,0,0,0) end
end

local function finish()
	return function(self) self:finishtweening() end
end

local function shockbright()
	return function(self)
			self:blend(Blend.Add):diffuse(lightblue):diffusealpha(0.9):
			zoom(2.5):sleep(0.2):linear(0.01):
			diffusealpha(0.0)
	end
end

local function shockzap()
	return function(self)
			self:blend(Blend.Add):diffuse(white):diffusealpha(0.9):
			rotationz(0):zoom(0.7):spring(0.05):
			zoom(1.3):sleep(0.15):linear(0.01):
			diffusealpha(0.0)
	end
end

local function ghostdim(c)
	return function(self)
		self:blend(Blend.Add):diffuse(c):diffusealpha(1.0):
		zoom(0.9):linear(0.12):zoom(1):
		diffusealpha(0.9):linear(0.05):diffusealpha(0)
	end
end

local function ghostbright(c)
	return function(self)
		self:blend(Blend.Add):diffuse(c):diffusealpha(1.0):
		zoom(0.64):linear(0.07):zoom(0.8):
		diffusealpha(0.9):linear(0.02):diffusealpha(0)
	end
end

local function holddiffuse()
	return function(self)
		self:sleep(0.12):blend(Blend.Add):diffuse(white):
		diffuseshift():effectcolor1(1,1,1,1):effectcolor2(1,1,1,0.6):
		effectperiod(0.11)
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
		
		W1Command=ghostdim(white),
		W2Command=ghostdim(yellow),
		W3Command=ghostdim(green),
		W4Command=ghostdim(blue),
		W5Command=ghostdim(purple),
		HeldCommand=ghostdim(white),
	},
	NOTESKIN:LoadActor( Var "Button", "Tap Explosion Bright" ) .. {
		JudgmentCommand=finish(),
		InitCommand=invisible(),
		
		W1Command=ghostbright(white),
	},
	NOTESKIN:LoadActor( Var "Button", "Tap Explosion Mid" ) .. {
		JudgmentCommand=finish(),
		InitCommand=invisible(),
		
		W2Command=ghostbright(yellow),
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