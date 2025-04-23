--Atronador Cetrino
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    -- Prevencion de colocar
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetRange(LOCATION_HAND)	
	e0:SetCountLimit(1,id)
    e0:SetCost(Cost.SelfDiscard)
	e0:SetCondition(s.condition)
    e0:SetOperation(s.operation)
	e0:SetTargetRange(1,0)
	c:RegisterEffect(e0)
	-- Invocar de Modo Especial
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    	--Check for single Set
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SSET)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED) then
		local g=eg:Filter(Card.IsPreviousLocation,nil,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
		for tc in aux.Next(g) do
			if tc:GetFlagEffect(id)==0 then
				tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET,0,1)
				Duel.RegisterFlagEffect(rp,id,RESET_PHASE+PHASE_END,0,1)
			end
		end
	end
end
	-- Prevencion de colocar
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase() < PHASE_END
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e0:SetCode(EFFECT_CANNOT_SSET)
	e0:SetCountLimit(1,{id,1})
	e0:SetCondition(s.setcon1)
    e0:SetTarget(s.settg)
    e0:SetTargetRange(1,0)
	e0:SetReset(RESET_PHASE+PHASE_END)
	e0:SetLabelObject(e0)
	Duel.RegisterEffect(e0,tp)
    local e1=e0:Clone()
	e1:SetTargetRange(0,1)
	e1:SetCondition(s.setcon2)
	Duel.RegisterEffect(e1,tp)
end
function s.setcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0
end
function s.setcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(1-e:GetHandlerPlayer(),id)>0
end
function s.settg(e,c)
	return c:IsLocation(LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
	-- Invocar de Modo Especial
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and re:IsActiveType(TYPE_SPELL|TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
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