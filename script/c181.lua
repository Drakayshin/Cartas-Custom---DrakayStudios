--Represalia de Oricalcos
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    -- Daño a los LP del Adversario
    local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_DAMAGE)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_DRAW_PHASE)
    e0:SetCountLimit(1,id)
    e0:SetCondition(s.condition)
	e0:SetTarget(s.dmtarget)
	e0:SetOperation(s.dmact)
	c:RegisterEffect(e0)
	-- Ganar LP
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
    -- Colocar esta carta, regresando otra
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.setcond)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.listed_names={id,48179391,125,130}
    -- Condición de activación
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)>Duel.GetLP(1-tp)
end
    -- Causar daño
function s.dmtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)~=0 end
	Duel.SetTargetPlayer(1-tp)
	local dam=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)*500
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.dmact(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local dam=Duel.GetFieldGroupCount(p,0,LOCATION_MZONE)*500
	Duel.Damage(p,dam,REASON_EFFECT)
end
    -- Ganar LP
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)>0 end
	local rec=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)*500
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(rec)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local rec=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)*500
	Duel.Recover(p,rec,REASON_EFFECT)
end
    -- Colocar esta carta y regresar otra
function s.setcond(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function s.setfilter(c)
	return c:IsFaceup() and c:ListsCode(48179391) and c:IsAbleToHand() and not c:IsLocation(LOCATION_FZONE)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.setfilter(chkc) end
	if chk==0 then return e:GetHandler():IsSSetable()
		and Duel.IsExistingTarget(s.setfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsSSetable()
		and Duel.SSet(tp,c)~=0 and tc and tc:IsRelateToEffect(e)
		and tc:ListsCode(48179391) and tc:IsLocation(LOCATION_SZONE) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end