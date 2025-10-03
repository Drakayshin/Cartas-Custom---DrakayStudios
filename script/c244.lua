--Sirius, Campeador Flauriga
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  *Invocación por Xyz
    c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,4,3,nil,nil,Xyz.InfiniteMats)
end