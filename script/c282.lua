--Maldición del Azulejo
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  Efecto 0: ATK/DEF x monstruos de Oscuridad en el Campo o Cementerios
    local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_SINGLE)
	e0a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0a:SetCode(EFFECT_UPDATE_ATTACK)
    e0a:SetRange(LOCATION_MZONE)
    e0a:SetCondition(function(e) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,100),0,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,1,nil) end)
	e0a:SetValue(function(e,c) return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_DARK),0,LOCATION_MZONE,LOCATION_MZONE,nil)*500 end)
	c:RegisterEffect(e0a)
	local e0b=e0a:Clone()
	e0b:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e0b)
    --  Efecto 1: Invocar de Modo Especial a esta carta desde la mano o destierro
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND|LOCATION_REMOVED)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_BATTLE_END|TIMINGS_CHECK_MONSTER_E)
    e1:SetCountLimit(1,{id,0})
    e1:SetCondition(function(_,tp) return not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --  Efecto 2: Buscar 1 carta y luego desterrar 1 carta en tu mano o Campo
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={100}
    --  *EFECTO 1°
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
    and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
    local c=e:GetHandler()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
    --  *EFECTO 2°
function s.thfilter(c)
	return c:ListsCode(100) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanRemove(tp) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil)
		if #rg>0 then
			Duel.BreakEffect()
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
function s.rmfilter(c)
	return c:IsMonster() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsAbleToRemove()
end