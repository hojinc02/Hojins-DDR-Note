overlay_opacity=0.8
frame=0.03333333

local function pressreceptor()
	return 
    function(self) 
      self
      :finishtweening()
      :zoom(0.75)
      :linear(3*frame)
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
      :linear(1*frame)
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
			:linear(1*frame)
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
        self:SetStateProperties({{Frame=0, Delay=6*frame}, {Frame=1, Delay=24*frame}});
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
--  Def.Sprite {
--    Texture=NOTESKIN:GetPath('Down', 'Press');
--    InitCommand=function(self) self:diffusealpha(0); end;
--    NoneCommand=pressoverlay(),
--    PressCommand=pressoverlay(),
--    LiftCommand=liftoverlay(),
--  };
};
return t;
