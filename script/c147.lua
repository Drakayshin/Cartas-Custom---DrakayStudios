--Cisura Bestial
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- Negar ataque y causar daño
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_DAMAGE)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_BE_BATTLE_TARGET)
    e0:SetCountLimit(1,{id,1})
	e0:SetCondition(s.nacon)
	e0:SetTarget(s.natg)
	e0:SetOperation(s.naop)
	c:RegisterEffect(e0)
	-- Incrementar ATK por DEF y ganar LP
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
    e1:SetCountLimit(1,{id,2})
	e1:SetCondition(s.condition1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.activate1)
	c:RegisterEffect(e1)
end
s.listed_series={0x3e9}
    -- Negar ataque y causar daño
function s.nacon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.GetAttacker():IsControler(tp)
		and eg:GetFirst():IsControler(tp) and eg:GetFirst():IsFaceup()
end
function s.natg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetAttacker():IsOnField() end
	local dam=Duel.GetAttacker():GetAttack()
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.naop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	if Duel.NegateAttack() then
		Duel.Damage(1-tp,a:GetAttack(),REASON_EFFECT)
	end
end
    -- Incrementar ATK por DEF y Ganar LP
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