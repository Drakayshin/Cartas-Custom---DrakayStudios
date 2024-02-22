-- Cisura Bestial
-- Cisura Bestial
local s,id=GetID()
function s.initial_effect(c)
	--Negar ataque y causar daño
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
    e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- Incrementar ATK por DEF y ganar LP
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
    e2:SetCountLimit(1,{id,2})
	e2:SetCondition(s.condition1)
	e2:SetTarget(s.target1)
	e2:SetOperation(s.activate1)
	c:RegisterEffect(e2)
end
s.listed_series={0x3e9}
    --Negar ataque y causar daño
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.GetAttacker():IsControler(tp)
		and eg:GetFirst():IsControler(tp) and eg:GetFirst():IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,eg:GetFirst():GetAttack())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if Duel.NegateAttack() and tc:IsRelateToBattle() then
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		Duel.Damage(p,tc:GetAttack(),REASON_EFFECT)
	end
end
    --Incrementar ATK por DEF y Ganar LP
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function s.filter(c)
	return c:HasNonZeroDefense() and c:IsSetCard(0x3e9)
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) and chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local def=tc:GetDefense()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and def>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetDefense())
		tc:RegisterEffect(e1)
		Duel.BreakEffect()
		Duel.Recover(tp,tc:GetDefense(),REASON_EFFECT)
	end
end