--Taumaturgo Oscuro
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- 0° Invocar Especial desde mano (Condición de campo vacío)
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e0:SetType(EFFECT_TYPE_QUICK_O)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    e0:SetRange(LOCATION_HAND)
    e0:SetCountLimit(1,{id,0})
    e0:SetCondition(s.spcon)
    e0:SetTarget(s.sptg0)
	e0:SetOperation(s.spop0)
    c:RegisterEffect(e0)
    -- 1° Invocar Guerrero o Lanzador de Conjuros Nivel 6 o menor desde tu Cementerio/Destierro
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id,1})
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)
	--A "Shark Drake" Xyz Monster that has this card as material gains this effect: Negate a Spell/Trap effect, and if you do, destroy that card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp and re:IsSpellTrapEffect() and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) end)
	e3:SetOperation(s.invamop)
    c:RegisterEffect(e3)
end
    --  *EFECTO 0°
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return  Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.sptg0(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.spop0(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1))then
		--  *Buscar 1 monstruo Guerrero o Lanzador de Conjuros de Nivel 6 o menor
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter0,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
	end
end
function s.thfilter0(c)
	return c:IsRace(RACE_WARRIOR|RACE_SPELLCASTER) and c:IsLevel(6) and not c:IsCode(id) and c:IsAbleToHand()
end
	-- *EFECTO 1°
function s.spfilter(c,e,tp)
    return c:IsRace(RACE_WARRIOR|RACE_SPELLCASTER) and c:IsLevelBelow(6) and not c:IsCode(id)
    and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,e:GetHandler(),e,tp) 
    and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT,nil)
    end
end
    --  *EFECTO 3°
function s.invamop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		--  *Inafectado por efectos activos del adversario por este turno
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,4))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		e1:SetValue(function(e,te) return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated() end)
		c:RegisterEffect(e1)
	end
end