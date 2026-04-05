--Released Curse
local s,id=GetID()
function s.initial_effect(c)
    --  0° Activar desde la mano
    local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.handcon)
	c:RegisterEffect(e0)
	--  1° destruir todas las cartas en el Campo y causar daño por cada una
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.damcon)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
    c:RegisterEffect(e1)
    --  2° Invocar de Modo Especial
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(0,TIMING_END_PHASE)
    e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) and Duel.IsMainPhase() end)
    e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.spth)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={0x3ee}
    --  *EFECTO 0°
function s.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end   
function s.handcon(e)
	return not Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
	--  *EFECTO 1°
function s.filter(c)
	return c:IsSetCard(0x3ee) and c:IsOriginalRace(RACE_PSYCHIC)
end	
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	local g=Duel.GetMatchingGroup(Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
function s.damfilter(c,tp)
	return c:GetOwner()==tp
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		local dg=Duel.GetOperatedGroup()
		local dam1=dg:FilterCount(s.damfilter,nil,tp)
		local dam2=dg:FilterCount(s.damfilter,nil,1-tp)
		Duel.Damage(tp,dam1*300,REASON_EFFECT)
		Duel.Damage(1-tp,dam2*300,REASON_EFFECT)
	end
end
    --  *EFECTO 2°
function s.filter1(c,e,tp)
	return c:IsSetCard(0x3ee) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.filter2(c,e,tp)
	return c:IsRace(RACE_WARRIOR|RACE_BEASTWARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spth(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_HAND|LOCATION_REMOVED,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND|LOCATION_REMOVED|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_HAND|LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g2>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end