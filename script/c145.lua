--Evocador Áureo
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- 	*Sacrificio entero por la Invocación por Ritual de un Nivel 10 o menor
	Ritual.AddWholeLevelTribute(c,function(rit_c) return rit_c:IsLevelBelow(10) end)
	-- 	0° añadir a tu mano 1 Monstruo Ritual o Mágica de Ritual, desde tu Deck o Cementerio
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCode(EVENT_SUMMON_SUCCESS)
	e0:SetCountLimit(1,{id,0})
	e0:SetTarget(s.thtg)
	e0:SetOperation(s.thop)
	c:RegisterEffect(e0)
	local e0a=e0:Clone()
	e0a:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e0a)
	local e0b=e0:Clone()
	e0b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e0b)
    -- 	1° Invocar a ser Sacrificada
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_RELEASE)
    e1:SetRange(LOCATION_GRAVE|LOCATION_REMOVED)
    e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
	-- 	*EFECTO 0°
function s.filter(c)
	return c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
    -- 	*EFECTO 1°
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end