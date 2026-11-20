--Magia de Subida de Rango Ascensión Barian
--DrakayStudios
Duel.EnableUnofficialProc(PROC_CANNOT_BATTLE_INDES)
local s,id=GetID()
function s.initial_effect(c)
	--  Efecto 0: Invocación de escalado
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e0:SetHintTiming(0,TIMING_MAIN_END)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetTarget(s.target)
	e0:SetOperation(s.activate)
	c:RegisterEffect(e0)
end
s.listed_series={SET_NUMBER_C,SET_CXYZ}
function s.filter1(c,e,tp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return (#pg<=0 or (#pg==1 and pg:IsContains(c))) and c:IsFaceup() and  c:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRace(),pg)
end
function s.filter2(c,e,tp,mc,rc,pg)
	if c.rum_limit and not c.rum_limit(mc,e) then return false end
	return mc:IsType(TYPE_XYZ,c,SUMMON_TYPE_XYZ,tp) and c:IsRace(rc) and c:IsRankAbove(1) and (c:IsSetCard({SET_NUMBER_C,SET_CXYZ}))
        and mc:IsCanBeXyzMaterial(c,tp) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(tc),tp,nil,nil,REASON_XYZ)
	if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) or #pg>1 or (#pg==1 and not pg:IsContains(tc)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRace(),pg)
	local sc=g:GetFirst()
	if sc then
		sc:SetMaterial(tc)
		Duel.Overlay(sc,tc)
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
        sc:CompleteProcedure()
        local c=e:GetHandler()
        --  *Negar efecto de indestructible en batalla
        local e0=Effect.CreateEffect(c)
        e0:SetType(EFFECT_TYPE_FIELD)
        e0:SetCode(EFFECT_CANNOT_BATTLE_INDES)
        e0:SetRange(LOCATION_MZONE)
        e0:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
        e0:SetValue(s.batval)
        e0:SetReset(RESET_EVENT|RESETS_STANDARD)
        sc:RegisterEffect(e0)
        --  *Sus efectos no pueden ser negados
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        sc:RegisterEffect(e1,true)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_CANNOT_DISEFFECT)
        sc:RegisterEffect(e2,true)
	end
end
function s.batval(e,re,c)
	return (re:GetCode()==EFFECT_INDESTRUCTABLE_BATTLE or re:GetCode()==EFFECT_INDESTRUCTABLE_COUNT)
		and (not re:IsHasType(EFFECT_TYPE_SINGLE) or re:GetOwner()==c)
		and (not re:IsHasType(EFFECT_TYPE_FIELD) or re:GetActivateLocation()>0)
		and not re:GetHandler():IsHasEffect(EFFECT_CANNOT_DISABLE)
		and not re:IsHasProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
end