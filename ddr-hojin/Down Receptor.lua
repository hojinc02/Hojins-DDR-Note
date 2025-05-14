overlay_opacity=0.8

local function pressreceptor()
	return 
    function(self) 
      self
      :finishtweening()
      :zoom(0.75)
      :linear(0.04)
      :zoom(1.0)
    end
end

local function pressoverlay()
  return 
    function(self) 
      self
      :finishtweening()
      :diffusealpha(overlay_opacity)
      :zoom(0.95)
      :linear(0.03)
      :zoom(1.0)
      :diffusealpha(overlay_opacity)
    end
end

local function liftoverlay()
  return
    function(self)
			self
      :finishtweening()
      :diffusealpha(overlay_opacity)
			:zoom(1.0)
			:linear(0.028)
			:zoom(0.95)
      :diffusealpha(0)
		end
end
      

local t = Def.ActorFrame {
	Def.Sprite {
		Texture=NOTESKIN:GetPath( '_down', 'Go Receptor' );
		InitCommand=
      function(self)
        self:effectclock("beat");
        self:SetStateProperties({{Frame= 0, Delay=0.2}, {Frame= 1, Delay=0.8}});
			end;
		NoneCommand=pressreceptor(),
		PressCommand=pressreceptor(),
		HeldCommand=pressreceptor(),
		W5Command=pressreceptor(),
		W4Command=pressreceptor(),
		W3Command=pressreceptor(),
		W2Command=pressreceptor(),
		W1Command=pressreceptor(),
	};
  Def.Sprite {
    Texture=NOTESKIN:GetPath('Down', 'Press');
    InitCommand=function(self) self:diffusealpha(0); end;
    NoneCommand=pressoverlay(),
    PressCommand=pressoverlay(),
    LiftCommand=liftoverlay(),
  };
};
return t;
