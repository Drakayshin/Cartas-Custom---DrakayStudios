--El Sello de Oricalcos Tritos
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- 	0° Activado con condicion no negable
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCondition(s.condition)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH+EFFECT_COUNT_CODE_DUEL)
	c:RegisterEffect(e0)
	-- 	1° Limite de Invocacion
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype,sumpos,targetp)return c:IsLocation(LOCATION_EXTRA)end)
	c:RegisterEffect(e1)
	-- 	2° Monstruo que controles ganan 500 ATK/DEF
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(500)
	c:RegisterEffect(e2)
    local e2a=e2:Clone()
	e2a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2a)
	-- 	3° No es afectada por efectos de otras cartas
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetValue(function(e,te) return te:GetOwner()~=e:GetOwner() end)
	c:RegisterEffect(e3)
	--	4° Tu adversario solo puede atacar al monstruo que tenga en ATK mas alto en tu Campo
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCondition(s.atkcon)
	e4:SetValue(s.atlimit)
	c:RegisterEffect(e4)
	-- 	5° Ganar 500 LP por cada monstruo que controles
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_RECOVER)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,{id,0})
	e5:SetTarget(s.rectg)
	e5:SetOperation(s.recop)
	c:RegisterEffect(e5)
	-- Efecto de ganar LP
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_ADJUST)
	e6:SetRange(LOCATION_FZONE)
	e6:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e6:SetOperation(s.op)
	c:RegisterEffect(e6)
    -- Recuperar del Cementerio 1 carta que mencione
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetCategory(CATEGORY_TOHAND)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_FZONE)
	e7:SetCountLimit(1,{id,1})
	e7:SetTarget(s.thtg)
	e7:SetOperation(s.thop)
	c:RegisterEffect(e7)
	--clock lizard
	aux.addContinuousLizardCheck(c,LOCATION_FZONE)
end
s.listed_names={48179391}
	-- 	*EFECTO 0°
function s.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFieldCard(e:GetHandlerPlayer(),LOCATION_SZONE,5)
	return tc and tc:IsFaceup() and tc:IsCode(125)
end
	-- 	*EFECTO 4°
function s.atkcon(e)
	return Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil,POS_FACEUP_ATTACK)
end
function s.atkfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<atk
end
function s.atlimit(e,c)
	return c:IsFaceup() and not Duel.IsExistingMatchingCard(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,c,c:GetAttack())
end
	-- 	*EFECTO 5°
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
	-- 	*EFECTO 6°
function s.thfilter(c)
	return (c:ListsCode(48179391)) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,3,aux.dncheck,1,tp,HINTMSG_ATOHAND)
	if #sg>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end