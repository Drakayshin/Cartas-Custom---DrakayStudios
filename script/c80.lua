--Aveniencia Terranigma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  0° Activar desde la mano si controlas un monstruo "Terranigma" de nivel 7 o mayor
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(function(e) return Duel.IsExistingMatchingCard(s.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) end)
	c:RegisterEffect(e0)
	--  1° Tomar el control de un monstruo Invocado de Modo Especial por tu adversario
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    --  2° Añadir a tu mano 1 monstruo "Terranigma" desde el Deck o Cementerio y luego poder Invocar de Modo Normal 1 monstruo "Terranigma"
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAIN_NEGATED)
	e2:SetRange(LOCATION_GRAVE|LOCATION_REMOVED)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.thcond)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,2))
	e2a:SetCategory(CATEGORY_TOHAND)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2a:SetCode(EVENT_DESTROYED)
	e2a:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp and r&REASON_EFFECT>0 end)
	e2a:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2a:SetTarget(s.thtg)
	e2a:SetOperation(s.thop)
    c:RegisterEffect(e2a)
end
s.listed_series={0x3e7}
    --  *EFECTO 0°
function s.actfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3e7) and c:IsMonster()
end
    --  *EFECTO 1°
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return tc:IsAbleToChangeControler() end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,eg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
        Duel.GetControl(tc,tp)
		--  *Destierralo si deja el Campo
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		tc:RegisterEffect(e1,true)
		Duel.BreakEffect()
	end
end
    --  *EFECTO 2°
function s.thcond(e,tp,eg,ep,ev,re,r,rp)
	local de,dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_REASON,CHAININFO_DISABLE_PLAYER)
	return re:GetHandler()==e:GetHandler() and re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp==tp and de and dp~=tp
end
function s.filter1(c)
	return c:IsSetCard(0x3e7) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.sumfilter(c)
	return c:IsSetCard(0x3e7) and c:IsSummonable(true,nil)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		if not g:GetFirst():IsLocation(LOCATION_HAND) then return end
		-- *Invocar de Modo Normal
		local sg1=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
		if #sg1>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.ShuffleHand(tp)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local sg2=sg1:Select(tp,1,1,nil):GetFirst()
			Duel.Summon(tp,sg2,true,nil)
		end
	end
end