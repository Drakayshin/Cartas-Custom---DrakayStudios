--Sirius, El Renacido Flauriga
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  *Debe ser Invocado por Xyz
    c:AddMustBeXyzSummoned()
    --  *Invocación por Xyz y, formal Altervativa de Invocación en Xyz
    c:EnableReviveLimit()
    Xyz.AddProcedure(c,nil,5,3,s.ovfilter,aux.Stringid(id,0))
    --  0° Negar efectos en el Campo y reducir ATK si es un monstruo
    local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e0:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
    e0:SetCost(Cost.DetachFromSelf(2))
	e0:SetCondition(s.discon)
	e0:SetTarget(s.diszatg)
    e0:SetOperation(s.diszaop)
    c:RegisterEffect(e0)
    --  1° Inafectado por efectos activos de cartas de tu adversario
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(function(e) return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0x3ee) and c:IsType(TYPE_XYZ) end)
    e1:SetValue(function(e,te) return (te:IsMonsterEffect() or te:IsSpellTrapEffect()) and te:IsActivated() and te:GetOwnerPlayer()==1-e:GetHandlerPlayer()  end)
    c:RegisterEffect(e1)
    --  2° Alterar ATK/DEF
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e) return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0x3ee) and c:IsType(TYPE_XYZ) and Duel.IsBattlePhase() end)
	e2:SetValue(2200)
	c:RegisterEffect(e2)
    local e2a=e2:Clone()
    e2a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2a)
end
s.listed_series={0x3ee}
    --  *Filtro de materiales
function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsType(TYPE_XYZ,xyzc,SUMMON_TYPE_XYZ,tp) and c:IsOriginalRace(RACE_BEASTWARRIOR)and c:IsRankBelow(4)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep==1-tp and loc&LOCATION_ONFIELD>0
end
function s.diszafilter(c)
	return c:IsFaceup() or c:HasNonZeroAttack() and c:IsNegatableMonster()
end
function s.diszatg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() end
    if chk==0 then return c:GetFlagEffect(id+1)==0 and Duel.IsExistingMatchingCard(s.diszafilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	c:RegisterFlagEffect(id+1,RESET_CHAIN,0,1)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,LOCATION_ONFIELD)
end
function s.diszaop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectMatchingCard(tp,s.diszafilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.HintSelection(g)
	local tc=g:GetFirst()
	if tc then
		tc:NegateEffects(c)
		if tc:IsMonster() then
		--	*Reducir ATK si es un monstruo
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		end
	end
end