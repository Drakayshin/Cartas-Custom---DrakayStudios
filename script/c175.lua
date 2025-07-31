--Coalición Cibernética
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- 	0° Invocar por Fusión 1 monstruo "Ciber"
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetCondition(s.condition)
	e0:SetCost(s.cost)
	e0:SetTarget(s.target)
	e0:SetOperation(s.activate)
	c:RegisterEffect(e0)
    -- 	1° Invocar por Fusión 1 Monstruo de Fusión Máquina
    local e1=Fusion.CreateSummonEff(c,s.ffilter,Fusion.OnFieldMat(Card.IsAbleToRemove),s.fextra,Fusion.BanishMaterial,nil,s.stage2,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_LEAVE_FIELD)
    e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCost(aux.bfgcost)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)
end
	-- 	*EFECTO 0°
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,3) and 
	Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>3 end
	Duel.DiscardDeck(tp,3,REASON_COST)
end
function s.filter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(147) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)~=0 then
		--	*No puede atacar directamente
        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
        tc:CompleteProcedure()
	end
end
    -- 	*EFECTO 1°
function s.cfilter(c,tp)
	return c:IsType(TYPE_FUSION) and (c:IsRace(RACE_MACHINE) or c:IsRace(RACE_CYBERSE)) 
	and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(s.cfilter,1,e:GetHandler(),tp)
end
function s.ffilter(c)
	return c:IsRace(RACE_MACHINE)
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_MZONE+LOCATION_GRAVE)
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==1 then
		-- No puede atacar este turno
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3207)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end