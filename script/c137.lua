-- Mandrágora de Fobos
-- DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    -- Incrementar el Nivel de esta carta
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_LVCHANGE)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e0:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCountLimit(1)
	e0:SetCondition(function(e) return e:GetHandler():HasLevel() end)
	e0:SetOperation(s.lvup)
	c:RegisterEffect(e0)
	-- Reducir Nivel
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
end
    -- Incrementar el Nivel de esta carta
function s.lvup(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:HasLevel() then
		-- Aumentar por 1
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
    -- Reducir Nivel e Invocar
function s.lvrescon(mustlv)
	return function(sg)
		local res,stop=aux.dncheck(sg)
		local sum=sg:GetSum(Card.GetLevel)
		return (res and sum==mustlv),(stop or sum>mustlv)
	end
end
function s.lvfilter(c,e,tp)
	return c:HasLevel() and c:IsRace(RACE_INSECT|RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft==0 or not c:HasLevel() or c:IsLevelBelow(3) then return false end
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		if c:IsLevelAbove(4) and aux.SelectUnselectGroup(g,e,tp,1,ft,s.lvrescon(3),0) then return true end
		if c:IsLevelAbove(6) and aux.SelectUnselectGroup(g,e,tp,1,ft,s.lvrescon(5),0) then return true end
		return false
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft==0 or c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or c:IsLevelBelow(3) then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.lvfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	local lvs={}
	if c:IsLevelAbove(5) and aux.SelectUnselectGroup(g,e,tp,1,ft,s.lvrescon(3),0) then table.insert(lvs,3) end
	if c:IsLevelAbove(6) and aux.SelectUnselectGroup(g,e,tp,1,ft,s.lvrescon(5),0) then table.insert(lvs,5) end
	if #lvs<1 then return end
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvs))
	if c:UpdateLevel(-lv)~=-lv then return end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,ft,s.lvrescon(lv),1,tp,HINTMSG_SPSUMMON,s.lvrescon(lv))
	if #tg>0 and Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)>0 then

		-- Limite de Invocación de monstruos
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(e,c) return not c:IsRace(RACE_INSECT|RACE_PLANT) end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
