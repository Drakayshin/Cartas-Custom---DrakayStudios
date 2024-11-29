--Ente de Disformidad 
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- Solo 1 Boca arriba en tu campo
    c:SetUniqueOnField(1,0,id)
    c:EnableCounterPermit(COUNTER_SPELL)
	c:SetCounterLimit(COUNTER_SPELL,5)
    -- Activate/Buscar 1 carta
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetTarget(s.thtg)
	e0:SetOperation(s.thop)
	c:RegisterEffect(e0)
    -- Limite de ataque directos
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.atktarget)
	c:RegisterEffect(e1)
	-- Reducir ATK por contador
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_ONFIELD)
	e2:SetTarget(s.iatarget)
	e2:SetValue(s.iavalue)
	c:RegisterEffect(e2)
	-- Colocar contadores
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.condition)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
end
	-- Buscar 1 carta
function s.thfilter(c)
	return c:IsLevelAbove(9) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
    -- Limite de ataques directos
function s.atktarget(e,c)
	return c:IsAttackBelow(2000)
end
	-- Reducir ATK por contador
function s.iatarget(e,c)
	return c:IsMonster()
end
function s.iavalue(e,c)
	return e:GetHandler():GetCounter(COUNTER_SPELL)*-400
end
	-- Colocar contadores
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(COUNTER_SPELL,1)
end