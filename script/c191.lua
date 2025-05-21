--Designio del duelista
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
    -- Activar desde la mano
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetCondition(function(e) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_ONFIELD)>0 end)
	c:RegisterEffect(e0)
    -- Cadena limitada
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_FZONE)
    e1:SetOperation(s.chainop)
    c:RegisterEffect(e1)
	-- Activación y poder robar
	local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1,{id,1})
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
    -- Reducir daño a la mitad en un turno
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(EFFECT_CHANGE_DAMAGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function()return Duel.IsMainPhase() end)
	e3:SetCost(s.SetCost)
	e3:SetOperation(s.SetOperation)
	c:RegisterEffect(e3)
end
    -- Robar
function s.cfilter(c)
	return c:IsRace(RACE_DIVINE) and not c:IsPublic()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local sg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil)
	if #sg>0 and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local g=Group.CreateGroup()
		repeat
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
			local tc=sg:Select(tp,1,1,nil):GetFirst()
			g:AddCard(tc)
			sg:Remove(Card.IsCode,nil,tc:GetCode())
		until #sg==0 or dt==#g or not Duel.SelectYesNo(tp,210)	
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		local ct=#g
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
end
    -- Cadena limitada
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRace(RACE_DIVINE) and re:GetHandler():IsLevel(12) then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return tp==rp
end
    -- Reducir daño a la mitad
function s.SetCost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED) end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.SetOperation(e,tp,eg,ep,ev,re,r,rp)
	-- Reducir daño a la mitad
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.damval)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.damval(e,re,val,r,rp,rc)
	return math.floor(val/2)
end