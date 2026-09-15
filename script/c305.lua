--Guilletosaurus LV7
--DrakayStudios - Evento 12/09/2026 - Hernán Fernández
local s,id=GetID()
function s.initial_effect(c)
    --  Efecto 0: Atacar a cada monstruo en Posición de Defensa
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ATTACK_ALL)
	e0:SetValue(function(e,c) return c:IsPosition(POS_DEFENSE) end)
	c:RegisterEffect(e0)
	--  Efecto 1: Infligir daño de penetración
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
end
s.listed_names={304}
s.LVnum=7