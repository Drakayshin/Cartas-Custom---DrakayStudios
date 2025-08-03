--Revitalizador de Oricalcos
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    -- 	0° Puedes activar desde la mano
    local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,1))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(function(e) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==0 end)
	c:RegisterEffect(e0)
    -- 	1° Activar 1 carta de Campo
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.actg)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
	-- 	2° Ganar LP igual al ATK de un tipo de monstruo en el Campo
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
s.listed_names={48179391,125,130}
    -- 	*EFECTO 1°
function s.acfilter(c,tp)
	return c:IsFieldSpell() and c:IsCode(48179391,125,130)
end
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.acfilter,tp,LOCATION_DECK,0,1,nil,tp)
		and Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.acfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
		end
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		Duel.BreakEffect()
		Duel.DiscardDeck(tp,3,REASON_EFFECT)
	end
end
	-- 	*EFECTO 2°
function s.rfilter(c,race)
	return c:IsFaceup() and c:IsRace(race)
end
function s.filter(c)
	return c:IsFaceup()
		and Duel.GetMatchingGroup(s.rfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil,c:GetRace()):GetSum(Card.GetAttack)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local val=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,g:GetFirst():GetRace()):GetSum(Card.GetAttack)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,val)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local val=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tc:GetRace()):GetSum(Card.GetAttack)
		Duel.Recover(tp,val,REASON_EFFECT)
	end
end