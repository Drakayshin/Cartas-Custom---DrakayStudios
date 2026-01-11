--Laios, El Prominente Flauriga
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  *Invocación por Sincronía
    c:EnableReviveLimit()
    Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x3ee),1,1,Synchro.NonTuner(nil),1,99)
    --  0° Ganar ATK igual a uno de sus Materiales de Sincronía (monstruo Cantante)
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.valcon)
	e0:SetOperation(s.valop)
	c:RegisterEffect(e0)
    --  1° Devolver a la mano, 1 carta en el Campo
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.rmcost)
	e1:SetCondition(s.bscon)
	e1:SetTarget(s.bstg)
	e1:SetOperation(s.bsop)
    c:RegisterEffect(e1)
    --  2° Añadir o colocar 1 Mágica/Trampa "Flauriga" desde tu Deck
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_NO_TURN_RESET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END|TIMING_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(Cost.PayLP(1000))
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0x3ee}
    --  *EFECTO 0°
function s.valcon(e)
	return e:GetHandler():IsSynchroSummoned()
end
function s.valop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	local tc=g:GetFirst()
	local atk=0
	while tc do
		if tc:IsType(TYPE_TUNER) and tc:IsSetCard(0x3ee) then
		local tatk=tc:GetTextAttack()
		if tatk<0 then tatk=0 end
		atk=atk+tatk
		end
		tc=g:GetNext()
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
end
	--  *EFECTO 1°
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetAttackAnnouncedCount()==0 end
	--	*No puede atacar este turno
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3206)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1,true)
	c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
end
function s.bscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSynchroSummoned()
end
function s.bstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1500)
end
function s.bsop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.BreakEffect()
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
		if tc:IsLocation(LOCATION_HAND|LOCATION_EXTRA) and tc:IsMonster() then
			Duel.Recover(tp,1500,REASON_EFFECT)
		end
	end
end
	--  *EFECTO 2°
function s.thfilter(c)
	return c:IsSpellTrap() and c:IsSetCard(0x3ee) and (c:IsAbleToHand() or c:IsSSetable())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not tc then return end
	aux.ToHandOrElse(tc,tp,
		Card.IsSSetable,
		function(c)
			Duel.SSet(tp,tc)
		end,
		aux.Stringid(id,2)
	)
end