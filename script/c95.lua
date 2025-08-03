--Ebanor, Hidalgo Terranigma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- 	0° No puede ser Invocado de Modo Especial
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(e0)
	-- 	1° Invocar de Modo Normal 1 monstruo "Terranigma"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) and Duel.IsMainPhase() end)
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
    c:RegisterEffect(e1)
    -- 	2° Negar efectos y reducir ATK a 0
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,2})
	e2:SetCondition(s.con)
	e2:SetTarget(s.diszatg)
    e2:SetOperation(s.diszaop)
    c:RegisterEffect(e2)
end
s.listed_series={0x3e7}
    -- 	*EFECTO 1°
function s.sumfilter(c)
	return c:IsSetCard(0x3e7) and c:IsSummonable(true,nil)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,g,1,tp,0)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end
	--	*EFECTO 2°
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3e7) and not c:IsCode(id)
end
function s.con(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.diszafilter(c)
	return c:IsFaceup() or c:HasNonZeroAttack() and c:IsNegatableMonster()
end
function s.diszatg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.diszafilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
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