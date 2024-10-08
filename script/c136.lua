--Samedineo Bestial
--DrakayStudio
local s,id=GetID()
function s.initial_effect(c)
	-- Nivel para Invocacion Xyz
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_XYZ_LEVEL)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(s.xyzlv)
	c:RegisterEffect(e0)
	-- Material sustituto
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e1:SetCondition(s.subcon)
	e1:SetValue(s.subval)
	c:RegisterEffect(e1)
    -- Invocar de Modo Especial desde la mano
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={0x3e9}
    -- Nivel tratado como
function s.xyzlv(e,c,rc)
    return 3,7,e:GetHandler():GetLevel()
end
	-- Material sustituto
function s.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)
end
	-- Monstruo especifico
function s.subval(e,c)
	return c:IsSetCard(0x3e9)
end
    -- Invocar desde la mano (efecto de activacion)
function s.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x3e9)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
    -- Proceso de Invocacion adicional por esta invocacion
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.spfilter(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,1,2,nil)
			local tc=sg:GetFirst()
			if tc then
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)                
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CHANGE_DAMAGE)
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e1:SetTargetRange(0,1)
				e1:SetValue(s.damval)
				e1:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e1,tp)
				aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,1),nil)
			end
		end
	end
end
function s.damval(e,re,val,r,rp,rc)
	return math.floor(val/2)
end