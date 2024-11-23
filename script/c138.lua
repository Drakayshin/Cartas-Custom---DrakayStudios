--Kusubana no Fobos
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    -- Limite de ser Invocado 1 vez por turno
	c:SetSPSummonOnce(id)
    -- Tipo de carta por Tipo de Invocación
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_HAND)
	e0:SetCode(EFFECT_ADD_TYPE)
	e0:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e0)
	local e1=e0:Clone()
	e1:SetCode(EFFECT_REMOVE_TYPE)
	e1:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e1)
	-- Destrucción por Tipo de Invocación
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
    -- Invocar de Modo Especial
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
    -- Destrucción por Tipo de Invocación
function s.filter(c,atk)
	return c:IsFaceup() and (c:IsAttackBelow(atk) or c:IsDefenseBelow(atk))
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,c:GetDefense(),c:GetAttack()) end
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,c:GetDefense(),c:GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,c:GetDefense(),c:GetAttack())
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		Duel.BreakEffect()
	end
end
    -- Invocar de Modo Especial
function s.filter1(c)
	return (c:IsCode(id) and c:IsFaceup())
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer() and not Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_ONFIELD,0,1,nil) 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if e:GetHandler():IsRelateToEffect(e)
		and not Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_ONFIELD,0,1,nil)then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
        -- Barajalo a tu Deck cuando deje el Campo
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetDescription(3900)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
        e2:SetValue(LOCATION_DECKSHF)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e2)
	end
end