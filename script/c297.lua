--
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--  ¨*Invocación por Sincronía
	Synchro.AddProcedure(c,nil,1,99,aux.FilterBoolFunctionEx(Card.Iscode,290),1,1)
	--  Efecto 0: El nombre de esta carta se convierte en "Yacard, Héroe de la Fábula" en Campo
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetValue(291)
    c:RegisterEffect(e0)
    --  Efecto 1:
end
s.listed_names={290}
    --  *EFECTO 1°
