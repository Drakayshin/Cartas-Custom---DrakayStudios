--El Sello de Oricalcos Deuteros
--El Sello de Oricalcos Deuteros
local s,id=GetID()
function s.initial_effect(c)
	--Activate con condicion
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	--spsummon limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.sumlimit)
	c:RegisterEffect(e2)
	-- +500  ATK
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetValue(500)
	c:RegisterEffect(e3)
	-- Indestrucible/Indesterrable
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_REMOVE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(1,1)
	e5:SetValue(1)
	e5:SetTarget(function(e,c,tp,r) return c==e:GetHandler() and r==REASON_EFFECT end)
	c:RegisterEffect(e5)
	--ATKs limit
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTargetRange(0,LOCATION_MZONE)
	e6:SetCondition(s.atkcon)
	e6:SetValue(s.atlimit)
	c:RegisterEffect(e6)
	--Recover LP
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,0))
	e7:SetCategory(CATEGORY_RECOVER)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetRange(LOCATION_SZONE)
	e7:SetCountLimit(1)
	e7:SetTarget(s.rectg)
	e7:SetOperation(s.recop)
	c:RegisterEffect(e7)
	--Gain effect LP
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_ADJUST)
	e8:SetRange(LOCATION_SZONE)
	e8:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e8:SetCountLimit(1)
	e8:SetOperation(s.op)
	c:RegisterEffect(e8)
	--clock lizard
	aux.addContinuousLizardCheck(c,LOCATION_FZONE)
end
s.listed_names={48179391,153}
function s.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFieldCard(e:GetHandlerPlayer(),LOCATION_SZONE,5)
	return tc and tc:IsFaceup() and {tc:IsCode(48179391) or tc:IsCode(153)}
end
function s.negdcon(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject() and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.negdop(e)
	Duel.ResetFlagEffect(e:GetHandlerPlayer(),id)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA)
end
-- Atk limit froo opponent
function s.atkcon(e)
	return Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil,POS_FACEUP_ATTACK)
end
function s.atkfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<atk
end
function s.atlimit(e,c)
	return c:IsFaceup() and not Duel.IsExistingMatchingCard(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,c,c:GetAttack())
end
-- Gain LP
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