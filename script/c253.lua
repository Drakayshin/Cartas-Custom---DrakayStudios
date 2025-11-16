--Tajador Flauriga
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--  0° Aumentar ATK y ganar LP
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_RECOVER)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetHintTiming(TIMING_DAMAGE_STEP)
    e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetCondition(s.atkcon)
	e0:SetTarget(s.atkth)
	e0:SetOperation(s.atkop)
    c:RegisterEffect(e0)
    --  1° Multiple ataque este turno
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.matkth)
	e1:SetOperation(s.matkop)
	c:RegisterEffect(e1)
end
s.listed_series={0x3ee}
    --  *EFECTO 0°
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function s.atkfilter(c)
	return c:HasNonZeroDefense() and c:IsSetCard(0x3ee)
end
function s.atkth(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) and chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
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
		--	*Infligir daño de penetración
		tc:AddPiercing(RESETS_STANDARD_PHASE_END,e:GetHandler())
	end
end
    --  *EFECTO 1°
function s.cfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x3ee) or c:IsOriginalRace(RACE_WARRIOR|RACE_BEASTWARRIOR))
end
function s.matkth(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.matkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		--  *Puede atacar a todos los monstruos este turno
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ATTACK_ALL)
		e1:SetValue(1)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end