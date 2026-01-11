--Amoralidad del Señoroscuro
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--	0° Invocar de Modo Especial 1 monstruo "Señoroscuro" desde tu mano
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
end
s.listed_series={0xef}
	--	*EFecto 0°
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xef) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		--	*Enviar al cementerio 1 carta "Señoroscuro/a" desde tu Deck
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g2=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g2>0 then
			Duel.SendtoGrave(g2,REASON_EFFECT)
		end
		--	*No puedes Invocar de Modo Especial este turno, excepto monstruo Hada
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(e,c) return not c:IsOriginalRace(RACE_FAIRY) end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.tgfilter(c)
	return c:IsSetCard(0xef) and c:IsAbleToGrave()
end