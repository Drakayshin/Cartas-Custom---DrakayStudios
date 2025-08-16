--Arcabastión Terranigma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  0° Activar y limitar activación de otras Cartas Mágicas de Campo
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetOperation(s.limop)
	c:RegisterEffect(e0)
    --  1° No puedes Invocar de Modo Especial, excepto monstruo "Terranigma"
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not c:IsSetCard(0x3e7) end)
    c:RegisterEffect(e1)
    --  2° Gana LP igual al ATK de uno o mas monstruos Invocados de Modo Especial de tu adversario
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.reccon1)
	e2:SetOperation(s.recop1)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.regcon)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EVENT_CHAIN_SOLVED)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(s.reccon2)
	e4:SetOperation(s.recop2)
	c:RegisterEffect(e4)
    e3:SetLabelObject(e4)
    --  3° Invocar de Modo Normal 1 monstruo "Terranigma"
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SUMMON)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e4:SetCondition(function()return Duel.IsMainPhase() end)
	e4:SetCountLimit(1)
	e4:SetTarget(s.sumtg)
	e4:SetOperation(s.sumop)
	c:RegisterEffect(e4)
    --  4° Añadir a la mano 1 monstruo "Terranigma" desde tu Deck, con nombre diferente al de tus monstruos en tu Cementerio
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e6:SetType(EFFECT_TYPE_QUICK_O)
    e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCountLimit(1)
	e6:SetCost(Cost.PayLP(1200))
	e6:SetOperation(s.thop)
	c:RegisterEffect(e6)
    --  5° Activar desde la mano
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,2))
	e7:SetType(EFFECT_TYPE_QUICK_O)
    e7:SetCode(EVENT_FREE_CHAIN)
    e7:SetRange(LOCATION_HAND)
    e7:SetCountLimit(1)
    e7:SetCondition(s.accon)
    e7:SetTarget(s.actg)
	e7:SetOperation(s.acop)
	c:RegisterEffect(e7)
end
s.listed_series={0x3e7}
s.listed_names={id}
    --  *EFECTO 0°
function s.limop(e,tp,eg,ep,ev,re,r,rp)
    --  *Cartas Mágicas de Campo no pueden ser activadas este turno
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,1)
    e1:SetValue(s.efilter)
    e1:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.efilter(e,re,tp)
	return re:GetHandler():IsType(TYPE_FIELD) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
    --  *EFECTO 2°
function s.rvfilter(c,sp)
	if c:IsLocation(LOCATION_MZONE) then
		return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:GetSummonPlayer()==sp and c:IsSummonLocation(LOCATION_EXTRA)
	else
		return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetSummonPlayer()==sp and c:IsSummonLocation(LOCATION_EXTRA)
	end
end
function s.reccon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.rvfilter,1,nil,1-tp)
		and (not re or (not re:IsHasType(EFFECT_TYPE_ACTIONS) or re:IsHasType(EFFECT_TYPE_CONTINUOUS)))
end
function s.sum(c)
	if c:IsLocation(LOCATION_MZONE) then
		return c:GetAttack()
	else
		return c:GetPreviousAttackOnField()
	end
end
function s.recop1(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.rvfilter,nil,1-tp)
	if #g>0 then
		local sum=g:GetSum(s.sum)
		Duel.Hint(HINT_CARD,0,id)
		if Duel.Recover(tp,sum,REASON_EFFECT)~=0 then 
			Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		end
	end
end
    --  *EFECTO 2° (4° Fase de Invocación de Modo Especial)
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.rvfilter,1,nil,1-tp)
		and re:IsHasType(EFFECT_TYPE_ACTIONS) and not re:IsHasType(EFFECT_TYPE_CONTINUOUS)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.rvfilter,nil,1-tp)
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	e:GetLabelObject():SetLabel(g:GetSum(s.sum)+e:GetLabelObject():GetLabel())
end
    --  *EFECTO 2° (5° Registro de ganar LP en base al ATK)
function s.reccon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0 
end
function s.recop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.ResetFlagEffect(tp,id)
	local rec=e:GetLabel()
	e:SetLabel(0)
	Duel.Hint(HINT_CARD,0,id)
	if Duel.Recover(tp,rec,REASON_EFFECT)~=0 then
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
	end
end
    --  *EFECTO 3°
function s.sumfilter(c)
	return c:IsSetCard(0x3e7) and c:IsSummonable(true,nil)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,g,1,tp,0)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end
    --  *EFECTO 4°
function s.cfilter(c)
	return c:IsSpecialSummoned() and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and ep==1-tp and Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c then
		Duel.MoveToField(c,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
        Duel.RaiseEvent(c,EVENT_CHAIN_SOLVED,c:GetActivateEffect(),0,tp,tp,Duel.GetCurrentChain())
        --  *Cartas Mágicas de Campo no pueden ser activadas este turno
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_ACTIVATE)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,1)
        e1:SetValue(s.efilter)
        e1:SetReset(RESET_PHASE|PHASE_END)
        Duel.RegisterEffect(e1,tp)
	end
end
    --  *EFECTO 5°
function s.thfilter(c,tp)
	return c:IsSetCard(0x3e7) and c:IsMonster() and c:IsAbleToHand() 
	and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,tp)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end