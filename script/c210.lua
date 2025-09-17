--Retorno de los Señoresocuros
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  0° Invocar por Fusión 1 Monstruo Fusión de Oscuridad
	local e0=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),nil,s.fextra,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,s.extratg)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e0:SetCost(Cost.PayLP(1/2))
    c:RegisterEffect(e0)
    --  1° Invocar por Enlace usando un monstruo Invocado por esta carta
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCost(Cost.PayLP(1/2))
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_DARKLORD}
    --  *EFECTO 0°
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.fextra(e,tp,mg)
	if Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA) then
		local eg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_DECK,0,nil)
		if eg and #eg>0 then
			return eg,s.fcheck
		end
	end
	return nil
end
function s.exfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_DARKLORD) and c:IsAbleToGrave()
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end 
    --  *EFECTO 1°
function s.spfilter2(c,mc,fg)
	return c:IsRace(RACE_FAIRY) and c:IsLinkBelow(3) and c:IsLinkSummonable(mc,fg+mc)
end
function s.spfilter(c,e,tp,fg)
	return c:IsSetCard(SET_DARKLORD) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,c,fg)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local fg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCanBeLinkMaterial),tp,LOCATION_MZONE,0,nil)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp,fg)
		and Duel.IsPlayerCanSpecialSummonCount(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND|LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local fg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCanBeLinkMaterial),tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp,fg)
	local tc=g:GetFirst()
	if not tc or not Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		return false
	end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	tc:RegisterEffect(e2)
	Duel.SpecialSummonComplete()
	local tg=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,tc,fg)
	if #tg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=tg:Select(tp,1,1,nil)
        local sc=sg:GetFirst()
        --  *Gana 1000 ATK
        local e3=Effect.CreateEffect(c)
        e3:SetDescription(aux.Stringid(id,2))
		e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_UPDATE_ATTACK)
		e3:SetValue(1000)
        sc:RegisterEffect(e3)
		Duel.LinkSummon(tp,sc,tc,nil)
	end
end