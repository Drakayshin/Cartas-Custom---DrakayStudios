--Adlántere Terranigma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--  0° Cambiar efecto de la carta activada por tu adversario
	local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetCategory(CATEGORY_SUMMON)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_HAND)
	e0:SetHintTiming(TIMINGS_CHECK_MONSTER|TIMING_MAIN_END|TIMING_DAMAGE_STEP)
	e0:SetCountLimit(1,{id,1})
	e0:SetCondition(s.chcon)
	e0:SetTarget(s.chtg)
	e0:SetOperation(s.chop)
    c:RegisterEffect(e0)
    --	1° Regresa a la mano junto al monstruo que ataque a esta carta
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80344569,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,2})
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x3e7}
    -- 	*EFECTO 0°
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return rp==1-tp and (re:IsMonsterEffect() or rc:IsSpellTrap())
end
function s.sumfilter(c)
	return c:IsSetCard(0x3e7) and c:IsSummonable(true,nil)
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) 
	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	local g=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Group.CreateGroup()
		Duel.ChangeTargetCard(ev,g)
		Duel.ChangeChainOperation(ev,s.repop)
	end
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(1-tp,s.sumfilter,1-tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
	if g then
		Duel.Summon(1-tp,g,true,nil)
	end
end
    -- 	*EFCTO 1°
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and Duel.GetAttacker():IsAbleToHand() end
	local g=Group.FromCards(Duel.GetAttacker(),c)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>1 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end