--Caballero de la Esperanza
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    -- 	*Solo 1 Boca arriba en tu campo
    c:SetUniqueOnField(1,0,id)
	-- 	*Invocación por Fusion de contacto
	c:EnableReviveLimit()
    Fusion.AddProcMixN(c,true,true,s.ffilter,3)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	-- 	0° Inafectado
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(function(e,te) return te:GetOwner()~=e:GetOwner() end)
	c:RegisterEffect(e0)
    -- 	1° Invocar 1 Monstruo Fusión
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.esptg)
	e1:SetOperation(s.espop)
	c:RegisterEffect(e1)
    -- 	*Regresa al Deck Extra al final de turno
	aux.EnableNeosReturn(c,nil,nil,nil)
end
s.listed_names={10000060,id} 
s.listed_series={SET_DARK_MAGICIAN}
s.material_setcode={SET_LEGENDARY_DRAGON}
	--	*Filtro de materiales
function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsSetCard(SET_LEGENDARY_DRAGON,fc,0,tp) and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,0,tp),fc,0,tp))
end
function s.fusfilter(c,code,fc,sumtype,tp)
	return c:IsSummonCode(fc,0,tp,code) and not c:IsHasEffect(511002961)
end
	-- 	*Fusion por contacto
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
end
function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
    -- 	*EFECTO 1°
function s.spfilter(c,e,tp)
    return c:IsType(TYPE_FUSION) and (c.material_race or c.material_trap or c:ListsCode(1784686)) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.esptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.espop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,e:GetHandler())
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end