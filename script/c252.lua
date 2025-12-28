--Incursión Flauriga
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--  0° Invocar de Modo Especial 1 monstruo "Flauriga" y posible destierro
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE+CATEGORY_DISABLE)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e0:SetCountLimit(1,{id,0})
    e0:SetCost(Cost.PayLP(1000))
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
    c:RegisterEffect(e0)
    --  1° Robar cartas
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCost(Cost.SelfBanish)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
end
s.listed_series={0x3ee}
    --  *EFECTO 0°
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x3ee) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_MZONE)
    --  *Negación en cadena
    local ch=Duel.GetCurrentChain()-1
	local trig_p,trig_e=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and ch>0 and trig_p==1-tp and trig_e:IsMonsterEffect() and Duel.IsChainDisablable(ch)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x3ee),tp,LOCATION_MZONE,0,1,nil) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0
		or tc:IsFacedown() or not tc:IsType(TYPE_SYNCHRO|TYPE_XYZ) then return end
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAttackBelow,tc:GetAttack()),tp,0,LOCATION_MZONE,nil)
	if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local dg=g:Select(tp,1,1,nil)
	if #dg>0 then
		Duel.HintSelection(dg,true)
		Duel.BreakEffect()
        Duel.Remove(dg,POS_FACEUP,REASON_EFFECT)
    end
    local ch=Duel.GetCurrentChain()-1
	if e:GetLabel()==1 then
		Duel.NegateEffect(ch)
	end
end
    --  *EFECTO 1°
function s.drfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3ee) and c:IsMonster()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroup(s.drfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil):GetClassCount(Card.GetAttribute)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.GetMatchingGroup(s.drfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil):GetClassCount(Card.GetRace)
	Duel.Draw(p,ct,REASON_EFFECT)
end