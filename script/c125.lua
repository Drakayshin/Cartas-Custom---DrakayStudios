--El Sello de Oricalcos Deuteros
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- 	0° Activación por condición
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetCondition(s.condition)
	c:RegisterEffect(e0)
	-- 	1° Limite de Invocación
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype,sumpos,targetp)return c:IsLocation(LOCATION_EXTRA)end)
	c:RegisterEffect(e1)
	-- 	2° Monstruo que controles ganan 500 ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 	3° No puede ser destruida por efectos de cartas
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--	4° No puede ser desterrada por efectos de cartas
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_REMOVE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(1,1)
	e4:SetValue(1)
	e4:SetTarget(function(e,c,tp,r) return c==e:GetHandler() and r==REASON_EFFECT end)
	c:RegisterEffect(e4)
	--	5° Tu adversario solo puede atacar al monstruo que tenga en ATK mas alto en tu Campo
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetCondition(s.atkcon)
	e5:SetValue(s.atlimit)
	c:RegisterEffect(e5)
	-- 	6° Ganar 500 LP por cada monstruo que controles
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_RECOVER)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCountLimit(1)
	e6:SetTarget(s.rectg)
	e6:SetOperation(s.recop)
	c:RegisterEffect(e6)
	-- Ganar LP
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_ADJUST)
	e7:SetRange(LOCATION_FZONE)
	e7:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e7:SetCountLimit(1)
	e7:SetOperation(s.op)
	c:RegisterEffect(e7)
	--clock lizard
	aux.addContinuousLizardCheck(c,LOCATION_FZONE)
end
s.listed_names={48179391,153}
	-- 	*EFECTO 0°
function s.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFieldCard(e:GetHandlerPlayer(),LOCATION_SZONE,5)
	return tc and tc:IsFaceup()
end
	-- 	*EFECTO 5°
function s.atkcon(e)
	return Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil,POS_FACEUP_ATTACK)
end
function s.atkfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<atk
end
function s.atlimit(e,c)
	return c:IsFaceup() and not Duel.IsExistingMatchingCard(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,c,c:GetAttack())
end
	-- 	*EFECTO 6°
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 end
	Duel.SetTargetPlayer(tp)
	local rec=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)*500
	Duel.SetTargetParam(rec)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local rec=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)*500
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Recover(p,rec,REASON_EFFECT)
end