--Matriarca Empíreo
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--  0°  Invocar de Modo Especial desde la mano
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,{id,0})
	e0:SetCost(s.spcost)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
    c:RegisterEffect(e0)
    --  1°  Reducir Nivel e Invocar de Modo Especial monstruos "Empíreo"
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_LVCHANGE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
end
s.listed_series={0x3eb}
    --  *Efecto 0°
function s.spfilter(c,tp)
	return c:IsAbleToRemoveAsCost() and c:IsSetCard(0x3eb) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil,tp) end
	e:GetHandler():RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)
end
    --  *Efecto 1°
function s.lvfilter(c,e,tp)
	return c:HasLevel() and c:IsSetCard(0x3eb) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.lvrescon(mustlv)
	return function(sg)
		local res,stop=aux.dncheck(sg)
		local sum=sg:GetSum(Card.GetLevel)
		return (res and sum==mustlv),(stop or sum>mustlv)
	end
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil,e,tp)
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft==0 or not c:HasLevel() or c:IsLevelBelow(2) then return false end
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		if c:IsLevelAbove(3) and aux.SelectUnselectGroup(g,e,tp,1,ft,s.lvrescon(2),0) then return true end
		if c:IsLevelAbove(5) and aux.SelectUnselectGroup(g,e,tp,1,ft,s.lvrescon(4),0) then return true end
		return false
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft==0 or c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or c:IsLevelBelow(2) then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.lvfilter),tp,LOCATION_HAND|LOCATION_DECK,0,nil,e,tp)
	local lvs={}
	if c:IsLevelAbove(3) and aux.SelectUnselectGroup(g,e,tp,1,ft,s.lvrescon(2),0) then table.insert(lvs,2) end
	if c:IsLevelAbove(5) and aux.SelectUnselectGroup(g,e,tp,1,ft,s.lvrescon(4),0) then table.insert(lvs,4) end
	if #lvs<1 then return end
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvs))
	if c:UpdateLevel(-lv)~=-lv then return end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,ft,s.lvrescon(lv),1,tp,HINTMSG_SPSUMMON,s.lvrescon(lv))
	if #tg>0 and Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)>0 then
		local fdg=Duel.GetOperatedGroup():Match(Card.IsFacedown,nil)
		if #fdg==0 then return end
		Duel.ConfirmCards(1-tp,fdg)
	end
end