--Ryumaru, Luchador Flauriga
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  0° Invocar de Modo Especial y tratarla como un monstruo Cantante
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,{id,0})
	e0:SetCost(s.selfspcost)
	e0:SetTarget(s.selfsptg)
	e0:SetOperation(s.selfspop)
	c:RegisterEffect(e0)
	--  1° monstrar 1 carta en tu mano y añadir a tu mano 2 cartas "Flauriga" con diferentes tipo (Monstruo, Magia, Trampa)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCost(Cost.Reveal(s.revealfilter,true,1,1,function(e,tp,g) e:SetLabel(g:GetFirst():GetMainCardType()) end))
	e1:SetTarget(s.handtg)
	e1:SetOperation(s.handop)
	c:RegisterEffect(e1)
	--  1° Efectos añadidos al ser material de Sincronía
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCountLimit(1,{id,2})
	e2:SetCondition(s.effcon)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_series={0x3ee}
    --  *EFECTO 0°
function s.selfspcostfilter(c,tp)
	return c:IsAbleToRemoveAsCost() and c:IsSetCard(0x3ee) and  c:IsMonster() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.selfspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0
		and Duel.IsExistingMatchingCard(s.selfspcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,tp) end
	e:GetHandler():RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.selfspcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		--  *Es tratado como un monstruo Cantante
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end
    --  *EFECTO 1°
function s.revealfilter(c,e,tp)
	return c:IsSetCard(0x3ee) and not c:IsPublic()
	and Duel.GetMatchingGroup(s.handtgfilter,tp,LOCATION_DECK,0,nil,c:GetMainCardType()):GetClassCount(Card.GetMainCardType)==2
end
function s.handtgfilter(c,main_type)
	return c:IsSetCard(0x3ee) and c:IsAbleToHand() and not c:IsType(main_type)
end
function s.handtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.handop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.handtgfilter,tp,LOCATION_DECK,0,nil,e:GetLabel())
	if #g<2 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetMainCardType),1,tp,HINTMSG_ATOHAND)
	if #sg==2 and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD,nil)
	end
end
	--	*EFECTO 2°
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
    return ((r==REASON_XYZ and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)) 
    or (r==REASON_SYNCHRO and e:GetHandler():GetReasonCard():HasLevel())) and e:GetHandler():GetReasonCard():IsSetCard(0x3ee)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--  *Robar 1 carta si destruye a un monstruo en batalla
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(aux.bdocon)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD)
    rc:RegisterEffect(e1)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end