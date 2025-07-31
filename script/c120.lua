--El Inmemorial Sello de Oricalcos
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- 	0° Activación con condicion
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetCondition(s.condition)
	c:RegisterEffect(e0)
	-- 	1° Monstruo que controles ganan 500 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	-- 	2° No puede ser destruida por efectos de cartas
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--	3° No puede ser desterrada por efectos de cartas
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_REMOVE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,1)
	e3:SetValue(1)
	e3:SetTarget(function(e,c,tp,r) return c==e:GetHandler() and r==REASON_EFFECT end)
	c:RegisterEffect(e3)
	-- 	4° Tu adversario solo puede atacar al monstruo que tenga en ATK mas alto en tu Campo
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCondition(s.atkcon)
	e4:SetValue(s.atlimit)
	c:RegisterEffect(e4)
	--	5° Esta carta es tratada como "El Sello de Oricalcos"
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_CHANGE_CODE)
	e5:SetRange(LOCATION_FZONE+LOCATION_GRAVE|LOCATION_DECK)
	e5:SetValue(48179391)
	c:RegisterEffect(e5)
end
s.listed_names={48179391,120}
	--	*EFECTO 0°
function s.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_EXTRA,0)==0
end
	--	*EFECTO 4°
function s.atkcon(e)
	return Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil,POS_FACEUP_ATTACK)
end
function s.atkfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<atk
end
function s.atlimit(e,c)
	return c:IsFaceup() and not Duel.IsExistingMatchingCard(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,c,c:GetAttack())
end