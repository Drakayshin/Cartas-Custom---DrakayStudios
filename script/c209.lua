--Vasallaje del Señoroscuro
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--  0° Invocar de Modo Especial hasta 2 monstruos Hada de Oscuridad con diferentes nombres
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetCost(s.spcost)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
end
s.listed_names={SET_DARKLORD}
    --  *EFECTO 0°
function s.spcostfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_FIELD) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.spfilter1(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	--  *Invocar de Modo Especial hasta 2 monstruos
	local g=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_HAND|LOCATION_DECK,0,nil,e,tp)
	local ct=math.min(2,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if ct>0 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct=1 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 then
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	--  *Hasta el final proxímo turno solo puedes Invocar de Modo Especial monstruos de Oscuridad
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c)return not c:IsAttribute(ATTRIBUTE_DARK)end)
	e1:SetReset(RESET_PHASE|PHASE_END|RESET_SELF_TURN,Duel.IsTurnPlayer(tp) and 2 or 1)
	Duel.RegisterEffect(e1,tp)
end