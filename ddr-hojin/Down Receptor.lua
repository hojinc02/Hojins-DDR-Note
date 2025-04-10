local function pressreceptor()
	return function(self) self:finishtweening()
			self:zoom(0.85):sleep(0.017)
			:linear(0.07):zoom(1.0)
	end
end

local t = Def.ActorFrame {
	Def.Sprite {
		Texture=NOTESKIN:GetPath( '_down', 'Go Receptor' );
		InitCommand=function(self)
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
};
return t;
