--Avatar Dis Pater
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--  *Proceso de Fusion 1°
	local f0=Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_DOGMATIKA),s.ffilter)[1]
	f0:SetDescription(aux.Stringid(id,0))
	-- *Proceso de Fusion de multipes materiales 2°
    local f1=Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_DESPIA),1,s.ffilter,1)[1]
    f1:SetDescription(aux.Stringid(id,1))
    --  Efecto 0: Colocar 1 Carta de Mágica/ de Trampa desde tu Deck
    local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,2))
	e0:SetCategory(CATEGORY_SET)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCountLimit(1,{id,0})
	e0:SetTarget(s.settg)
	e0:SetOperation(s.setop)
    c:RegisterEffect(e0)
    --  Efecto 1: Invocar de Modo Especial (Esto es tratado como una Invocación por Fusión)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,3))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(function(e) return e:GetHandler():IsFusionSummoned() end)
    e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_DOGMATIKA,SET_DESPIA,SET_BRANDED}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK,fc,sumtype,tp)
end
    --  *EFECTO 0°
function s.setfilter(c)
	return (c:IsSetCard(SET_DOGMATIKA) or c:IsSetCard(SET_BRANDED)) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
    --  *EFECTO 1°
function s.cfilter(c)
	return c:IsRitualSpell() and c:IsDiscardable(REASON_EFFECT)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_DOGMATIKA) and c:IsRitualMonster() 
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false,POS_FACEUP)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
        and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardHand(tp,s.cfilter,1,1,REASON_EFFECT+REASON_DISCARD)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
		if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP) then
			tc:CompleteProcedure()
		end
	end
end