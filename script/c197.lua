--Einna, Doncella del Delirio
--DrakayStudios
--Codigo a petición de Hugo Castro
local s,id=GetID()
function s.initial_effect(c)
    -- Invocación 1 vez por turno
	c:SetSPSummonOnce(id)
	-- Invocar de Modo Especial
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
	e0:SetCondition(s.delicon)
	c:RegisterEffect(e0)
    -- ATK UP
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3ed))
	e1:SetValue(500)
	e1:SetCondition(s.delicon)
	c:RegisterEffect(e1)
    -- Indestructible por batalla
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(s.delicon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
s.listed_series={0x3ed}
s.listed_names={194}
    --Condicio por efecto
function s.delicon(e)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,194),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end