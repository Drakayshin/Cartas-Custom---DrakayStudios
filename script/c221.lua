--Centurión de Ojos Rojos
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--  0° Invocar de Modo Especial
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_LVCHANGE)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetRange(LOCATION_HAND)
	e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e0:SetCountLimit(1,{id,0})
	e0:SetCost(s.spcost)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
    c:RegisterEffect(e0)
    --  1° Buscar 1 monstruo "Ojos Rojos" e inmeditamente despúes Invocar por Fusión o Xyz
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
s.listed_series={SET_RED_EYES}
s.listed_names={CARD_REDEYES_B_DRAGON}
    --  *EFECTO 0°
function s.spcfilter(c)
	return c:IsSetCard(SET_RED_EYES) and c:IsMonster() and not c:IsCode(id) and c:IsAbleToGraveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.spcfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		--  *Aumentar su Nivel en 1
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD~RESET_TOFIELD)
        c:RegisterEffect(e1)
        --  *El nombre de esta carta se convierte en "Dragón Negro de Ojos Rojos"
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e2:SetCode(EFFECT_CHANGE_CODE)
        e2:SetValue(CARD_REDEYES_B_DRAGON)
        e2:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TOFIELD)
        c:RegisterEffect(e2)
	end
end
    --  *EFECTO 1°
function s.thfilter(c)
	return c:IsSetCard(SET_RED_EYES) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 or Duel.SendtoHand(g,nil,REASON_EFFECT)==0 or not g:GetFirst():IsLocation(LOCATION_HAND) then return end
	Duel.ConfirmCards(1-tp,g)
	--	*Invocar por Fusión o Xyz
	local params={fusfilter=aux.FilterBoolFunction(Card.ListsArchetypeAsMaterial,SET_RED_EYES)}
	local b1=Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil)
	if not (b1 or b2) then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,2)},{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
	end
	local op=e:GetLabel()
	if op==1 then
		--	*Invocar por Fusión
		local params={fusfilter=aux.FilterBoolFunction(Card.ListsArchetypeAsMaterial,SET_RED_EYES)}
		Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		--	*Invocar por Xyz
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
		if sc then
			Duel.XyzSummon(tp,sc)
		end
	end
end
function s.spfilter2(c)
	return c:IsSetCard(SET_RED_EYES) and c:IsXyzSummonable()
end